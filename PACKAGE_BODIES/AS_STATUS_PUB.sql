--------------------------------------------------------
--  DDL for Package Body AS_STATUS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_STATUS_PUB" AS
/* $Header: asxpstab.pls 115.5 2003/01/28 23:10:11 geliu ship $ */

-- Declare Global Variables
G_PKG_NAME           CONSTANT VARCHAR2(30) := 'AS_STATUSES_PUB';

-- Start of Comments
--
-- API Name        : create_status
-- Type            : Public
-- Function        : To create status codes using the table handler
-- Pre-Reqs        : The table handler API AS_STATUSES_PKG.INSERT_ROW
--                   should exist
-- Parameters      :
--         IN      : p_api_version_number  IN    NUMBER
--                   p_init_msg_list       IN    VARCHAR2
--                   p_commit              IN    VARCHAR2
--                   p_validation_level    IN    NUMBER
--                   p_status_rec          IN    STATUS_Rec_Type
--        OUT      : x_return_status       OUT   VARCHAR2
--                   x_msg_count           OUT   NUMBER
--                   x_msg_data            OUT   VARCHAR2
-- Version         : 2.0
-- Purpose         : To create status codes in as_statuses_b,_tl,_vl tables
-- Notes           : This procedure is a public procedure called using the
--                   public API as_status_pub to create status codes.
--
-- End of Comments :

PROCEDURE create_status (
    p_api_version_number      IN    NUMBER,
    p_init_msg_list           IN    VARCHAR2         ,
    p_commit                  IN    VARCHAR2         ,
    p_validation_level        IN    NUMBER           ,
    p_status_rec              IN    STATUS_Rec_Type  ,
    x_return_status           OUT   VARCHAR2,
    x_msg_count               OUT   NUMBER,
    x_msg_data                OUT   VARCHAR2)
IS
-- Declaration of local variables and cursors
l_api_version                      NUMBER :=  p_api_version_number;
l_api_name        CONSTANT         VARCHAR(30)    DEFAULT 'CREATE_STATUS';
l_count                            NUMBER;
l_row_id                           VARCHAR2(2000) DEFAULT ' ';
l_creation_date                    DATE          ;
l_created_by                       NUMBER        ;
l_last_update_date                 DATE          ;
l_last_updated_by                  NUMBER        ;
l_last_update_login                NUMBER        ;
l_status_rank                      NUMBER        ;
l_attribute_category               VARCHAR2(30)  ;
l_attribute1                       VARCHAR2(150) ;
l_attribute2                       VARCHAR2(150) ;
l_attribute3                       VARCHAR2(150) ;
l_attribute4                       VARCHAR2(150) ;
l_attribute5                       VARCHAR2(150) ;
l_attribute6                       VARCHAR2(150) ;
l_attribute7                       VARCHAR2(150) ;
l_attribute8                       VARCHAR2(150) ;
l_attribute9                       VARCHAR2(150) ;
l_attribute10                      VARCHAR2(150) ;
l_attribute11                      VARCHAR2(150) ;
l_attribute12                      VARCHAR2(150) ;
l_attribute13                      VARCHAR2(150) ;
l_attribute14                      VARCHAR2(150) ;
l_attribute15                      VARCHAR2(150) ;
l_description                      VARCHAR2(240) ;

-- Cursor for checking duplicate status code
CURSOR status_dup_cur(p_status_code IN VARCHAR2) IS
       SELECT 1
         FROM as_statuses_vl
        WHERE TRIM(NLS_UPPER(status_code)) = p_status_code;  -- trimmed value passed while opening

BEGIN
-- Standard start of api save point
   SAVEPOINT create_status;

-- Initialize Message List
   IF fnd_api.to_boolean (p_init_msg_list)
   THEN
       fnd_msg_pub.initialize;
   END IF;

-- Standard Call to check api compatibility
   IF NOT fnd_api.compatible_api_call (
              l_api_version,
              p_api_version_number,
              l_api_name,
              G_PKG_NAME
           )
   THEN
       fnd_message.set_name('AS', 'AS_INVALID_VERSION');
       fnd_msg_pub.add;
   END IF;

-- Initialize api return status
   x_return_status := fnd_api.g_ret_sts_success;

-- Check if the version number passed is 2.0 else error out
IF    p_api_version_number <> 2.0
THEN
       fnd_message.set_name('AS', 'AS_INVALID_VERSION');
       fnd_msg_pub.add;
END IF;


