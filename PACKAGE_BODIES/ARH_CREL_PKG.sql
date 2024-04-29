--------------------------------------------------------
--  DDL for Package Body ARH_CREL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARH_CREL_PKG" as
/* $Header: ARHCRELB.pls 120.6 2005/06/16 21:09:58 jhuang ship $*/

  FUNCTION INIT_SWITCH
  ( p_date   IN DATE,
    p_switch IN VARCHAR2 DEFAULT 'NULL_GMISS')
  RETURN DATE
  IS
   res_date date;
  BEGIN
   IF    p_switch = 'NULL_GMISS' THEN
     IF p_date IS NULL THEN
       res_date := FND_API.G_MISS_DATE;
     ELSE
       res_date := p_date;
     END IF;
   ELSIF p_switch = 'GMISS_NULL' THEN
     IF p_date = FND_API.G_MISS_DATE THEN
       res_date := NULL;
     ELSE
       res_date := p_date;
     END IF;
   ELSE
     res_date := TO_DATE('31/12/1800','DD/MM/RRRR');
   END IF;
   RETURN res_date;
  END;

  FUNCTION INIT_SWITCH
  ( p_char   IN VARCHAR2,
    p_switch IN VARCHAR2 DEFAULT 'NULL_GMISS')
  RETURN VARCHAR2
  IS
   res_char varchar2(2000);
  BEGIN
   IF    p_switch = 'NULL_GMISS' THEN
     IF p_char IS NULL THEN
       return FND_API.G_MISS_CHAR;
     ELSE
       return p_char;
     END IF;
   ELSIF p_switch = 'GMISS_NULL' THEN
     IF p_char = FND_API.G_MISS_CHAR THEN
       return NULL;
     ELSE
       return p_char;
     END IF;
   ELSE
     return ('INCORRECT_P_SWITCH');
   END IF;
  END;

  FUNCTION INIT_SWITCH
  ( p_num   IN NUMBER,
    p_switch IN VARCHAR2 DEFAULT 'NULL_GMISS')
  RETURN NUMBER
  IS
  BEGIN
   IF    p_switch = 'NULL_GMISS' THEN
     IF p_num IS NULL THEN
       return FND_API.G_MISS_NUM;
     ELSE
       return p_num;
     END IF;
   ELSIF p_switch = 'GMISS_NULL' THEN
     IF p_num = FND_API.G_MISS_NUM THEN
       return NULL;
     ELSE
       return p_num;
     END IF;
   ELSE
     return ('9999999999');
   END IF;
  END;

  PROCEDURE object_version_select
  (p_table_name                  IN VARCHAR2,
   p_col_id                      IN VARCHAR2,
   p_col_id2                     IN VARCHAR2,
   x_rowid                       IN OUT NOCOPY ROWID,
   x_object_version_number       IN OUT NOCOPY NUMBER,
   x_last_update_date            IN OUT NOCOPY DATE,
   x_id_value                    IN OUT NOCOPY NUMBER,
   x_return_status               IN OUT NOCOPY VARCHAR2,
   x_msg_count                   IN OUT NOCOPY NUMBER,
   x_msg_data                    IN OUT NOCOPY VARCHAR2 )
  IS
     CURSOR cu_cust_relate_version IS
        SELECT ROWID,
               OBJECT_VERSION_NUMBER,
               LAST_UPDATE_DATE
          FROM HZ_CUST_ACCT_RELATE
         WHERE CUST_ACCOUNT_ID         = p_col_id
           AND RELATED_CUST_ACCOUNT_ID = p_col_Id2;

    l_last_update_date   DATE;
  BEGIN

    IF p_table_name = 'HZ_CUST_ACCT_RELATE' THEN
         OPEN cu_cust_relate_version;
         FETCH cu_cust_relate_version INTO
           x_rowid                ,
           x_object_version_number,
           l_last_update_date     ;
         CLOSE cu_cust_relate_version;
    END IF;

    IF x_rowid IS NULL THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
        FND_MESSAGE.SET_TOKEN( 'RECORD', p_table_name);
        FND_MESSAGE.SET_TOKEN( 'VALUE',
                NVL( p_col_id , 'null' ) || ',' ||
                NVL( p_col_id2, 'null' ) );
        FND_MSG_PUB.ADD;
     ELSE
     IF TO_CHAR(x_last_update_date,'DD-MON-YYYY HH:MI:SS') <>
        TO_CHAR(l_last_update_date,'DD-MON-YYYY HH:MI:SS')
     THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
        FND_MESSAGE.SET_TOKEN('TABLE', p_table_name);
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
   END IF;
  END;

  PROCEDURE  check_unique(x_customer_id in number ,x_related_customer_id in number ) is
  --
  duplicate_count number(15);
  --
  begin
	select count(1)
        into    duplicate_count
	from   hz_cust_acct_relate
	where  cust_account_id		= x_customer_id
	and    related_cust_account_id	= x_related_customer_id
        and    status = 'A';		--Bug Fix: 3237327

	if (duplicate_count >= 1 ) then
		fnd_message.set_name('AR','AR_CUST_REL_ALREADY_EXISTS');
		app_exception.raise_exception;
	end if;
  end check_unique;
  --
  --
  PROCEDURE Insert_Row(
                       X_Created_By                     NUMBER,
                       X_Creation_Date                  DATE,
                       X_Customer_Id                    NUMBER,
                       X_Customer_Reciprocal_Flag       VARCHAR2,
		       X_relationship_type		VARCHAR2,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Related_Customer_Id            NUMBER,
                       X_Status                         VARCHAR2,
                       X_Comments                       VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                      X_BILL_TO_FLAG                    VARCHAR2,
                       X_SHIP_TO_FLAG                    VARCHAR2,
                        x_return_status                 out NOCOPY varchar2,
                        x_msg_count                     out NOCOPY number,
                        x_msg_data                      out NOCOPY varchar2

  ) IS

