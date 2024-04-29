--------------------------------------------------------
--  DDL for Package Body CN_PREPOSTDETAILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PREPOSTDETAILS" AS
-- $Header: cntpdetb.pls 115.8 2002/01/28 20:05:02 pkm ship    $ --+

G_PKG_NAME       CONSTANT VARCHAR2(30) := 'CN_PREPOSTDETAILS';
G_LAST_UPDATE_DATE        DATE         := SYSDATE;
G_LAST_UPDATED_BY         NUMBER       := FND_GLOBAL.USER_ID;
G_CREATION_DATE           DATE         := SYSDATE;
G_CREATED_BY              NUMBER       := FND_GLOBAL.USER_ID;
G_LAST_UPDATE_LOGIN       NUMBER       := FND_GLOBAL.LOGIN_ID;
-- ----------------------------------------------------------------------------+
--
--  Procedure      : Get_UID
--  Description    : Get the sequence number to create a new posting detail
--
-- ----------------------------------------------------------------------------+
PROCEDURE Get_UID( x_posting_detail_id  IN OUT NUMBER )
IS
   CURSOR get_id IS
   SELECT cn_posting_details_s.nextval
     FROM   dual;
BEGIN
   OPEN  get_id;
   FETCH get_id INTO x_posting_detail_id;
   CLOSE get_id;
END Get_UID;
-- ----------------------------------------------------------------------------+
--
--  Procedure      : Insert_Record
--  Description    : Main insert procedure
--  Calls          :
--
-- ----------------------------------------------------------------------------+
PROCEDURE Insert_Record
  (x_rowid                     IN OUT      VARCHAR2,
   x_posting_detail_id         IN OUT      NUMBER,
   x_posting_batch_id                      NUMBER,
   x_posting_type                          VARCHAR2,
   x_trx_type                              VARCHAR2,
   x_payee_salesrep_id                     NUMBER,
   x_role_id                               NUMBER,
   x_incentive_type_code                   VARCHAR2,
   x_credit_type_id                        NUMBER,
   x_pay_period_id                         NUMBER,
   x_amount                                NUMBER,
   x_commission_header_id                  NUMBER,
   x_commission_line_id                    NUMBER,
   x_srp_plan_assign_id                    NUMBER,
   x_quota_id                              NUMBER,
   x_status                                VARCHAR2,
   x_loaded_date                           DATE,
   x_processed_date                        DATE,
   x_credited_salesrep_id                  NUMBER,
   x_processed_period_id                   NUMBER,
   x_quota_rule_id                         NUMBER,
   x_event_factor                          NUMBER,
   x_payment_factor                        NUMBER,
   x_quota_factor                          NUMBER,
   x_pending_status                        VARCHAR2,
   x_input_achieved                        NUMBER,
   x_rate_tier_id                          NUMBER,
   x_payee_line_id                         NUMBER,
   x_cl_status                             VARCHAR2,
   x_created_during                        VARCHAR2,
   x_commission_rate                       NUMBER,
   x_hold_flag                             VARCHAR2,
   x_paid_flag                             VARCHAR2,
   x_payment_amount                        NUMBER,
   x_attribute_category                    VARCHAR2,
   x_attribute1                            VARCHAR2,
   x_attribute2                            VARCHAR2,
   x_attribute3                            VARCHAR2,
   x_attribute4                            VARCHAR2,
   x_attribute5                            VARCHAR2,
   x_attribute6                            VARCHAR2,
   x_attribute7                            VARCHAR2,
   x_attribute8                            VARCHAR2,
   x_attribute9                            VARCHAR2,
   x_attribute10                           VARCHAR2,
   x_attribute11                           VARCHAR2,
   x_attribute12                           VARCHAR2,
   x_attribute13                           VARCHAR2,
   x_attribute14                           VARCHAR2,
   x_attribute15                           VARCHAR2,
   x_last_update_date                      DATE,
   x_last_updated_by                       NUMBER,
   x_last_update_login                     NUMBER,
   x_creation_date                         DATE,
   x_created_by                            NUMBER)
  IS
     l_api_name            CONSTANT VARCHAR2(30) := 'Insert_Record';
     l_loading_status               VARCHAR2(30) := 'CN_INSERTED';
     l_return_status                VARCHAR2(30) := FND_API.G_RET_STS_SUCCESS;
