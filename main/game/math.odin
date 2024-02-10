package GAME

import "core:math"
import RL "vendor:raylib"
import "core:fmt"

VectorPair :: struct {
    v1: RL.Vector2,
    v2: RL.Vector2
}

doHitboxOverlap :: proc (hb1, hb2: Hitbox) -> bool {
    return f32((hb1.x-hb2.x)*(hb1.x-hb2.x) + (hb1.y-hb2.y)*(hb1.y-hb2.y)) <= 
                (hb1.radius+hb2.radius)*(hb1.radius+hb2.radius)
}

calculateDirection :: proc(hb1, hb2: RL.Vector2) -> Direction {
    angleRad := math.atan2_f32((hb1.y - hb2.y), (hb1.x - hb2.x));
    angleDeg := angleRad * 180.0 / math.PI;
    if angleDeg < 0 {angleDeg += 360}

    if ((angleDeg >= 0 && angleDeg < 22.5) || (angleDeg <= 360 && angleDeg > 337.5)) {return Direction.W}
    else if (angleDeg >= 22.5 && angleDeg <= 67.5) {return Direction.NW}
    else if (angleDeg > 67.5 && angleDeg <= 112.5) {return Direction.N}
    else if (angleDeg > 112.5 && angleDeg <= 157.5) {return Direction.NE}
    else if (angleDeg > 157.5 && angleDeg <= 202.5) {return Direction.E}
    else if (angleDeg > 202.5 && angleDeg <= 247.5) {return Direction.SE}
    else if (angleDeg > 247.5 && angleDeg <= 292.5) {return Direction.S}
    else {return Direction.SW}
}

calculateForce :: proc(hb1, hb2: Hitbox) -> VectorPair {
    vec1 := RL.Vector2{f32(hb1.x), f32(hb1.y)}
    vec2 := RL.Vector2{f32(hb2.x), f32(hb2.y)}
    fDistance := math.sqrt_f32((vec1.x - vec2.x)*(vec1.x-vec2.x)+(vec1.y - vec2.y)*(vec1.y - vec2.y))
    fOverlap := 0.5 * (fDistance - hb1.radius - hb2.radius);

    vec1.x -= fOverlap * (vec1.x - vec2.x) / fDistance;
	vec1.y -= fOverlap * (vec1.y - vec2.y) / fDistance;

	vec2.x += fOverlap * (vec1.x - vec2.x) / fDistance;
	vec2.y += fOverlap * (vec1.y - vec2.y) / fDistance;

    return VectorPair{vec1, vec2}
}

dynamicCollision :: proc(ac1, ac2: ^Actor) {
    v1 := RL.Vector2{f32(ac1.mHitbox.x), f32(ac1.mHitbox.y)}
    v2 := RL.Vector2{f32(ac2.mHitbox.x), f32(ac2.mHitbox.y)}

    fDistance := math.sqrt_f32((v1.x - v2.x)*(v1.x - v2.x) + (v1.y - v2.y)*(v1.y - v2.y));

	// Normal
	nx := (v2.x - v1.x) / fDistance;
	ny := (v2.y - v1.y) / fDistance;

	// Tangent
	tx := -ny;
	ty := nx;

	// Dot Product Tangent
	dpTan1 := ac1.mVelocity.x * tx + ac1.mVelocity.y * ty;
	dpTan2 := ac2.mVelocity.x * tx + ac2.mVelocity.y * ty;

	// Dot Product Normal
	dpNorm1 := ac1.mVelocity.x * nx + ac1.mVelocity.y * ny;
	dpNorm2 := ac2.mVelocity.x * nx + ac2.mVelocity.y * ny;

	// Conservation of momentum in 1D
	m1 := (dpNorm1 * (ac1.mMass - ac2.mMass) + 2 * ac2.mMass * dpNorm2) / (ac1.mMass + ac2.mMass);
	m2 := (dpNorm2 * (ac2.mMass - ac1.mMass) + 2 * ac1.mMass * dpNorm1) / (ac1.mMass + ac2.mMass);

    x := tx * dpTan1 + nx * m1;
    y := ty * dpTan1 + ny * m1;
	// Update velocities
	ac1.mVelocity = RL.Vector2{tx * dpTan1 + nx * m1, ty * dpTan1 + ny * m1}
	ac2.mVelocity = RL.Vector2{tx * dpTan2 + nx * m2, ty * dpTan2 + ny * m2}
}