--cust_rel_rec      HZ_cust_acct_info_pub.cust_acct_relate_rec_type;
  cust_rel_rec      HZ_CUST_ACCOUNT_V2PUB.cust_acct_relate_rec_type;

tmp_var                VARCHAR2(2000);
i                      number;
tmp_var1                VARCHAR2(2000);

   --
BEGIN
       --
       check_unique(x_customer_id,x_related_customer_id);

       cust_rel_rec.cust_account_id               := X_Customer_Id;
       cust_rel_rec.related_cust_account_id       := X_Related_Customer_Id;
       cust_rel_rec.relationship_type             := X_relationship_type;
       cust_rel_rec.status                        := x_status;
       cust_rel_rec.comments                      := x_comments;
       cust_rel_rec.Customer_Reciprocal_Flag      := X_Customer_Reciprocal_Flag;
       cust_rel_rec.attribute_category            := x_attribute_category;
       cust_rel_rec.attribute1                    := x_attribute1;
       cust_rel_rec.attribute2                    := x_attribute2;
       cust_rel_rec.attribute3                    := x_attribute3;
       cust_rel_rec.attribute4                    := x_attribute4;
       cust_rel_rec.attribute5                    := x_attribute5;
       cust_rel_rec.attribute6                    := x_attribute6;
       cust_rel_rec.attribute7                    := x_attribute7;
       cust_rel_rec.attribute8                    := x_attribute8;
       cust_rel_rec.attribute9                    := x_attribute9;
       cust_rel_rec.attribute10                   := x_attribute10;
       cust_rel_rec.attribute11                   := x_attribute11;
       cust_rel_rec.attribute12                   := x_attribute12;
       cust_rel_rec.attribute13                   := x_attribute13;
       cust_rel_rec.attribute14                   := x_attribute14;
       cust_rel_rec.attribute15                   := x_attribute15;
       cust_rel_rec.BILL_TO_FLAG                   := x_BILL_TO_FLAG;
       cust_rel_rec.SHIP_TO_FLAG                   := x_SHIP_TO_FLAG;
       cust_rel_rec.created_by_module             := 'TCA_FORM_WRAPPER';