BEGIN
   --dbms_output.put_line('before get UID ');
   -- Get Unique ID for posting detail
   Get_UID( x_posting_detail_id );
   --dbms_output.put_line('after get UID and ID is '||to_char(x_posting_detail_id));

   -- several fields (including the attributes) might have G_MISS values
   -- these fields are the hold, paid flag and payment amount(to have defaults)
   -- and status and loaded date used in update (along with attributes)

   INSERT INTO cn_posting_details
     (posting_detail_id,
      posting_batch_id,
      posting_type,
      trx_type,
      payee_salesrep_id,
      role_id,
      incentive_type_code,
      credit_type_id,
      pay_period_id,
      amount,
      commission_header_id,
      commission_line_id,
      srp_plan_assign_id,
      quota_id,
      status,
      loaded_date,
      processed_date,
      credited_salesrep_id,
      processed_period_id,
      quota_rule_id,
      event_factor,
      payment_factor,
      quota_factor,
      pending_status,
      input_achieved,
      rate_tier_id,
      payee_line_id,
      cl_status,
      created_during,
      commission_rate,
      hold_flag,
      paid_flag,
      payment_amount,
      attribute_category,
      attribute1      ,
      attribute2      ,
      attribute3      ,
      attribute4      ,
      attribute5      ,
      attribute6      ,
      attribute7      ,
      attribute8      ,
      attribute9      ,
      attribute10      ,
      attribute11      ,
      attribute12      ,
      attribute13      ,
      attribute14      ,
      attribute15      ,
      last_update_date,
      last_updated_by,
      last_update_login,
      creation_date,
      created_by)
     (SELECT
      x_posting_detail_id,
      x_posting_batch_id,
      x_posting_type,
      x_trx_type,
      x_payee_salesrep_id,
      x_role_id,
      x_incentive_type_code,
      x_credit_type_id,
      x_pay_period_id,
      x_amount,
      x_commission_header_id,
      x_commission_line_id,
      x_srp_plan_assign_id,
      x_quota_id,
      decode(x_status,        FND_API.G_MISS_CHAR, 'UNLOADED', x_status),
      decode(x_loaded_date,   FND_API.G_MISS_CHAR, null,       x_loaded_date),
      x_processed_date,
      x_credited_salesrep_id,
      x_processed_period_id,
      x_quota_rule_id,
      x_event_factor,
      x_payment_factor,
      x_quota_factor,
      x_pending_status,
      x_input_achieved,
      x_rate_tier_id,
      x_payee_line_id,
      x_cl_status,
      x_created_during,
      x_commission_rate,
      decode(x_hold_flag,      FND_API.G_MISS_CHAR, 'N', x_hold_flag),
      decode(x_paid_flag,      FND_API.G_MISS_CHAR, 'N', x_paid_flag),
      decode(x_payment_amount, FND_API.G_MISS_NUM, x_amount, x_payment_amount),
     decode(x_attribute_category, FND_API.G_MISS_CHAR, null, x_attribute_category),
     decode(x_attribute1,  FND_API.G_MISS_CHAR, null, x_attribute1),
     decode(x_attribute2,  FND_API.G_MISS_CHAR, null, x_attribute2),
     decode(x_attribute3,  FND_API.G_MISS_CHAR, null, x_attribute3),
     decode(x_attribute4,  FND_API.G_MISS_CHAR, null, x_attribute4),
     decode(x_attribute5,  FND_API.G_MISS_CHAR, null, x_attribute5),
     decode(x_attribute6,  FND_API.G_MISS_CHAR, null, x_attribute6),
     decode(x_attribute7,  FND_API.G_MISS_CHAR, null, x_attribute7),
     decode(x_attribute8,  FND_API.G_MISS_CHAR, null, x_attribute8),
     decode(x_attribute9,  FND_API.G_MISS_CHAR, null, x_attribute9),
     decode(x_attribute10, FND_API.G_MISS_CHAR, null, x_attribute10),
     decode(x_attribute11, FND_API.G_MISS_CHAR, null, x_attribute11),
     decode(x_attribute12, FND_API.G_MISS_CHAR, null, x_attribute12),
     decode(x_attribute13, FND_API.G_MISS_CHAR, null, x_attribute13),
     decode(x_attribute14, FND_API.G_MISS_CHAR, null, x_attribute14),
     decode(x_attribute15, FND_API.G_MISS_CHAR, null, x_attribute15),
     G_LAST_UPDATE_DATE,
     G_LAST_UPDATED_BY,
     G_LAST_UPDATE_LOGIN,
     G_CREATION_DATE,
     G_CREATED_BY
     FROM DUAL);
