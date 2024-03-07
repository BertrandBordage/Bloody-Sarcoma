extends Node


func sum(values: Array):
    if values.size() == 0:
        return null
    return values.reduce(func (a, b): return a + b)


func avg(values: Array):
    if values.size() == 0:
        return null
    return values.reduce(func (a, b): return a + b) / values.size()


func choice(choices: Array, weights: Array[float]):
    var total = sum(weights)
    var ratios_points = weights.reduce(
        func (accum, weight): return accum + [weight + sum(accum)],
        [0],
    ).map(func (weight): return weight / total)
    var value = randf()
    for i in range(choices.size()):
        if value >= ratios_points[i] and value < ratios_points[i+1]:
            return choices[i]