/*
                HZ_cust_acct_info_pub.create_cust_acct_relate(
                1,
                null,
                null,
                cust_rel_rec,
                x_return_status,
                x_msg_count,
                x_msg_data);
*/

    -- call V2 API.
    HZ_CUST_ACCOUNT_V2PUB.create_cust_acct_relate (
        p_cust_acct_relate_rec              => cust_rel_rec,
        x_return_status                     => x_return_status,
        x_msg_count                         => x_msg_count,
        x_msg_data                          => x_msg_data
    );

   IF x_msg_count > 1 THEN
     FOR i IN 1..x_msg_count  LOOP
       tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
       tmp_var1 := tmp_var1 || ' '|| tmp_var;
     END LOOP;
     x_msg_data := tmp_var1;
   END IF;

END Insert_Row;



PROCEDURE Update_Row(
                       X_Customer_Id                    NUMBER,
                       X_Customer_Reciprocal_Flag       VARCHAR2,
		       X_relationship_type		VARCHAR2,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date        IN OUT       NOCOPY DATE,
                       X_Related_Customer_Id            NUMBER,
                       X_Status                         VARCHAR2,
                       X_Comments                       VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_BILL_TO_FLAG                    VARCHAR2,
                       X_SHIP_TO_FLAG                    VARCHAR2,
                       x_return_status                 out NOCOPY varchar2,
                       x_msg_count                     out NOCOPY number,
                       x_msg_data                      out NOCOPY varchar2,
                       x_object_version                 IN  NUMBER DEFAULT -1,
                       X_Row_Id		                    IN ROWID DEFAULT NULL  --Bug Fix:3237327

  ) IS

--cust_rel_rec      hz_cust_acct_info_pub.cust_acct_relate_rec_type;
  cust_rel_rec       HZ_CUST_ACCOUNT_V2PUB.cust_acct_relate_rec_type;
  tmp_var            VARCHAR2(2000);
  i                  number;
  tmp_var1           VARCHAR2(2000);
  l_object_version   NUMBER;
  l_rowid            ROWID;
  l_last_update_date DATE;
  l_dummy            NUMBER;

BEGIN
   l_object_version  := x_object_version;
   IF l_object_version = -1 THEN
       object_version_select
           (p_table_name                  => 'HZ_CUST_ACCT_RELATE',
            p_col_id                      => X_customer_id,
            p_col_id2                     => X_Related_Customer_Id,
            x_rowid                       => l_rowid,
            x_object_version_number       => l_object_version,
            x_last_update_date            => l_last_update_date,
            x_id_value                    => l_dummy,
            x_return_status               => x_return_status,
            x_msg_count                   => x_msg_count,
            x_msg_data                    => x_msg_data );

        IF x_msg_count > 1 THEN
           FOR i IN 1..x_msg_count  LOOP
            tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
            tmp_var1 := tmp_var1 || ' '|| tmp_var;
           END LOOP;
           x_msg_data := tmp_var1;
        END IF;

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           return;
        END IF;

    END IF;

   cust_rel_rec.cust_account_id               := X_Customer_Id;
   cust_rel_rec.related_cust_account_id       := INIT_SWITCH(X_Related_Customer_Id);
   cust_rel_rec.status                        := INIT_SWITCH(x_status);
   cust_rel_rec.comments                      := INIT_SWITCH(x_comments);
   cust_rel_rec.attribute_category            := INIT_SWITCH(x_attribute_category);
   cust_rel_rec.attribute1                    := INIT_SWITCH(x_attribute1);
   cust_rel_rec.attribute2                    := INIT_SWITCH(x_attribute2);
   cust_rel_rec.attribute3                    := INIT_SWITCH(x_attribute3);
   cust_rel_rec.attribute4                    := INIT_SWITCH(x_attribute4);
   cust_rel_rec.attribute5                    := INIT_SWITCH(x_attribute5);
   cust_rel_rec.attribute6                    := INIT_SWITCH(x_attribute6);
   cust_rel_rec.attribute7                    := INIT_SWITCH(x_attribute7);
   cust_rel_rec.attribute8                    := INIT_SWITCH(x_attribute8);
   cust_rel_rec.attribute9                    := INIT_SWITCH(x_attribute9);
   cust_rel_rec.attribute10                   := INIT_SWITCH(x_attribute10);
   cust_rel_rec.attribute11                   := INIT_SWITCH(x_attribute11);
   cust_rel_rec.attribute12                   := INIT_SWITCH(x_attribute12);
   cust_rel_rec.attribute13                   := INIT_SWITCH(x_attribute13);
   cust_rel_rec.attribute14                   := INIT_SWITCH(x_attribute14);
   cust_rel_rec.attribute15                   := INIT_SWITCH(x_attribute15);
   cust_rel_rec.BILL_TO_FLAG                  := INIT_SWITCH(x_BILL_TO_FLAG);
   cust_rel_rec.SHIP_TO_FLAG                  := INIT_SWITCH(x_SHIP_TO_FLAG);