END Insert_Record;

-- ----------------------------------------------------------------------------+
--
--  Procedure      : Lock_Record
--  Description    : Main lock procedure
--                   lock db row after form record is changed
--  Note           : Only called from the form.
--
-- ----------------------------------------------------------------------------+
PROCEDURE Lock_Record
  (x_rowid                                    VARCHAR2,
   x_posting_detail_id                        NUMBER)
  IS
     l_api_name                  CONSTANT VARCHAR2(30)      := 'Lock_Record';
     CURSOR c IS
     SELECT *
       FROM   cn_posting_details
      WHERE  posting_detail_id = x_posting_detail_id
      FOR UPDATE OF posting_detail_id NOWAIT;
   RecInfo c%ROWTYPE;
BEGIN
   OPEN  c;
   FETCH c INTO RecInfo;
   IF c%NOTFOUND THEN
      CLOSE c;
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
   CLOSE c;
   IF RecInfo.posting_detail_id = x_posting_detail_id THEN
      RETURN;
   ELSE
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Record;

-- ----------------------------------------------------------------------------+
--
--  Procedure      : Update_Record
--  Description    : Main update procedure to update posting details
--  Notes          : Only update status and loaded date
--
-- ----------------------------------------------------------------------------+
PROCEDURE Update_Record
  (x_rowid                              VARCHAR2,
   x_posting_detail_id                  NUMBER,
   x_status                             VARCHAR2,
   x_loaded_date                        DATE,
   x_attribute_category                 VARCHAR2,
   x_attribute1                         VARCHAR2,
   x_attribute2                         VARCHAR2,
   x_attribute3                         VARCHAR2,
   x_attribute4                         VARCHAR2,
   x_attribute5                         VARCHAR2,
   x_attribute6                         VARCHAR2,
   x_attribute7                         VARCHAR2,
   x_attribute8                         VARCHAR2,
   x_attribute9                         VARCHAR2,
   x_attribute10                        VARCHAR2,
   x_attribute11                        VARCHAR2,
   x_attribute12                        VARCHAR2,
   x_attribute13                        VARCHAR2,
   x_attribute14                        VARCHAR2,
   x_attribute15                        VARCHAR2,
   x_last_update_date                   DATE,
   x_last_updated_by                    NUMBER,
   x_last_update_login                  NUMBER)
  IS
     l_api_name                  CONSTANT VARCHAR2(30)      := 'Update_Record';
     CURSOR c is
     SELECT status,
            loaded_date,
            attribute_category,
            attribute1,  attribute2,  attribute3,  attribute4,  attribute5,
            attribute6,  attribute7,  attribute8,  attribute9,  attribute10,
            attribute11, attribute12, attribute13, attribute14, attribute15
       FROM cn_posting_details
      WHERE posting_detail_id = x_posting_detail_id;
     l_oldrec c%rowtype;
