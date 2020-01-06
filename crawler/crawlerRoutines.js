const conf = require('../config');
const Util = require('../commonUtil').Util;
const DataModel = require('../dataModel').DataModel;

class Routines {
    static async  _updateSuspiciousStatus(mongoCollection) {
        let allUsers = await DataModel.getAllUsers();
        for (const i in allUsers) {
            let user = allUsers[i];
            let userData = await DataModel.getUserLastData(user, mongoCollection);
            let findRes = await mongoCollection.findOne({ '_id': user });
            if (!userData) throw Error('User data not found in mongodb, most likely data not in sync.');
            let body = {
                "pk": user,
                "username": findRes.username,
                "followerCount": userData['follower_count']['value'][0],
                "followingCount": userData['following_count']['value'][0]
            }
            let getSuspiciousResponse = await Util.sendHttpRequest('post', body, conf.mockstagramApiService, '/api/v1/influencers/is_suspicious');
            let r = await mongoCollection.updateOne({ '_id': user }, { '$set': { 'isSuspicious': getSuspiciousResponse.suspicious } });
        }
    }

    static async updateSuspiciousStatusInterval(mongoCollection, intervalSeconds = 24 * 60 * 60) {
        return setInterval(async () => {
            this._updateSuspiciousStatus(mongoCollection);
        }, intervalSeconds * 1000);
    }

    static async  refreshPushgatewayInterval(intervalSeconds = conf.crawlerIntervalSeconds * 3) { //unused, now using docker
        return setInterval(async () => {
            let processStatus = Util.startNewChildProcess('curl', ['-X', 'PUT', conf.pushgatewayService + '/api/v1/admin/wipe']);
        }, intervalSeconds * 1000);
    }
}

module.exports.Routines = Routines;