-- API Body
-- Begin Validation Section
-- Check for valid values being passed.

   IF   (p_status_rec.enabled_flag  NOT IN ('Y','N')
   OR    p_status_rec.enabled_flag  = FND_API.G_MISS_CHAR
   OR    TRIM(p_status_rec.enabled_flag)  IS NULL)
   THEN
        fnd_message.set_name('AS', 'AS_ENABLED_FLAG_INVALID');
        fnd_msg_pub.add;
   END IF;
   IF   (p_status_rec.lead_flag    NOT IN ('Y','N')
   OR   p_status_rec.lead_flag    = FND_API.G_MISS_CHAR
   OR   TRIM(p_status_rec.lead_flag)   IS NULL)
   THEN
        fnd_message.set_name('AS', 'AS_LEAD_FLAG_INVALID');
        fnd_msg_pub.add;
   END IF;
   IF   (p_status_rec.opp_flag      NOT IN ('Y','N')
   OR    p_status_rec.opp_flag  = FND_API.G_MISS_CHAR
   OR    TRIM(p_status_rec.opp_flag)  IS NULL)
   THEN
        fnd_message.set_name('AS', 'AS_OPP_FLAG_INVALID');
        fnd_msg_pub.add;
   END IF;
   IF   (p_status_rec.opp_open_status_flag   NOT IN ('Y','N')
   OR   TRIM(p_status_rec.opp_open_status_flag)  = FND_API.G_MISS_CHAR
   OR   TRIM(p_status_rec.opp_open_status_flag)  IS NULL)
   THEN
        fnd_message.set_name('AS', 'AS_OPP_OPEN_FLAG_INVALID');
        fnd_msg_pub.add;
   END IF;
   IF   (p_status_rec.opp_decision_date_flag NOT IN ('Y','N')
   OR    p_status_rec.opp_decision_date_flag = FND_API.G_MISS_CHAR
   OR    TRIM(p_status_rec.opp_decision_date_flag) IS NULL)
   THEN
        fnd_message.set_name('AS', 'AS_DECISION_FLAG_INVALID');
        fnd_msg_pub.add;
   END IF;
   IF   (p_status_rec.forecast_rollup_flag NOT IN ('Y','N')
   OR    p_status_rec.forecast_rollup_flag = FND_API.G_MISS_CHAR
   OR    TRIM(p_status_rec.forecast_rollup_flag) IS NULL)
   THEN
        fnd_message.set_name('AS', 'AS_FORECAST_FLAG_INVALID');
        fnd_msg_pub.add;
   END IF;

   IF   (p_status_rec.win_loss_indicator     NOT IN ('W','L')
   OR    p_status_rec.win_loss_indicator= FND_API.G_MISS_CHAR
   OR    TRIM(p_status_rec.win_loss_indicator) IS NULL)
   THEN
        fnd_message.set_name('AS', 'AS_WIN_IND_INVALID');
        fnd_msg_pub.add;
   END IF;

-- Check if the required field Meaning is passed
   IF    (p_status_rec.meaning = FND_API.G_MISS_CHAR
   OR    TRIM(p_status_rec.meaning) IS NULL)
   THEN
        fnd_message.set_name('AS', 'AS_MEANING');
        fnd_msg_pub.add;
   END IF;

-- End Validation Section

-- Check for duplicate or uniqueness of the status code
-- Open the cursor and fetch the record.

    OPEN   status_dup_cur(TRIM(NLS_UPPER(p_status_rec.status_code)));
    FETCH  status_dup_cur INTO l_count;
    IF     (status_dup_cur%FOUND)
    THEN
          fnd_message.set_name('AS', 'AS_DUPLICATE_STATUS_CODE');
          fnd_message.set_token('STATUS_CODE', p_status_rec.status_code);
          fnd_msg_pub.add;
          CLOSE status_dup_cur;
    END IF;
    CLOSE status_dup_cur;

-- Check if the Who columns have any values otherwise default them.

   IF    (p_status_rec.creation_date = FND_API.G_MISS_DATE)
   OR    TRIM(p_status_rec.creation_date) IS NULL
   THEN
         l_creation_date := sysdate;
   ELSE
         l_creation_date := p_status_rec.creation_date ;
   END IF;
   IF    (p_status_rec.created_by = FND_API.G_MISS_NUM)
   OR    TRIM(p_status_rec.created_by) IS NULL
   THEN
          l_created_by := fnd_global.user_id;
   ELSE
          l_created_by := p_status_rec.created_by ;
   END IF;
   IF    (p_status_rec.last_update_date = FND_API.G_MISS_DATE)
   OR    TRIM(p_status_rec.last_update_date) IS NULL
   THEN
          l_last_update_date := sysdate;
   ELSE
          l_last_update_date := p_status_rec.last_update_date;
   END IF;
   IF    (p_status_rec.last_update_login = FND_API.G_MISS_NUM)
   OR    TRIM(p_status_rec.last_update_login) IS NULL
   THEN
          l_last_update_login := fnd_global.login_id;
   ELSE
          l_last_update_login := p_status_rec.last_update_login;
   END IF;
   IF    (p_status_rec.last_updated_by = FND_API.G_MISS_NUM)
   OR    TRIM(p_status_rec.last_updated_by) IS NULL
   THEN
          l_last_updated_by := fnd_global.user_id;
   ELSE
          l_last_updated_by := p_status_rec.last_updated_by ;
   END IF;