BEGIN
   open  c;
   fetch c into l_oldrec;
   close c;

   UPDATE cn_posting_details SET
     status                    = decode(x_status, FND_API.G_MISS_CHAR,
					l_oldrec.status, x_status),
     loaded_date               = decode(x_loaded_date, FND_API.G_MISS_DATE,
					l_oldrec.loaded_date, x_loaded_date),
     attribute_category        = decode(x_attribute_category,
					FND_API.G_MISS_CHAR,
					l_oldrec.attribute_category,
					x_attribute_category),
     attribute1                = decode(x_attribute1, FND_API.G_MISS_CHAR,
					l_oldrec.attribute1, x_attribute1),
     attribute2                = decode(x_attribute2, FND_API.G_MISS_CHAR,
					l_oldrec.attribute2, x_attribute2),
     attribute3                = decode(x_attribute3, FND_API.G_MISS_CHAR,
					l_oldrec.attribute3, x_attribute3),
     attribute4                = decode(x_attribute4, FND_API.G_MISS_CHAR,
					l_oldrec.attribute4, x_attribute4),
     attribute5                = decode(x_attribute5, FND_API.G_MISS_CHAR,
					l_oldrec.attribute5, x_attribute5),
     attribute6                = decode(x_attribute6, FND_API.G_MISS_CHAR,
					l_oldrec.attribute6, x_attribute6),
     attribute7                = decode(x_attribute7, FND_API.G_MISS_CHAR,
					l_oldrec.attribute7, x_attribute7),
     attribute8                = decode(x_attribute8, FND_API.G_MISS_CHAR,
					l_oldrec.attribute8, x_attribute8),
     attribute9                = decode(x_attribute9, FND_API.G_MISS_CHAR,
					l_oldrec.attribute9, x_attribute9),
     attribute10               = decode(x_attribute10, FND_API.G_MISS_CHAR,
					l_oldrec.attribute10, x_attribute10),
     attribute11               = decode(x_attribute11, FND_API.G_MISS_CHAR,
					l_oldrec.attribute11, x_attribute11),
     attribute12               = decode(x_attribute12, FND_API.G_MISS_CHAR,
					l_oldrec.attribute12, x_attribute12),
     attribute13               = decode(x_attribute13, FND_API.G_MISS_CHAR,
					l_oldrec.attribute13, x_attribute13),
     attribute14               = decode(x_attribute14, FND_API.G_MISS_CHAR,
					l_oldrec.attribute14, x_attribute14),
     attribute15               = decode(x_attribute15, FND_API.G_MISS_CHAR,
					l_oldrec.attribute15, x_attribute15),
     last_update_date          = G_LAST_UPDATE_DATE,
     last_updated_by           = G_LAST_UPDATED_BY,
     last_update_login         = G_LAST_UPDATE_LOGIN;
END Update_Record;
-- ----------------------------------------------------------------------------+
--
--  Procedure      : Begin_Record
--  Description    : This PRIVATE table handler procedure calls the
--                   appropriate private procedures depending on the value of
--                   X_Operation.
--  Calls          :
--
--  Notes          :
--
--
-- ----------------------------------------------------------------------------+
PROCEDURE Begin_Record
  (x_operation              IN       VARCHAR2,
   x_rowid                  IN OUT   VARCHAR2,
   x_posting_detail_rec     IN OUT   posting_detail_rec_type,
   x_program_type           IN       VARCHAR2)
  IS
     l_api_name               CONSTANT VARCHAR2(30)      := 'Begin_Record';
     l_api_version            CONSTANT NUMBER            := 1.0;
