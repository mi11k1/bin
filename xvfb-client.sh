ssh -N -T -L 5900:localhost:5900 10.42.0.58 &
 vncviewer -encodings 'copyrect tight zrle hextile' localhost:5900
