# Flutter_dots
# A Flutter web app to count black and white dots in the mind (representing bad and good thoughts).
The web package using "Flutter build web" shows blank page in Android System Browser and Wechat Browser. 
By opening index.html, we can see error in the following line:

if (!reg.active && (reg.installing || reg.waiting)) {
// No active web worker and we have installed or are installing
// one for the first time. Simply wait for it to activate.
waitForActivation(reg.installing ?? reg.waiting);

Just change the above index.html file "??" into "||" , problem fixed.