-- Check all optional fields if they have g_miss values then
-- replace those with null before inserting.

   IF    p_status_rec.status_rank = FND_API.G_MISS_NUM
   THEN
         l_status_rank := NULL;
   ELSE
         l_status_rank := p_status_rec.status_rank;
   END IF;
   IF    p_status_rec.attribute_category = FND_API.G_MISS_CHAR
   THEN
         l_attribute_category := NULL;
   ELSE
         l_attribute_category :=p_status_rec.attribute_category;
   END IF;
   IF    p_status_rec.attribute1 = FND_API.G_MISS_CHAR
   THEN
         l_attribute1 := NULL;
   ELSE
         l_attribute1 := p_status_rec.attribute1 ;
   END IF;
   IF    p_status_rec.attribute2 = FND_API.G_MISS_CHAR
   THEN
         l_attribute2 := NULL;
   ELSE
         l_attribute2 := p_status_rec.attribute2 ;
   END IF;
   IF    p_status_rec.attribute3 = FND_API.G_MISS_CHAR
   THEN
         l_attribute3   := NULL;
   ELSE
         l_attribute3 := p_status_rec.attribute3 ;
   END IF;
   IF    p_status_rec.attribute4 = FND_API.G_MISS_CHAR
   THEN
         l_attribute4   := NULL;
   ELSE
         l_attribute4 := p_status_rec.attribute4 ;
   END IF;
   IF    p_status_rec.attribute5 = FND_API.G_MISS_CHAR
   THEN
         l_attribute5   := NULL;
   ELSE
         l_attribute5 := p_status_rec.attribute5 ;
   END IF;
   IF    p_status_rec.attribute6 = FND_API.G_MISS_CHAR
   THEN
         l_attribute6    := NULL;
   ELSE
         l_attribute6 := p_status_rec.attribute6 ;
   END IF;
   IF    p_status_rec.attribute7 = FND_API.G_MISS_CHAR
   THEN
         l_attribute7   := NULL;
   ELSE
         l_attribute7 := p_status_rec.attribute7 ;
   END IF;
   IF    p_status_rec.attribute8 = FND_API.G_MISS_CHAR
   THEN
         l_attribute8  := NULL;
   ELSE
         l_attribute8 := p_status_rec.attribute8 ;
   END IF;
   IF    p_status_rec.attribute9 = FND_API.G_MISS_CHAR
   THEN
         l_attribute9   := NULL;
   ELSE
         l_attribute9 := p_status_rec.attribute9 ;
   END IF;
   IF    p_status_rec.attribute10 = FND_API.G_MISS_CHAR
   THEN
         l_attribute10   := NULL;
   ELSE
         l_attribute10 := p_status_rec.attribute10 ;
   END IF;
   IF    p_status_rec.attribute11 = FND_API.G_MISS_CHAR
   THEN
         l_attribute11   := NULL;
   ELSE
         l_attribute11 := p_status_rec.attribute11 ;
   END IF;
   IF    p_status_rec.attribute12 = FND_API.G_MISS_CHAR
   THEN
         l_attribute12   := NULL;
   ELSE
         l_attribute12 := p_status_rec.attribute12 ;
   END IF;
   IF    p_status_rec.attribute13 = FND_API.G_MISS_CHAR
   THEN
         l_attribute13   := NULL;
   ELSE
         l_attribute13 := p_status_rec.attribute13 ;
   END IF;
   IF    p_status_rec.attribute14 = FND_API.G_MISS_CHAR
   THEN
         l_attribute14   := NULL;
   ELSE
         l_attribute14 := p_status_rec.attribute14 ;
   END IF;
   IF    p_status_rec.attribute15 = FND_API.G_MISS_CHAR
   THEN
         l_attribute15   := NULL;
   ELSE
         l_attribute15 := p_status_rec.attribute15 ;
   END IF;
   IF    p_status_rec.description = FND_API.G_MISS_CHAR
   THEN
         l_description   := NULL;
   ELSE
         l_description := p_status_rec.description;
   END IF;

-- END OF CHECK OF ALL OPTIONAL FIELD FOR g_miss_values

