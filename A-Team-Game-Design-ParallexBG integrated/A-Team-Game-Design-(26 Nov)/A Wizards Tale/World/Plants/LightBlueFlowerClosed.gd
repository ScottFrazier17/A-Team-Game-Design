extends Light2D

const MIN_ENERGY = 0.1
const MAX_ENERGY = 1.8
var updatedEnergy = MIN_ENERGY
var flag = 1

func _process(delta):
    updatedEnergy += flag*delta*0.5
    if(updatedEnergy>MAX_ENERGY):
      flag = -1
    if(updatedEnergy<MIN_ENERGY):
      flag = 1  
    set_energy(updatedEnergy)   
