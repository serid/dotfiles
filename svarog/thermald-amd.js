// Check CPU temperature every second and adjust max CPU frequency
// to prevent overheating

import { readFile, writeFile, readdir } from 'fs/promises'
import { setTimeout } from 'node:timers/promises';

const PERIOD = 400 // milliseconds
const HIGH_THRESHOLD_TEMPERATURE = 83000 // millidegree Celcius
const THRESHOLD_WIDTH = 5000 // millidegree Celcius

// hardware-specific settings

const SENSOR_DIR = "/sys/bus/pci/drivers/k10temp/0000:00:18.3/hwmon/"
const SENSOR_PATH = await (async () => {
  let entries = await readdir(SENSOR_DIR)
  if (entries.length != 1) throw new Error("unexpected hwmon layout")
  return `${SENSOR_DIR}${entries[0]}/temp1_input`
})()
const N_PROC = 16

const DEFAULT_MIN_FREQ = parseInt(await readFile("/sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq", { encoding: 'utf8' }))
const DEFAULT_MAX_FREQ = parseInt(await readFile("/sys/devices/system/cpu/cpufreq/policy0/amd_pstate_max_freq", { encoding: 'utf8' }))
const FREQ_RANGE = DEFAULT_MAX_FREQ-DEFAULT_MIN_FREQ

function linpo(ratio, a, b) {
  return a * ratio + b * (1 - ratio)
}

function clamp(x) {
  return Math.min(Math.max(x, 0), 1)
}

while (true) {
  let currTemperature = await readFile(SENSOR_PATH, { encoding: 'utf8' })
  currTemperature = parseInt(currTemperature.trim())

  let tempRatio = clamp((HIGH_THRESHOLD_TEMPERATURE-currTemperature)/THRESHOLD_WIDTH)
  let targetFreq = DEFAULT_MIN_FREQ +
    linpo(0.6, FREQ_RANGE, tempRatio*(FREQ_RANGE))


  targetFreq = Math.floor(targetFreq)
  // scaling_max_freq shall not be lower than scaling_min_freq
  targetFreq = Math.max(targetFreq, DEFAULT_MIN_FREQ)
  targetFreq = targetFreq.toString()

  for (let i = 0; i < N_PROC; i++) {
    await writeFile(`/sys/devices/system/cpu/cpufreq/policy${i}/scaling_max_freq`, targetFreq)
  }

  // console.log(`T=${currTemperature/1000} °C; Setting Freq to ${targetFreq/1000}`)
  await setTimeout(PERIOD);
}