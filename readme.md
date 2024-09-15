# A Bright Idea

My entry for Vision Hack 2024.

I thought I had a bright idea.

![idea](idea-01.png)

I set out to create a small app to organize your ideas in an immersive space. Each idea could be represented by scale and brightness. I created a simple light bulb mesh and started the prototype with a point light.

![idea](idea-02.png)

I ran face first into my first issue.

> A RealityKit scene can contain up to eight dynamic lights

Apple Documentation for [PointLight](https://developer.apple.com/documentation/realitykit/pointlight)

I don't know about you, but I have a lot more than eight ideas that I want to keep track of...



So I started thinking about workarounds. How about emissive materials?

> You can set this property to values greater than 1.0.

Apple Documentation for [emissiveIntensity](https://developer.apple.com/documentation/realitykit/physicallybasedmaterial/emissiveintensity)

I tried that, but it didn't pan out. I could not perceive a difference between 1.0, 10, 100, or even 1,000!



I couldn't use Point Lights because of the limited number per scene and emissive materials didn't showcase the difference in ideas that I wanted. My idea came crashing down.

Which gave me another idea...

![idea](idea-03.png)

 What if I set aside my original idea and embrace this failure instead? I kept working. I kept reaching for idea after idea and they kept crashing down. I kept at it until I arrived at this.