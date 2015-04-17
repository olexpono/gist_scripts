var _ = require("lodash-node")
var fs = require("fs")
console.log(_ ? "Lodash Loaded" : "Lodash Failed")

var fileArgs = process.argv.slice(2);

/********
 *
 * taken from pysplash/courses/static/javascript/curricula/curriculum.time.js
 *
//*/
var getMinutesValue = function(rawTimeText) {
    /**
     * timeText => timeMatch
     * "" =>            null
     * "90" =>          ["90", "90", undefined, undefined]
     * "7 Hours" =>     ["7 Hours", "7", undefined, " Hours"]
     * "4-6 hours" =>   ["4-6 hours", "4", "-6", " hours"]
     * "6 hours / ~3 days" =>
     *      ["6 hours / ~3 days", "6", undefined, " hours / ~3 days"]
     **/
    timeText = (rawTimeText || "").replace(/^\s+/g, '')
    timeMatch = timeText.match(/^([\d.]+)(-[\d]+)?(\s+.*)?/);

    if (!timeMatch || timeMatch.length < 1) {
        // No time found in a leaf node, assume one hour
        return null;
    } else if (timeMatch[3]) {
        // Figure out unit based on the rest of the string after the number
        if (timeMatch[3].replace(/^\s+/g, '')[0].match(/[Hh]/)) {
            // First non-space char is an "h", so assume hours.
            return parseFloat(timeMatch[1]) * 60;
        } else {
            // Otherwise minutes
            return parseFloat(timeMatch[1]);
        }
    } else {
        // Assume the time was in minutes already
        return parseFloat(timeMatch[1]);
    }
}
/**********
   * END Ripped code
// */

console.log("Initiating conversion for these files:");
for (var i = 0; i < fileArgs.length; i++) {
    var filename = fileArgs[i];
    console.log(" ---- " + filename);
    var metadata;
    try {
        metadata = require("../" + filename);
    } catch(e) {
        console.log("ERROR! "+ filename);
        console.log(e);
        console.log("Skipping!");
        continue;
    }
    var minutes;
    var origTime = metadata["time"];

    if (!metadata["time"]) {
        console.log(" -->  No time field. Skipped.");
        continue;
    }

    minutes = getMinutesValue(metadata["time"]);

    if (minutes) {
        console.log('"' + origTime + '" => "' + (minutes || "deleted") + '"');
        metadata["time"] = minutes.toString();
    } else {
        console.log(" -!-> Could not parse " + origTime + ", defaulting to TBD");
        metadata["time"] = "TBD";
    }

    if (!filename.match(/\/assignments\/\d/)) {
        console.log(" -->  Not an assignment. Time Req Deleted.");
        delete metadata.time;
    }

    (function() {
        var savefn = filename;
        fs.writeFile(savefn,
            JSON.stringify(metadata, null, 4) + "\n",
            function(err) {
        console.log(err ? err : ("Saved  " + savefn));
        });
    })();
}