-- Check for open_status and win_loss validations
-- Perform this check before every insert of the status code
-- if opp_open_status_flag is Y and win_loss_indicator is NULL or
-- if opp_open_status_flag is N and win_loss_indicator is not in W or L
-- then insert into as_statuses_b and as_statuses_tl using api.
-- else error out with a message.

   IF NOT  ((p_status_rec.opp_open_status_flag = 'Y' AND
             p_status_rec.win_loss_indicator IS NULL)
   OR       (p_status_rec.opp_open_status_flag = 'N' AND
             p_status_rec.win_loss_indicator IN ('W','L')))
   THEN
             fnd_message.set_name('AS', 'AS_INVALID_WL_STATUS_COMBO');
             fnd_msg_pub.add;
   END IF;

   IF (FND_MSG_PUB.COUNT_MSG > 0)
   THEN
      fnd_message.set_name('AS', 'AS_STATUS_INSERT_FAILED');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
   END IF;


-- Insert into as_statuses_b and as_statuses_tl using api
-- AS_STATUSES_PKG.INSERT_ROW

              AS_STATUSES_PKG.INSERT_ROW(
                  l_row_id,
                  p_status_rec.status_code,
                  p_status_rec.enabled_flag,
                  p_status_rec.lead_flag,
                  p_status_rec.opp_flag,
                  p_status_rec.opp_open_status_flag,
                  p_status_rec.opp_decision_date_flag,
                  p_status_rec.status_rank,
                  p_status_rec.forecast_rollup_flag,
                  p_status_rec.win_loss_indicator,
                  NULL,
                  l_attribute_category,
                  l_attribute1,
                  l_attribute2,
                  l_attribute3,
                  l_attribute4,
                  l_attribute5,
                  l_attribute6,
                  l_attribute7,
                  l_attribute8,
                  l_attribute9,
                  l_attribute10,
                  l_attribute11,
                  l_attribute12,
                  l_attribute13,
                  l_attribute14,
                  l_attribute15,
                  p_status_rec.meaning,
                  l_description,
                  l_creation_date,
                  l_created_by,
                  l_last_update_date,
                  l_last_updated_by,
                  l_last_update_login);

-- Standard Check for p_commit
   IF fnd_api.to_boolean (p_commit)
   THEN
       COMMIT WORK;
   END IF;

-- Standard call to get message count and if count is 1, get message infor.
   fnd_msg_pub.count_and_get(
       p_count  =>  x_msg_count,
       p_data   =>  x_msg_data
   );

-- Handling all the exceptions
EXCEPTION
    WHEN fnd_api.g_exc_error THEN
    ROLLBACK TO create_status;
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_msg_pub.count_and_get (
         p_count => x_msg_count,
         p_data  => x_msg_data
    );
    WHEN fnd_api.g_exc_unexpected_error THEN
    ROLLBACK TO create_status;
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.count_and_get (
         p_count => x_msg_count,
         p_data  => x_msg_data
    );
    WHEN OTHERS THEN
    ROLLBACK TO create_status;
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.count_and_get (
         p_count => x_msg_count,
         p_data  => x_msg_data
    );
END create_status;

-- Start of Comments
--
-- API Name        : update_status
-- Type            : Public
-- Function        : To update the status code using the table handler
-- Pre-Reqs        : Table Handler AS_STATUSES_PKG.UPDATE_ROW should exist
-- Parameters      :
--         IN      : p_api_version_number   IN     NUMBER
--                   p_init_msg_list        IN     VARCHAR2
--                   p_commit               IN     VARCHAR2
--                   p_validation_level     IN     NUMBER
--                   p_status_rec           IN     STATUS_Rec_Type
--        OUT      : x_return_status        OUT    VARCHAR2
--                   x_msg_count            OUT    NUMBER
--                   x_msg_data             OUT    VARCHAR2
-- Version         : 2.0
-- Purpose         : To update the status codes in as_statuses_b,tl,vl table
-- Notes           : This procedure is a public procedure called using the
--                   public API as_status_pub to update status codes.
--
-- End of Comments :

PROCEDURE update_status (
    p_api_version_number   IN     NUMBER,
    p_init_msg_list        IN     VARCHAR2 ,
    p_commit               IN     VARCHAR2 ,
    p_validation_level     IN     NUMBER,
    p_status_rec           IN     STATUS_Rec_Type ,
    x_return_status        OUT    VARCHAR2,
    x_msg_count            OUT    NUMBER,
    x_msg_data             OUT    VARCHAR2)

IS
-- Declaration of local variables and cursors
l_api_version                      NUMBER:= p_api_version_number;
l_api_name        CONSTANT         VARCHAR(30) DEFAULT 'UPDATE_STATUS';

