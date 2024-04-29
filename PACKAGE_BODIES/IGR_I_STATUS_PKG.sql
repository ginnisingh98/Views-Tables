--------------------------------------------------------
--  DDL for Package Body IGR_I_STATUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGR_I_STATUS_PKG" AS
/* $Header: IGSRH07B.pls 120.1 2006/01/11 23:45:24 rghosh noship $ */

PROCEDURE update_row (
  X_S_ENQUIRY_STATUS in VARCHAR2,
  X_ENQUIRY_STATUS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  x_ret_status OUT NOCOPY VARCHAR2,
  x_msg_data OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER
  ) AS

l_last_update_date                 DATE;
l_enabled_flag                     VARCHAR2(1);
l_lead_flag                        VARCHAR2(1);
l_opp_flag                         VARCHAR2(1);
l_opp_open_status_flag             VARCHAR2(1);
l_opp_decision_date_flag           VARCHAR2(1);
l_forecast_rollup_flag             VARCHAR2(1);
l_win_loss_indicator               VARCHAR2(1);
l_attribute_category               VARCHAR2(30);
l_attribute1                       VARCHAR2(150);
l_attribute2                       VARCHAR2(150);
l_attribute3                       VARCHAR2(150);
l_attribute4                       VARCHAR2(150);
l_attribute5                       VARCHAR2(150);
l_attribute6                       VARCHAR2(150);
l_attribute7                       VARCHAR2(150);
l_attribute8                       VARCHAR2(150);
l_attribute9                       VARCHAR2(150);
l_attribute10                      VARCHAR2(150);
l_attribute11                      VARCHAR2(150);
l_attribute12                      VARCHAR2(150);
l_attribute13                      VARCHAR2(150);
l_attribute14                      VARCHAR2(150);
l_attribute15                      VARCHAR2(150);
l_meaning                          VARCHAR2(240);
l_description                      VARCHAR2(240);
v_description                      VARCHAR2(240);
l_status_rank                      NUMBER;
l_status_code                      AS_STATUSES_B.status_code%TYPE;
v_enquiry_status                   VARCHAR2(240);
l_last_updated_by                  NUMBER(15);
l_last_update_login                NUMBER(15);


CURSOR c_get_status IS
  SELECT last_update_date,
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
  FROM as_statuses_vl
  WHERE status_code = x_s_enquiry_status;


BEGIN

  -- Standard start of api save point

  SAVEPOINT update_row_status;

  -- Initialize api return status

  x_ret_status := fnd_api.g_ret_sts_success;


  -- Fetch all the column values into local variables from the database
  -- and pass these values, if they are not changed, in the AS_STATUSES_PKG.UPDATE_ROW call

  OPEN c_get_status;
  FETCH  c_get_status
  INTO    l_last_update_date,
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

  CLOSE c_get_status;

  -- In the update row call, need to pass the system enquiry status as the status code
  -- Since the system enquiry status parameter cannot be null, hence we dont need to handle the
  -- null condition here
  l_status_code := x_s_enquiry_status;

  -- If the enquiry status parameter is null, then pass the value from the database
  IF x_enquiry_status IS NULL THEN
     v_enquiry_status := l_meaning;
  ELSE
     v_enquiry_status := x_enquiry_status;
  END IF;

  -- If the description parameter is null, then pass the value from the database
  IF x_description IS NULL THEN
    v_description := l_description;
  ELSE
    v_description := x_description;
  END IF;

  -- If the enabled flag is null in the database, update it to 'Y'.
  IF l_enabled_flag IS NULL THEN
     l_enabled_flag := 'Y';
  END IF;

  -- If the lead flag is null in the database, update it to 'N'.
  IF l_lead_flag IS NULL THEN
     l_lead_flag := 'N';
  END IF;

  -- If the l_opp_flag is null in the database, update it to 'N'.
  IF l_opp_flag IS NULL THEN
     l_opp_flag := 'N';
  END IF;

  -- If the l_opp_open_status_flag is null in the database, update it to 'N'.
  IF l_opp_open_status_flag IS NULL THEN
     l_opp_open_status_flag := 'N';
  END IF;

  -- If the l_opp_decision_date_flag is null in the database, update it to 'N'.
  IF l_opp_decision_date_flag IS NULL THEN
     l_opp_decision_date_flag := 'N';
  END IF;

  -- If the l_forecast_rollup_flag is null in the database, update it to 'N'.
  IF l_forecast_rollup_flag IS NULL THEN
     l_forecast_rollup_flag := 'N';
  END IF;

  -- If the l_win_loss_indicator is null in the database, update it to 'N'.
  IF l_win_loss_indicator IS NULL THEN
     l_win_loss_indicator := 'N';
  END IF;


  -- populate the last_updated_by and last_update_login fields.
  l_last_updated_by := fnd_global.user_id;
  l_last_update_login := fnd_global.login_id;

  -- calling the update_row API to update the statuses.
  AS_STATUSES_PKG.UPDATE_ROW(
              l_status_code,
              l_enabled_flag,
              l_lead_flag,
              l_opp_flag,
              l_opp_open_status_flag,
              l_opp_decision_date_flag,
              l_status_rank,
              l_forecast_rollup_flag,
              l_win_loss_indicator,
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
              v_enquiry_status,
              v_description,
              l_last_update_date,
              l_last_updated_by,
              l_last_update_login);

EXCEPTION
    -- Exception Handling
    WHEN OTHERS THEN
    ROLLBACK TO update_row_status;
    x_ret_status := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.count_and_get (
        p_count => x_msg_count,
        p_data  => x_msg_data
    );

END update_row;
END igr_i_status_pkg;

/