BEGIN
   IF x_operation = 'INSERT' THEN
      --dbms_output.put_line('in API about to call TH ');
      Insert_Record
	(x_rowid,
	 x_posting_detail_rec.posting_detail_id,
	 x_posting_detail_rec.posting_batch_id,
	 x_posting_detail_rec.posting_type,
	 x_posting_detail_rec.trx_type,
	 x_posting_detail_rec.payee_salesrep_id,
	 x_posting_detail_rec.role_id,
	 x_posting_detail_rec.incentive_type_code,
	 x_posting_detail_rec.credit_type_id,
	 x_posting_detail_rec.pay_period_id,
	 x_posting_detail_rec.amount,
	 x_posting_detail_rec.commission_header_id,
	 x_posting_detail_rec.commission_line_id,
	 x_posting_detail_rec.srp_plan_assign_id,
	 x_posting_detail_rec.quota_id,
	 x_posting_detail_rec.status,
	 x_posting_detail_rec.loaded_date,
	 x_posting_detail_rec.processed_date,
	 x_posting_detail_rec.credited_salesrep_id,
	 x_posting_detail_rec.processed_period_id,
	 x_posting_detail_rec.quota_rule_id,
	 x_posting_detail_rec.event_factor,
	 x_posting_detail_rec.payment_factor,
	 x_posting_detail_rec.quota_factor,
	 x_posting_detail_rec.pending_status,
	 x_posting_detail_rec.input_achieved,
	 x_posting_detail_rec.rate_tier_id,
	 x_posting_detail_rec.payee_line_id,
	 x_posting_detail_rec.cl_status,
         x_posting_detail_rec.created_during,
	 x_posting_detail_rec.commission_rate,
	 x_posting_detail_rec.hold_flag,
	 x_posting_detail_rec.paid_flag,
	 x_posting_detail_rec.payment_amount,
         x_posting_detail_rec.attribute_category,
         x_posting_detail_rec.attribute1      ,
         x_posting_detail_rec.attribute2      ,
         x_posting_detail_rec.attribute3      ,
         x_posting_detail_rec.attribute4      ,
         x_posting_detail_rec.attribute5      ,
         x_posting_detail_rec.attribute6      ,
         x_posting_detail_rec.attribute7      ,
         x_posting_detail_rec.attribute8      ,
         x_posting_detail_rec.attribute9      ,
         x_posting_detail_rec.attribute10      ,
         x_posting_detail_rec.attribute11      ,
         x_posting_detail_rec.attribute12      ,
         x_posting_detail_rec.attribute13      ,
         x_posting_detail_rec.attribute14      ,
         x_posting_detail_rec.attribute15      ,
         x_posting_detail_rec.last_update_date,
         x_posting_detail_rec.last_updated_by,
         x_posting_detail_rec.last_update_login,
         x_posting_detail_rec.creation_date,
	 x_posting_detail_rec.created_by);

      --dbms_output.put_line('in API after TH ');
    ELSIF x_operation = 'UPDATE' THEN
      Update_Record
	(x_rowid,
	 x_posting_detail_rec.posting_detail_id,
	 x_posting_detail_rec.status,
	 x_posting_detail_rec.loaded_date,
	 x_posting_detail_rec.attribute_category,
	 x_posting_detail_rec.attribute1      ,
	 x_posting_detail_rec.attribute2      ,
	 x_posting_detail_rec.attribute3      ,
	 x_posting_detail_rec.attribute4      ,
	 x_posting_detail_rec.attribute5      ,
	 x_posting_detail_rec.attribute6      ,
	 x_posting_detail_rec.attribute7      ,
	 x_posting_detail_rec.attribute8      ,
	 x_posting_detail_rec.attribute9      ,
	 x_posting_detail_rec.attribute10      ,
	 x_posting_detail_rec.attribute11      ,
	 x_posting_detail_rec.attribute12      ,
	 x_posting_detail_rec.attribute13      ,
	 x_posting_detail_rec.attribute14      ,
	 x_posting_detail_rec.attribute15      ,
	 x_posting_detail_rec.last_update_date,
	 x_posting_detail_rec.last_updated_by,
	 x_posting_detail_rec.last_update_login);
    ELSIF x_operation = 'LOCK' THEN
      Lock_Record
	(x_rowid,
	 x_posting_detail_rec.posting_detail_id);
   END IF;
END Begin_Record;
END CN_PREPOSTDETAILS;

/