l_enabled_flag                     VARCHAR2(1)   ;
l_lead_flag                        VARCHAR2(1)   ;
l_opp_flag                         VARCHAR2(1)   ;
l_opp_open_status_flag             VARCHAR2(1)   ;
l_opp_decision_date_flag           VARCHAR2(1)   ;
l_forecast_rollup_flag             VARCHAR2(1)   ;
l_win_loss_indicator               VARCHAR2(1)   ;

v_enabled_flag                     VARCHAR2(1)   ;
v_lead_flag                        VARCHAR2(1)   ;
v_opp_flag                         VARCHAR2(1)   ;
v_opp_open_status_flag             VARCHAR2(1)   ;
v_opp_decision_date_flag           VARCHAR2(1)   ;
v_forecast_rollup_flag             VARCHAR2(1)   ;
v_win_loss_indicator               VARCHAR2(1)   ;
l_last_update_date                 DATE          ;
v_last_update_date                 DATE          ;
l_last_updated_by                  NUMBER        ;
l_last_update_login                NUMBER        ;
l_status_rank                      NUMBER        ;
l_attribute_category               VARCHAR2(30)  ;
l_attribute1                       VARCHAR2(150) ;
l_attribute2                       VARCHAR2(150) ;
l_attribute3                       VARCHAR2(150) ;
l_attribute4                       VARCHAR2(150) ;
l_attribute5                       VARCHAR2(150) ;
l_attribute6                       VARCHAR2(150) ;
l_attribute7                       VARCHAR2(150) ;
l_attribute8                       VARCHAR2(150) ;
l_attribute9                       VARCHAR2(150) ;
l_attribute10                      VARCHAR2(150) ;
l_attribute11                      VARCHAR2(150) ;
l_attribute12                      VARCHAR2(150) ;
l_attribute13                      VARCHAR2(150) ;
l_attribute14                      VARCHAR2(150) ;
l_attribute15                      VARCHAR2(150) ;
l_meaning                          VARCHAR2(240) ;
l_description                      VARCHAR2(240) ;
v_status_rank                      NUMBER        ;
v_attribute_category               VARCHAR2(30)  ;
v_attribute1                       VARCHAR2(150) ;
v_attribute2                       VARCHAR2(150) ;
v_attribute3                       VARCHAR2(150) ;
v_attribute4                       VARCHAR2(150) ;
v_attribute5                       VARCHAR2(150) ;
v_attribute6                       VARCHAR2(150) ;
v_attribute7                       VARCHAR2(150) ;
v_attribute8                       VARCHAR2(150) ;
v_attribute9                       VARCHAR2(150) ;
v_attribute10                      VARCHAR2(150) ;
v_attribute11                      VARCHAR2(150) ;
v_attribute12                      VARCHAR2(150) ;
v_attribute13                      VARCHAR2(150) ;
v_attribute14                      VARCHAR2(150) ;
v_attribute15                      VARCHAR2(150) ;
v_meaning                          VARCHAR2(240) ;
v_description                      VARCHAR2(240) ;
l_current_last_update_date         DATE;


CURSOR  get_update_row_cur(p_status_code in VARCHAR2) IS
      SELECT   last_update_date,
               enabled_flag,
               lead_flag,
               opp_flag,
               opp_open_status_flag ,
               opp_decision_date_flag,
               forecast_rollup_flag,
               win_loss_indicator,
               attribute_category,
               attribute1,
               attribute2,
               attribute3,
               attribute4,
               attribute5,
               attribute6,
               attribute7,
               attribute8,
               attribute9,
               attribute10,
               attribute11,
               attribute12,
               attribute13,
               attribute14,
               attribute15,
               meaning,
               description,
               status_rank
        FROM   as_statuses_vl
       WHERE   TRIM(NLS_UPPER(status_code)) = p_status_code; -- trimmed value passed while opening

CURSOR  lock_row_for_update(p_status_code in VARCHAR2) IS
      SELECT   last_update_date
        FROM   as_statuses_vl
       WHERE   TRIM(NLS_UPPER(status_code)) = p_status_code; -- trimmed value passed while opening



BEGIN

-- Standard start of api save point
   SAVEPOINT update_status;

-- Initialize Message List
   IF fnd_api.to_boolean (p_init_msg_list)
   THEN
       fnd_msg_pub.initialize;
   END IF;

-- Standard Call to check api compatibility
   IF NOT fnd_api.compatible_api_call (
              l_api_version,
              p_api_version_number,
              l_api_name,
              G_PKG_NAME
           )
   THEN
       fnd_message.set_name('AS', 'AS_INVALID_VERSION');
       fnd_msg_pub.add;
   END IF;

-- Initialize api return status
   x_return_status := fnd_api.g_ret_sts_success;

