var exec = require('cordova/exec');

exports.startTrace = function (arg0, success, error) {
    exec(success, error, 'wwareBaiduYY', 'startTrace', [arg0]);
};
exports.stopTrace = function (arg0, success, error) {
    exec(success, error, 'wwareBaiduYY', 'stopTrace', [arg0]);
};
exports.startGather = function (arg0, success, error) {
    exec(success, error, 'wwareBaiduYY', 'startGather', [arg0]);
};
exports.stopGather = function (arg0, success, error) {
    exec(success, error, 'wwareBaiduYY', 'stopGather', [arg0]);
};
exports.setLocationMode = function (arg0, success, error) {
    exec(success, error, 'wwareBaiduYY', 'setLocationMode', [arg0]);
};
exports.setInterval = function (arg0, success, error) {
    exec(success, error, 'wwareBaiduYY', 'setInterval', [arg0]);
};
exports.queryDistance = function (arg0, success, error) {
    exec(success, error, 'wwareBaiduYY', 'queryDistance', [arg0]);
};
exports.queryHistoryTrack = function (arg0, success, error) {
    exec(success, error, 'wwareBaiduYY', 'queryHistoryTrack', [arg0]);
};
