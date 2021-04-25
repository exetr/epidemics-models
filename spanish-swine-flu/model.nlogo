;; Author: Teo Chuan Kai
;; For UQF2101A Quantitative Reasoning Foundation: Epidemics AY2020/21 S2
;; Model for comparison between Spanish flu and swine flu pandemics

globals [
  infected
  deaths
  vaccinated
  %fatality
  current-tick
]

turtles-own [
  infected?       ;; bool: is person infected?
  immune?         ;; bool: is person recovered and immune?
  infected-time   ;; int: amount of ticks since person has been infected
  recovered-time  ;; int:
  vaccinated?     ;; bool: is person vaccinated?
]

to setup
  clear-all
  setup-people
  set current-tick 0
  reset-ticks
end

to setup-people
  set-default-shape turtles "person"
  crt population
  [
    setxy random-xcor random-ycor
    set infected? false
    set immune? false
    set vaccinated? false
    set infected-time 0
    set color white
  ]
  ask n-of 1 turtles [get-infected]
end

to get-infected
  set infected? true
  set color red
  set infected (infected + 1)
end

to get-recovered
  set infected? false
  set immune? true
  set color green
end

to get-vaccinated
  set vaccinated? true
  set color blue
  set vaccinated (vaccinated + 1)
end

to go
  advance-tick
  move
  vaccinate
  infect
  recover
  if (count turtles with [infected?] = 0) [stop]
  update-globals
  tick
end

to advance-tick
  set current-tick (current-tick + 1)
  ask turtles [
    if infected? [set infected-time (infected-time + 1)]
  ]
end

to move
  ask turtles [
    rt random-float 360
    ifelse control-measures? and current-tick > control-start
    [ fd 1 ]
    [ fd 2 ]
  ]
end

to infect
  ask turtles with [infected?] [
    ask other turtles-here with [not immune? and not vaccinated?] [
      if (random-float 100) < chance-infect [get-infected]
    ]
    ask other turtles-here with [not immune? and vaccinated?] [
      if (((random-float 100) * (vaccine-efficacy / 100)) < chance-infect) [get-infected]
    ]
  ]
end

to recover
  ask turtles with [infected?] [
    if (random infected-time) > contagious-duration [
      ifelse ((random-float 100) < chance-recover)
      [get-recovered]
      [ die ]
    ]
  ]
end

to vaccinate
  if (control-measures? and current-tick > control-start) [
    ask turtles with [not vaccinated? and not infected?] [
      if (random-float 100) < vaccine-rate [get-vaccinated]
    ]
  ]
end

to update-globals
  set deaths (population - count turtles)
  set %fatality (deaths / infected) * 100
end