-- Check if the version number passed is 2.0 else error out
IF    p_api_version_number <> 2.0
THEN
       fnd_message.set_name('AS', 'AS_INVALID_VERSION');
       fnd_msg_pub.add;
END IF;


-- API Body
-- Fetch all the column values into local variables from the database before
-- checking to see if the value passed in the input paramater was G_MISS or not.
-- If the input parameter was G_MISS then replace the value with the fetched value
-- from the database

  OPEN   get_update_row_cur(TRIM(NLS_UPPER(p_status_rec.status_code)));
   FETCH  get_update_row_cur
    INTO  l_last_update_date,
          l_enabled_flag,
          l_lead_flag,
          l_opp_flag,
          l_opp_open_status_flag ,
          l_opp_decision_date_flag,
          l_forecast_rollup_flag,
          l_win_loss_indicator,
          l_attribute_category,
          l_attribute1,
          l_attribute2,
          l_attribute3,
          l_attribute4,
          l_attribute5,
          l_attribute6,
          l_attribute7,
          l_attribute8,
          l_attribute9,
          l_attribute10,
          l_attribute11,
          l_attribute12,
          l_attribute13,
          l_attribute14,
          l_attribute15,
          l_meaning,
          l_description,
          l_status_rank;

   IF     get_update_row_cur%NOTFOUND
   THEN
          CLOSE  get_update_row_cur;
          RAISE fnd_api.g_exc_unexpected_error;
   END IF;

-- checking for G_MISS..and replace with original values if necessary
-- Validation for open_status_flag and win loss indicator needs to be done here..

IF    p_status_rec.opp_open_status_flag = FND_API.G_MISS_CHAR
THEN
      v_opp_open_status_flag  := l_opp_open_status_flag;
ELSE
      IF p_status_rec.opp_open_status_flag = 'Y'
      THEN
         v_opp_open_status_flag  := p_status_rec.opp_open_status_flag ;
         v_win_loss_indicator  := NULL;
      ELSIF p_status_rec.opp_open_status_flag = 'N'
      THEN
          v_opp_open_status_flag  := p_status_rec.opp_open_status_flag ;
          IF   p_status_rec.win_loss_indicator = FND_API.G_MISS_CHAR
          OR   TRIM(p_status_rec.win_loss_indicator) IS NULL
          THEN
               v_win_loss_indicator  := l_win_loss_indicator;
    	  ELSIF   v_win_loss_indicator  NOT IN ('W','L')
          AND  v_win_loss_indicator  IS NOT NULL
	  THEN
		  fnd_message.set_name('AS', 'AS_WIN_IND_INVALID');
                  fnd_msg_pub.add;
          ELSE
              v_win_loss_indicator  := p_status_rec.win_loss_indicator;
          END IF;
      ELSE
        fnd_message.set_name('AS', 'AS_OPP_OPEN_FLAG_INVALID');
        fnd_msg_pub.add;
      END IF;
END IF;

IF    p_status_rec.enabled_flag = FND_API.G_MISS_CHAR
THEN
      v_enabled_flag := l_enabled_flag;
ELSE
      v_enabled_flag := p_status_rec.enabled_flag ;
END IF;
IF    p_status_rec.lead_flag = FND_API.G_MISS_CHAR
THEN
      v_lead_flag := l_lead_flag ;
ELSE
      v_lead_flag := p_status_rec.lead_flag ;
END IF;
IF    p_status_rec.opp_flag = FND_API.G_MISS_CHAR
THEN
      v_opp_flag := l_opp_flag ;
ELSE
      v_opp_flag := p_status_rec.opp_flag;
END IF;
IF    p_status_rec.opp_decision_date_flag = FND_API.G_MISS_CHAR
THEN
      v_opp_decision_date_flag := l_opp_decision_date_flag ;
ELSE
      v_opp_decision_date_flag := p_status_rec.opp_decision_date_flag ;
END IF;
IF    p_status_rec.forecast_rollup_flag = FND_API.G_MISS_CHAR
THEN
      v_forecast_rollup_flag := l_forecast_rollup_flag ;
ELSE
      v_forecast_rollup_flag := p_status_rec.forecast_rollup_flag ;
END IF;
IF    p_status_rec.status_rank = FND_API.G_MISS_NUM
THEN
      v_status_rank := l_status_rank;
ELSE
      v_status_rank := p_status_rec.status_rank ;
END IF;
IF    p_status_rec.attribute_category = FND_API.G_MISS_CHAR
THEN
      v_attribute_category := l_attribute_category;
ELSE
      v_attribute_category := p_status_rec.attribute_category;
END IF;
IF    p_status_rec.attribute1 = FND_API.G_MISS_CHAR
THEN
      v_attribute1 := l_attribute1 ;
