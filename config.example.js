module.exports = {
  apikey : 'CWB-FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF',
  listen : {
    earthquake : {
      id : 'E-A0015-001',
      interval : 30000
    },
    earthquake_mini : {
      id : 'E-A0016-001',
      interval : 30000
    }
  },
  port : process.env.PORT || 80,
  ip : process.env.IP || "0.0.0.0"
};