-- Bug Fix 1823689
   cust_rel_rec.relationship_type             := INIT_SWITCH(X_relationship_type);

   --{Bug Fix: 3237327
   IF X_Row_Id IS NOT NULL THEN
      HZ_CUST_ACCOUNT_V2PUB.update_cust_acct_relate (
        p_cust_acct_relate_rec              => cust_rel_rec,
        p_object_version_number             => l_object_version,
        p_rowid                             => X_Row_Id,
        x_return_status                     => x_return_status,
        x_msg_count                         => x_msg_count,
        x_msg_data                          => x_msg_data );
   ELSE
      HZ_CUST_ACCOUNT_V2PUB.update_cust_acct_relate (
        p_cust_acct_relate_rec              => cust_rel_rec,
        p_object_version_number             => l_object_version,
        x_return_status                     => x_return_status,
        x_msg_count                         => x_msg_count,
        x_msg_data                          => x_msg_data );
   END IF;
   --}

  IF x_return_status = 'S' THEN
  --{Bug Fix: 3237327
    IF x_row_id IS NOT NULL THEN
      select last_update_date
        into x_last_update_date
        from hz_cust_acct_relate
       where cust_account_id         = X_Customer_Id
         and related_cust_account_id = X_Related_Customer_Id
         and rowid                   = X_row_id;
    ELSE
      /* As x_customer_id and X_Related_Customer_Id can not identified a unique record
         We will not be able to return the x_last_update_date correctly, we can not return
         it. We might face some issue here but as this api is only used by ARXCUDCI.fmb
         and ARXCUDCI.fmb has been modified accordingly, this should not be a problem */
       NULL;
    END IF;
  --Bug Fix: 3237327
  END IF;

  IF x_msg_count > 1 THEN
    FOR i IN 1..x_msg_count  LOOP
     tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
     tmp_var1 := tmp_var1 || ' '|| tmp_var;
    END LOOP;
     x_msg_data := tmp_var1;
  END IF;

	--
	-- Update the reciprocal relationship.
	-- if it exist.
	--
  --{Bug Fix: 3237327
  IF x_return_status = 'S' THEN
    IF x_row_id IS NOT NULL THEN
      update  hz_cust_acct_relate_all
         set  customer_reciprocal_flag = decode(x_status,
                    'I','N',
                    'A','Y'
                 )
       where  cust_account_id          = x_related_customer_id
         and  related_cust_account_id  = x_customer_id
         and  rowid                    = X_row_id;
    ELSE
      /* As x_customer_id and X_Related_Customer_Id can not identified a unique record
         We will not be able to return the x_last_update_date correctly, we can not return
         it. We might face some issue here but as this api is only used by ARXCUDCI.fmb
         and ARXCUDCI.fmb has been modified accordingly, this should not be a problem */
      NULL;
    END IF;
  END IF;
  --}Bug Fix: 3237327
	--
	--
  END Update_Row;

END arh_crel_pkg;

/