ELSE
      v_attribute1 := p_status_rec.attribute1;
END IF;
IF    p_status_rec.attribute2 = FND_API.G_MISS_CHAR
THEN
      v_attribute2 := l_attribute2 ;
ELSE
      v_attribute2 := p_status_rec.attribute2;
END IF;
IF   p_status_rec.attribute3 = FND_API.G_MISS_CHAR
THEN
     v_attribute3 := l_attribute3 ;
ELSE
     v_attribute3 := p_status_rec.attribute3 ;
END IF;
IF   p_status_rec.attribute4 = FND_API.G_MISS_CHAR
THEN
     v_attribute4 := l_attribute4 ;
ELSE
     v_attribute4 := p_status_rec.attribute4;
END IF;
IF   p_status_rec.attribute5 = FND_API.G_MISS_CHAR
THEN
     v_attribute5 := l_attribute5 ;
ELSE
     v_attribute5 := p_status_rec.attribute5;
END IF;
IF   p_status_rec.attribute6 = FND_API.G_MISS_CHAR
THEN
     v_attribute6 := l_attribute6 ;
ELSE
     v_attribute6 := p_status_rec.attribute6;
END IF;
IF   p_status_rec.attribute7 = FND_API.G_MISS_CHAR
THEN
     v_attribute7 := l_attribute7 ;
ELSE
     v_attribute7 := p_status_rec.attribute7;
END IF;
IF   p_status_rec.attribute8 = FND_API.G_MISS_CHAR
THEN
     v_attribute8 := l_attribute8 ;
ELSE
     v_attribute8 := p_status_rec.attribute8;
END IF;
IF   p_status_rec.attribute9 = FND_API.G_MISS_CHAR
THEN
     v_attribute9 := l_attribute9 ;
ELSE
     v_attribute9 := p_status_rec.attribute9;
END IF;
IF   p_status_rec.attribute10 = FND_API.G_MISS_CHAR
THEN
     v_attribute10 := l_attribute10 ;
ELSE
     v_attribute10 := p_status_rec.attribute10;
END IF;
IF   p_status_rec.attribute11 = FND_API.G_MISS_CHAR
THEN
     v_attribute11 := l_attribute11 ;
ELSE
     v_attribute11 := p_status_rec.attribute11;
END IF;
IF   p_status_rec.attribute12 = FND_API.G_MISS_CHAR
THEN
     v_attribute12 := l_attribute12 ;
ELSE
     v_attribute12 := p_status_rec.attribute12;
END IF;
IF   p_status_rec.attribute13 = FND_API.G_MISS_CHAR
THEN
     v_attribute13 := l_attribute13 ;
ELSE
     v_attribute13 := p_status_rec.attribute13;
END IF;
IF    p_status_rec.attribute14 = FND_API.G_MISS_CHAR
THEN
     v_attribute14 := l_attribute14 ;
ELSE
     v_attribute14 := p_status_rec.attribute14;
END IF;
IF   p_status_rec.attribute15 = FND_API.G_MISS_CHAR
THEN
     v_attribute15 := l_attribute15 ;
ELSE
     v_attribute15 := p_status_rec.attribute15;
END IF;
IF   p_status_rec.meaning = FND_API.G_MISS_CHAR
THEN
     v_meaning := l_meaning ;
ELSE
     v_meaning := p_status_rec.meaning;
END IF;
IF   p_status_rec.description = FND_API.G_MISS_CHAR
THEN
     v_description := l_description ;
ELSE
     v_description := p_status_rec.description;
END IF;

-- Check to see if values were passed for the who colums
-- if not default them.
IF   p_status_rec.last_update_date = FND_API.G_MISS_DATE
OR   TRIM(p_status_rec.last_update_date) IS NULL
THEN
     l_last_update_date := SYSDATE;
ELSE
     l_last_update_date := p_status_rec.last_update_date ;
END IF;

IF  p_status_rec.last_update_login = FND_API.G_MISS_NUM
OR  TRIM(p_status_rec.last_update_login) IS NULL
THEN
    l_last_update_login := fnd_global.login_id;
ELSE
    l_last_update_login :=  p_status_rec.last_update_login;
END IF;

IF  p_status_rec.last_updated_by = FND_API.G_MISS_NUM
OR  TRIM(p_status_rec.last_updated_by) IS NULL
THEN
    l_last_updated_by := fnd_global.user_id;
ELSE
    l_last_updated_by := p_status_rec.last_updated_by;
END IF;

-- Check for valid values being passed

IF   TRIM(p_status_rec.win_loss_indicator) NOT IN ('W','L', NULL)
THEN
        fnd_message.set_name('AS', 'AS_WIN_IND_INVALID');
        fnd_msg_pub.add;
ELSE
     v_win_loss_indicator:=p_status_rec.win_loss_indicator;
END IF;
IF   v_enabled_flag  NOT IN ('Y','N')
THEN
     fnd_message.set_name('AS', 'AS_ENABLED_FLAG_INVALID');
     fnd_msg_pub.add;
END IF;
IF   v_lead_flag    NOT IN ('Y','N')
THEN
     fnd_message.set_name('AS', 'AS_LEAD_FLAG_INVALID');
     fnd_msg_pub.add;
END IF;
IF   v_opp_flag      NOT IN ('Y','N')
THEN
     fnd_message.set_name('AS', 'AS_OPP_FLAG_INVALID');
     fnd_msg_pub.add;
END IF;
IF   v_opp_decision_date_flag NOT IN ('Y','N')
THEN
     fnd_message.set_name('AS', 'AS_DECISION_FLAG_INVALID');
     fnd_msg_pub.add;
END IF;
IF   v_forecast_rollup_flag   NOT IN ('Y','N')
THEN
     fnd_message.set_name('AS', 'AS_FORECAST_FLAG_INVALID');
     fnd_msg_pub.add;
END IF;

-- if opp_open_status_flag is Y and win_loss_indicator IS NULL else
-- if opp_open_status_flag is N and win_loss_indicator not in W or L
-- then update into as_statuses_b and as_statuses_tl using api.

   IF  NOT    ((v_opp_open_status_flag = 'Y' AND
             TRIM(v_win_loss_indicator) IS NULL)
   OR       (v_opp_open_status_flag ='N' AND
             v_win_loss_indicator IN ('W','L')))
   THEN
             fnd_message.set_name('AS', 'AS_INVALID_WL_STATUS_COMBO');
             fnd_message.set_token('WIN_LOSS_IND',  p_status_rec.win_loss_indicator);
             fnd_msg_pub.add;
   END IF;

   IF (FND_MSG_PUB.COUNT_MSG > 0)
   THEN
      fnd_message.set_name('AS', 'AS_STATUS_UPDATE_FAILED');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
   END IF;

--  Lock the row for update. Check to see if the fetched value is same still.
-- If they are same then update the record else give a message that the row has been
-- updated by others.

   OPEN   lock_row_for_update(TRIM(NLS_UPPER(p_status_rec.status_code)));
   FETCH  lock_row_for_update INTO  l_current_last_update_date;
   IF     lock_row_for_update%NOTFOUND
   THEN
          CLOSE  lock_row_for_update;
          RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   IF l_last_update_date <> l_current_last_update_date
   THEN
          fnd_message.set_name('AS', 'AS_RECORD_UPDATED');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
   END IF;

   AS_STATUSES_PKG.UPDATE_ROW(
              p_status_rec.status_code,
              v_enabled_flag,
              v_lead_flag,
              v_opp_flag,
              v_opp_open_status_flag,
              v_opp_decision_date_flag,
              v_status_rank,
              v_forecast_rollup_flag,
              v_win_loss_indicator,
              NULL,
              v_attribute_category,
              v_attribute1,
              v_attribute2,
              v_attribute3,
              v_attribute4,
              v_attribute5,
              v_attribute6,
              v_attribute7,
              v_attribute8,
              v_attribute9,
              v_attribute10,
              v_attribute11,
              v_attribute12,
              v_attribute13,
              v_attribute14,
              v_attribute15,
              v_meaning,
              v_description,
              l_last_update_date,
              l_last_updated_by,
              l_last_update_login);


-- Standard Check for p_commit
   IF fnd_api.to_boolean (p_commit)
   THEN
       COMMIT WORK;
   END IF;

-- Close all opened cursors
   CLOSE  get_update_row_cur;   -- closed after update...
   CLOSE  lock_row_for_update ;


-- Standard call to get message count and if count is 1, get message infor.
   fnd_msg_pub.count_and_get(
       p_count  =>  x_msg_count,
       p_data   =>  x_msg_data
   );

-- Handling all Exceptions
EXCEPTION
    WHEN fnd_api.g_exc_error THEN
    ROLLBACK TO update_status;
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_msg_pub.count_and_get (
        p_count => x_msg_count,
        p_data  => x_msg_data
    );
    WHEN fnd_api.g_exc_unexpected_error THEN
    ROLLBACK TO update_status;
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.count_and_get (
        p_count => x_msg_count,
        p_data  => x_msg_data
    );
    WHEN OTHERS THEN
    ROLLBACK TO update_status;
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.count_and_get (
        p_count => x_msg_count,
        p_data  => x_msg_data
    );

END update_status;
END as_status_pub;

/
