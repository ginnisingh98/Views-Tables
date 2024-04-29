--------------------------------------------------------
--  DDL for Package Body IGS_PE_VISAPASS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_VISAPASS_PUB" AS
/* $Header: IGSPE16B.pls 120.1 2005/10/17 02:22:50 appldev noship $ */

/******************************************************************************
  ||  Created By : ssaleem
  ||  Created On : 01-Sep-2004
  ||  Purpose : This public API is used to update and insert records to
  ||            Visa, Passport and Visit Histry tables in IGS
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || vredkar	     14-Oct-2005     Bug#4654248,replaced generic duplicate/overlap
  ||			             exists messages with component specific messages
******************************************************************************/

G_PKG_NAME         CONSTANT VARCHAR2(30):='IGS_PE_VISAPASS_PUB';

-- Start of comments
--        API name         : Create_Visa
--        Type             : Public
--        Function         :
--        Pre-reqs         : None.
--        Parameters       :
--        IN               :      p_api_version               IN NUMBER        Required
--                                p_init_msg_list             IN VARCHAR2         Optional
--                                Default = FND_API.G_FALSE
--                                p_commit                    IN VARCHAR2        Optional
--                                Default = FND_API.G_FALSE
--                                Default = FND_API.G_VALID_LEVEL_FULL
--                                p_visa_rec                  IN visa_rec_type
--
--
--        OUT                :        x_return_status         OUT        VARCHAR2(1)
--                                x_msg_count                 OUT        NUMBER
--                                x_msg_data                  OUT        VARCHAR2(2000)
--                                x_visa_id                   OUT     NUMBER
--
--
--
--        Version        : Current version        x.x
--                                Changed....
--                          previous version        y.y
--                                Changed....
--                          .
--                          .
--                          Initial version         1.0
--
--        Notes                :
--
-- End of comments

PROCEDURE Create_Visa
(         p_api_version                   IN        NUMBER,
          p_init_msg_list                 IN        VARCHAR2  DEFAULT FND_API.G_FALSE,
          p_commit                        IN        VARCHAR2  DEFAULT FND_API.G_FALSE,
          x_return_status                 OUT  NOCOPY     VARCHAR2,
          x_msg_count                     OUT  NOCOPY     NUMBER,
          x_msg_data                      OUT  NOCOPY     VARCHAR2,
          p_visa_rec                      IN        visa_rec_type,
          x_visa_id                       OUT  NOCOPY     NUMBER
)
IS


l_api_name                        CONSTANT VARCHAR2(30)        := 'Create_Visa';
l_api_version                   CONSTANT NUMBER                 := 1.0;

l_error_code igs_pe_visa_int.error_code%TYPE;
l_message_name VARCHAR2(30);
l_app          VARCHAR2(50);
l_rowid ROWID := NULL;

l_visa_rec    visa_rec_type;
BEGIN
    SAVEPOINT        Create_Visa_PUB;
    IF NOT FND_API.Compatible_API_Call (         l_api_version,
                                                 p_api_version,
                                                 l_api_name,
                                                 G_PKG_NAME )
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
-- Start here

   l_visa_rec := p_visa_rec;
   x_msg_count := 0;

   l_visa_rec.visa_issue_date := TRUNC(l_visa_rec.visa_issue_date);
   l_visa_rec.visa_expiry_date := TRUNC(l_visa_rec.visa_expiry_date);


   IF l_visa_rec.person_id IS NULL OR l_visa_rec.person_id = FND_API.G_MISS_NUM THEN
      fnd_message.set_name ('IGS', 'IGS_PS_LGCY_MANDATORY');
      fnd_message.set_token('PARAM','PERSON_ID');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
   END IF;

   IF l_visa_rec.visa_type IS NULL OR l_visa_rec.visa_type = FND_API.G_MISS_CHAR THEN
    fnd_message.set_name ('IGS', 'IGS_PS_LGCY_MANDATORY');
    fnd_message.set_token('PARAM','VISA_TYPE');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
   END IF;

   IF l_visa_rec.visa_number IS NULL OR l_visa_rec.visa_number = FND_API.G_MISS_CHAR THEN
    fnd_message.set_name ('IGS', 'IGS_PS_LGCY_MANDATORY');
    fnd_message.set_token('PARAM','VISA_NUMBER');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
   END IF;

   IF l_visa_rec.visa_issue_date IS NULL  OR l_visa_rec.visa_issue_date = FND_API.G_MISS_DATE THEN
    fnd_message.set_name ('IGS', 'IGS_PS_LGCY_MANDATORY');
    fnd_message.set_token('PARAM','VISA_ISSUE_DATE');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
   END IF;

   IF l_visa_rec.visa_expiry_date IS NULL OR l_visa_rec.visa_expiry_date = FND_API.G_MISS_DATE THEN
     fnd_message.set_name ('IGS', 'IGS_PS_LGCY_MANDATORY');
     fnd_message.set_token('PARAM','visa_expiry_date');
     igs_ge_msg_stack.add;
     app_exception.raise_exception;
   END IF;

   IF l_visa_rec.visa_issuing_post = FND_API.G_MISS_CHAR THEN
    l_visa_rec.visa_issuing_post := NULL;
   END IF;

   IF l_visa_rec.passport_id = FND_API.G_MISS_NUM THEN
    l_visa_rec.passport_id := NULL;
   END IF;

   IF l_visa_rec.agent_org_unit_cd = FND_API.G_MISS_CHAR THEN
    l_visa_rec.agent_org_unit_cd := NULL;
   END IF;

   IF l_visa_rec.agent_person_id = FND_API.G_MISS_NUM THEN
    l_visa_rec.agent_person_id := NULL;
   END IF;

   IF l_visa_rec.visa_number = FND_API.G_MISS_CHAR THEN
    l_visa_rec.visa_number := NULL;
   END IF;

   IF l_visa_rec.agent_contact_name = FND_API.G_MISS_CHAR THEN
    l_visa_rec.agent_contact_name := NULL;
   END IF;

   IF l_visa_rec.attribute_category = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute_category := NULL;
   END IF;

   IF l_visa_rec.attribute1 = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute1 := NULL;
   END IF;

   IF l_visa_rec.attribute2 = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute2 := NULL;
   END IF;

   IF l_visa_rec.attribute4 = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute4 := NULL;
   END IF;

   IF l_visa_rec.attribute5 = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute5 := NULL;
   END IF;

   IF l_visa_rec.attribute6 = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute6 := NULL;
   END IF;

   IF l_visa_rec.attribute7 = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute7 := NULL;
   END IF;

   IF l_visa_rec.attribute8 = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute8 := NULL;
   END IF;

   IF l_visa_rec.attribute9 = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute9 := NULL;
   END IF;

   IF l_visa_rec.attribute10 = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute10 := NULL;
   END IF;

   IF l_visa_rec.attribute11 = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute11 := NULL;
   END IF;

   IF l_visa_rec.attribute12 = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute12 := NULL;
   END IF;

   IF l_visa_rec.attribute13 = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute13 := NULL;
   END IF;

   IF l_visa_rec.attribute14 = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute14 := NULL;
   END IF;

   IF l_visa_rec.attribute15 = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute15 := NULL;
   END IF;

   IF l_visa_rec.attribute16 = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute16 := NULL;
   END IF;

   IF l_visa_rec.attribute17 = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute17 := NULL;
   END IF;

   IF l_visa_rec.attribute18 = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute18 := NULL;
   END IF;

   IF l_visa_rec.attribute19 = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute19 := NULL;
   END IF;

   IF l_visa_rec.attribute20 = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute20 := NULL;
   END IF;

   IF l_visa_rec.visa_issuing_country = FND_API.G_MISS_CHAR THEN
    l_visa_rec.visa_issuing_country := NULL;
   END IF;

   IF igs_ad_imp_026.validate_visa_pub(api_visa_rec => l_visa_rec, p_err_code => l_error_code) THEN

           IGS_PE_VISA_PKG.INSERT_ROW(
                X_ROWID                    =>  l_rowid,
                X_VISA_ID                  =>  x_visa_id,
                X_PERSON_ID                =>  l_visa_rec.person_id,
                X_VISA_TYPE                =>  l_visa_rec.VISA_TYPE ,
                X_VISA_NUMBER              =>  l_visa_rec.VISA_NUMBER,
                X_VISA_ISSUE_DATE          =>  l_visa_rec.VISA_ISSUE_DATE ,
                X_VISA_EXPIRY_DATE         =>  l_visa_rec.VISA_EXPIRY_DATE,
                X_VISA_CATEGORY            =>  NULL ,
                X_VISA_ISSUING_POST        =>  l_visa_rec.VISA_ISSUING_POST,
                X_PASSPORT_ID              =>  l_visa_rec.PASSPORT_ID,
                X_AGENT_ORG_UNIT_CD        =>  l_visa_rec.AGENT_ORG_UNIT_CD ,
                X_AGENT_PERSON_ID          =>  l_visa_rec.AGENT_PERSON_ID    ,
                X_AGENT_CONTACT_NAME       =>  l_visa_rec.AGENT_CONTACT_NAME ,
                X_ATTRIBUTE_CATEGORY       =>  l_visa_rec.ATTRIBUTE_CATEGORY ,
                X_ATTRIBUTE1               =>  l_visa_rec.ATTRIBUTE1         ,
                X_ATTRIBUTE2               =>  l_visa_rec.ATTRIBUTE2         ,
                X_ATTRIBUTE3               =>  l_visa_rec.ATTRIBUTE3         ,
                X_ATTRIBUTE4               =>  l_visa_rec.ATTRIBUTE4         ,
                X_ATTRIBUTE5               =>  l_visa_rec.ATTRIBUTE5         ,
                X_ATTRIBUTE6               =>  l_visa_rec.ATTRIBUTE6         ,
                X_ATTRIBUTE7               =>  l_visa_rec.ATTRIBUTE7         ,
                X_ATTRIBUTE8               =>  l_visa_rec.ATTRIBUTE8         ,
                X_ATTRIBUTE9               =>  l_visa_rec.ATTRIBUTE9         ,
                X_ATTRIBUTE10              =>  l_visa_rec.ATTRIBUTE10        ,
                X_ATTRIBUTE11              =>  l_visa_rec.ATTRIBUTE11        ,
                X_ATTRIBUTE12              =>  l_visa_rec.ATTRIBUTE12        ,
                X_ATTRIBUTE13              =>  l_visa_rec.ATTRIBUTE13        ,
                X_ATTRIBUTE14              =>  l_visa_rec.ATTRIBUTE14        ,
                X_ATTRIBUTE15              =>  l_visa_rec.ATTRIBUTE15        ,
                X_ATTRIBUTE16              =>  l_visa_rec.ATTRIBUTE16        ,
                X_ATTRIBUTE17              =>  l_visa_rec.ATTRIBUTE17        ,
                X_ATTRIBUTE18              =>  l_visa_rec.ATTRIBUTE18        ,
                X_ATTRIBUTE19              =>  l_visa_rec.ATTRIBUTE19        ,
                X_ATTRIBUTE20              =>  l_visa_rec.ATTRIBUTE20        ,
                x_visa_issuing_country     =>  l_visa_rec.visa_issuing_country);
    ELSE
          RAISE FND_API.G_EXC_ERROR;
    END IF;

-- End Here

    IF l_error_code = 'E555' THEN
      x_msg_count := 1;
      x_msg_data := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', l_error_code, 8405);
    END IF;


    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO Create_Visa_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                x_msg_data := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', l_error_code, 8405);
                x_msg_count := 1;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO Create_Visa_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                    (          p_count                 =>      x_msg_count             ,
                               p_data                  =>      x_msg_data
                    );
    WHEN OTHERS THEN
                ROLLBACK TO Create_Visa_PUB;

                FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED, l_app, l_message_name);
                x_msg_count := 1;

                IF l_message_name IN('IGS_PE_VIS_ASOC_PASS_EXP','IGS_FOREIGN_KEY_REFERENCE','IGS_PE_VISA_DATE_OVERLAP','IGS_EN_INV','IGS_PS_LGCY_MANDATORY', 'IGS_PE_VIPS_UPD_ERR') THEN
                  x_return_status := FND_API.G_RET_STS_ERROR ;
                  x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_FIRST, p_encoded => 'F');
		ELSIF l_message_name  = 'FORM_RECORD_DELETED' THEN
                  x_return_status := FND_API.G_RET_STS_ERROR ;
                  fnd_message.set_name ('IGS', 'IGS_EN_INV');
                  fnd_message.set_token('PARAM','PERSON_ID');
                  igs_ge_msg_stack.add;
                  x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST, p_encoded => 'F');
		ELSIF l_message_name = 'IGS_PE_VISA_DUP_EXISTS' THEN
                  x_return_status := FND_API.G_RET_STS_ERROR ;
                  fnd_message.set_name ('IGS', 'IGS_PE_UNIQUE_FAILED');
                  fnd_message.set_token('COLUMN','PERSON_ID,VISA_TYPE,VISA_ISSUE_DATE');
                  igs_ge_msg_stack.add;
                  x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST, p_encoded => 'F');
                ELSE
                  x_msg_data := SQLERRM;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                END IF;

END Create_Visa;




-- Start of comments
--        API name         : Update_Visa
--        Type             : Public
--        Function         :
--        Pre-reqs         : None.
--        Parameters       :
--        IN               :      p_api_version             IN NUMBER        Required
--                                p_init_msg_list           IN VARCHAR2         Optional
--                                Default = FND_API.G_FALSE
--                                p_commit                  IN VARCHAR2        Optional
--                                Default = FND_API.G_FALSE
--                                Default = FND_API.G_VALID_LEVEL_FULL
--                                p_visa_rec                IN visa_rec_type
--
--
--        OUT                :    x_return_status           OUT        VARCHAR2(1)
--                                x_msg_count               OUT        NUMBER
--                                x_msg_data                OUT        VARCHAR2(2000)
--
--
--
--        Version        : Current version        x.x
--                                Changed....
--                          previous version        y.y
--                                Changed....
--                          .
--                          .
--                          Initial version         1.0
--
--        Notes                :
--
-- End of comments

PROCEDURE Update_Visa
(         p_api_version                   IN        NUMBER,
          p_init_msg_list                 IN        VARCHAR2 DEFAULT FND_API.G_FALSE,
          p_commit                        IN        VARCHAR2 DEFAULT FND_API.G_FALSE,
          x_return_status                 OUT    NOCOPY   VARCHAR2,
          x_msg_count                     OUT    NOCOPY   NUMBER,
          x_msg_data                      OUT    NOCOPY   VARCHAR2,
          p_visa_rec                      IN        visa_rec_type
)
IS

CURSOR null_handlng_cur(cp_visa_rec  IN  visa_rec_type) IS
SELECT rowid,
       visa_id,person_id,visa_type, visa_number, visa_issue_date, visa_expiry_date,visa_category,
       visa_issuing_post,passport_id, agent_org_unit_cd, agent_person_id, agent_contact_name,
       attribute_category,attribute1, attribute2, attribute3, attribute4, attribute5, attribute6,
       attribute7, attribute8, attribute9,  attribute10, attribute11, attribute12, attribute13,
       attribute14, attribute15, attribute16, attribute17, attribute18, attribute19, attribute20,
       visa_issuing_country
FROM  IGS_PE_VISA
WHERE   VISA_ID = cp_visa_rec.visa_id FOR UPDATE NOWAIT;

dup_visa_rec null_handlng_cur%ROWTYPE;
l_error_code igs_pe_visa_int.error_code%TYPE;

l_message_name VARCHAR2(30);
l_app          VARCHAR2(50);

l_api_name                        CONSTANT VARCHAR2(30)        := 'Update_Visa';
l_api_version                   CONSTANT NUMBER                 := 1.0;

l_visa_rec    visa_rec_type;

E_RESOURCE_BUSY   EXCEPTION;
PRAGMA EXCEPTION_INIT(E_RESOURCE_BUSY, -54);

BEGIN
    SAVEPOINT        Update_Visa_PUB;
    IF NOT FND_API.Compatible_API_Call (         l_api_version,
                                                 p_api_version,
                                                 l_api_name,
                                                 G_PKG_NAME )
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Start here

   l_visa_rec := p_visa_rec;

   l_visa_rec.visa_issue_date := TRUNC(l_visa_rec.visa_issue_date);
   l_visa_rec.visa_expiry_date := TRUNC(l_visa_rec.visa_expiry_date);

   IF l_visa_rec.visa_id IS NULL OR l_visa_rec.visa_id = FND_API.G_MISS_NUM THEN
      fnd_message.set_name ('IGS', 'IGS_PS_LGCY_MANDATORY');
      fnd_message.set_token('PARAM','VISA_ID');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
   END IF;

   OPEN null_handlng_cur(p_visa_rec);
   FETCH null_handlng_cur INTO dup_visa_rec;
   IF null_handlng_cur%NOTFOUND THEN
     fnd_message.set_name ('IGS', 'IGS_PE_VIPS_UPD_ERR');
     fnd_message.set_token('VALUES','VISA_ID=' || p_visa_rec.visa_id);
     igs_ge_msg_stack.add;
     app_exception.raise_exception;
   END IF;
   CLOSE null_handlng_cur;

   IF l_visa_rec.person_id = FND_API.G_MISS_NUM THEN
     fnd_message.set_name ('IGS', 'IGS_PS_LGCY_MANDATORY');
     fnd_message.set_token('PARAM','PERSON_ID');
     igs_ge_msg_stack.add;
     app_exception.raise_exception;
   ELSIF l_visa_rec.person_id IS NULL THEN
     l_visa_rec.person_id := dup_visa_rec.person_id;
   ELSIF l_visa_rec.person_id <> dup_visa_rec.person_id THEN
    fnd_message.set_name ('IGS', 'IGS_PE_VIPS_COL_NONUPD');
    fnd_message.set_token('COLUMN','PERSON_ID');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
   END IF;

   IF l_visa_rec.visa_type = FND_API.G_MISS_CHAR THEN
    fnd_message.set_name ('IGS', 'IGS_PS_LGCY_MANDATORY');
    fnd_message.set_token('PARAM','VISA_TYPE');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
   ELSIF l_visa_rec.visa_type IS NULL THEN
    l_visa_rec.visa_type := dup_visa_rec.visa_type;
   ELSIF l_visa_rec.visa_type <> dup_visa_rec.visa_type THEN
    fnd_message.set_name ('IGS', 'IGS_PE_VIPS_COL_NONUPD');
    fnd_message.set_token('COLUMN','VISA_TYPE');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
   END IF;

   IF l_visa_rec.visa_number = FND_API.G_MISS_CHAR THEN
     fnd_message.set_name ('IGS', 'IGS_PS_LGCY_MANDATORY');
     fnd_message.set_token('PARAM','VISA_NUMBER');
     igs_ge_msg_stack.add;
     app_exception.raise_exception;
   ELSIF l_visa_rec.visa_number IS NULL THEN
    l_visa_rec.visa_number := dup_visa_rec.visa_number;
   END IF;

   IF l_visa_rec.visa_issue_date = FND_API.G_MISS_DATE THEN
     fnd_message.set_name ('IGS', 'IGS_PS_LGCY_MANDATORY');
     fnd_message.set_token('PARAM','VISA_ISSUE_DATE');
     igs_ge_msg_stack.add;
     app_exception.raise_exception;
   ELSIF l_visa_rec.visa_issue_date IS NULL THEN
    l_visa_rec.visa_issue_date := dup_visa_rec.visa_issue_date;
   ELSIF l_visa_rec.visa_issue_date <> dup_visa_rec.visa_issue_date THEN
    fnd_message.set_name ('IGS', 'IGS_PE_VIPS_COL_NONUPD');
    fnd_message.set_token('COLUMN','VISA_ISSUE_DATE');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
   END IF;

   IF l_visa_rec.visa_expiry_date = FND_API.G_MISS_DATE THEN
     fnd_message.set_name ('IGS', 'IGS_PS_LGCY_MANDATORY');
     fnd_message.set_token('PARAM','VISA_EXPIRY_DATE');
     igs_ge_msg_stack.add;
     app_exception.raise_exception;
   ELSIF l_visa_rec.visa_expiry_date IS NULL THEN
    l_visa_rec.visa_expiry_date := dup_visa_rec.visa_expiry_date;
   END IF;

   IF l_visa_rec.visa_issuing_post = FND_API.G_MISS_CHAR THEN
    l_visa_rec.visa_issuing_post := NULL;
   ELSIF l_visa_rec.visa_issuing_post IS NULL THEN
    l_visa_rec.visa_issuing_post := dup_visa_rec.visa_issuing_post;
   END IF;

   IF l_visa_rec.passport_id = FND_API.G_MISS_NUM THEN
    l_visa_rec.passport_id := NULL;
   ELSIF l_visa_rec.passport_id IS NULL THEN
    l_visa_rec.passport_id := dup_visa_rec.passport_id;
   END IF;

   IF l_visa_rec.agent_org_unit_cd  = FND_API.G_MISS_CHAR THEN
    l_visa_rec.agent_org_unit_cd  := NULL;
   ELSIF l_visa_rec.agent_org_unit_cd  IS NULL THEN
    l_visa_rec.agent_org_unit_cd := dup_visa_rec.agent_org_unit_cd ;
   END IF;

   IF l_visa_rec.agent_person_id = FND_API.G_MISS_NUM THEN
    l_visa_rec.agent_person_id  := NULL;
   ELSIF l_visa_rec.agent_person_id IS NULL THEN
    l_visa_rec.agent_person_id := dup_visa_rec.agent_person_id;
   END IF;

   IF l_visa_rec.agent_contact_name = FND_API.G_MISS_CHAR THEN
    l_visa_rec.agent_contact_name := NULL;
   ELSIF l_visa_rec.agent_contact_name IS NULL THEN
    l_visa_rec.agent_contact_name := dup_visa_rec.agent_contact_name;
   END IF;

   IF l_visa_rec.attribute_category = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute_category := NULL;
   ELSIF l_visa_rec.attribute_category IS NULL THEN
    l_visa_rec.attribute_category := dup_visa_rec.attribute_category;
   END IF;

   IF l_visa_rec.attribute1 = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute1 := NULL;
   ELSIF l_visa_rec.attribute1 IS NULL THEN
    l_visa_rec.attribute1 := dup_visa_rec.attribute1;
   END IF;

   IF l_visa_rec.attribute2 = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute2 := NULL;
   ELSIF l_visa_rec.attribute2 IS NULL THEN
    l_visa_rec.attribute2 := dup_visa_rec.attribute2;
   END IF;

   IF l_visa_rec.attribute3 = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute3 := NULL;
   ELSIF l_visa_rec.attribute3 IS NULL THEN
    l_visa_rec.attribute3 := dup_visa_rec.attribute3;
   END IF;

   IF l_visa_rec.attribute4 = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute4 := NULL;
   ELSIF l_visa_rec.attribute4 IS NULL THEN
    l_visa_rec.attribute4 := dup_visa_rec.attribute4;
   END IF;

   IF l_visa_rec.attribute5 = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute5 := NULL;
   ELSIF l_visa_rec.attribute5 IS NULL THEN
    l_visa_rec.attribute5 := dup_visa_rec.attribute5;
   END IF;

   IF l_visa_rec.attribute6 = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute6 := NULL;
   ELSIF l_visa_rec.attribute6 IS NULL THEN
    l_visa_rec.attribute6 := dup_visa_rec.attribute6;
   END IF;

   IF l_visa_rec.attribute7 = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute7 := NULL;
   ELSIF l_visa_rec.attribute7 IS NULL THEN
    l_visa_rec.attribute7 := dup_visa_rec.attribute7;
   END IF;

   IF l_visa_rec.attribute8 = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute8 := NULL;
   ELSIF l_visa_rec.attribute8 IS NULL THEN
    l_visa_rec.attribute8 := dup_visa_rec.attribute8;
   END IF;

   IF l_visa_rec.attribute9 = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute9 := NULL;
   ELSIF l_visa_rec.attribute9 IS NULL THEN
    l_visa_rec.attribute9 := dup_visa_rec.attribute9;
   END IF;

   IF l_visa_rec.attribute10 = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute10 := NULL;
   ELSIF l_visa_rec.attribute10 IS NULL THEN
    l_visa_rec.attribute10 := dup_visa_rec.attribute10;
   END IF;

   IF l_visa_rec.attribute11 = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute11 := NULL;
   ELSIF l_visa_rec.attribute11 IS NULL THEN
    l_visa_rec.attribute11 := dup_visa_rec.attribute11;
   END IF;

   IF l_visa_rec.attribute12 = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute12 := NULL;
   ELSIF l_visa_rec.attribute12 IS NULL THEN
    l_visa_rec.attribute12 := dup_visa_rec.attribute12;
   END IF;

   IF l_visa_rec.attribute13 = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute13 := NULL;
   ELSIF l_visa_rec.attribute13 IS NULL THEN
    l_visa_rec.attribute13 := dup_visa_rec.attribute13;
   END IF;

   IF l_visa_rec.attribute14 = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute14 := NULL;
   ELSIF l_visa_rec.attribute14 IS NULL THEN
    l_visa_rec.attribute14 := dup_visa_rec.attribute14;
   END IF;

   IF l_visa_rec.attribute15 = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute15 := NULL;
   ELSIF l_visa_rec.attribute15 IS NULL THEN
    l_visa_rec.attribute15 := dup_visa_rec.attribute15;
   END IF;

   IF l_visa_rec.attribute16 = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute16 := NULL;
   ELSIF l_visa_rec.attribute16 IS NULL THEN
    l_visa_rec.attribute16 := dup_visa_rec.attribute16;
   END IF;

   IF l_visa_rec.attribute17 = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute17 := NULL;
   ELSIF l_visa_rec.attribute17 IS NULL THEN
    l_visa_rec.attribute17 := dup_visa_rec.attribute17;
   END IF;

   IF l_visa_rec.attribute18 = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute18 := NULL;
   ELSIF l_visa_rec.attribute18 IS NULL THEN
    l_visa_rec.attribute18 := dup_visa_rec.attribute18;
   END IF;

   IF l_visa_rec.attribute19 = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute19 := NULL;
   ELSIF l_visa_rec.attribute19 IS NULL THEN
    l_visa_rec.attribute19 := dup_visa_rec.attribute19;
   END IF;

   IF l_visa_rec.attribute20 = FND_API.G_MISS_CHAR THEN
    l_visa_rec.attribute20 := NULL;
   ELSIF l_visa_rec.attribute20 IS NULL THEN
    l_visa_rec.attribute20 := dup_visa_rec.attribute20;
   END IF;

   IF l_visa_rec.visa_issuing_country = FND_API.G_MISS_CHAR THEN
    l_visa_rec.visa_issuing_country := NULL;
   ELSIF l_visa_rec.visa_issuing_country IS NULL THEN
    l_visa_rec.visa_issuing_country := dup_visa_rec.visa_issuing_country;
   END IF;

   x_msg_count := 0;

   IF igs_ad_imp_026.validate_visa_pub(api_visa_rec => l_visa_rec, p_err_code => l_error_code) THEN

     IGS_PE_VISA_PKG.UPDATE_ROW (
                 X_ROWID                         => dup_visa_rec.rowid,
                 X_VISA_ID                       => l_visa_rec.visa_id,
                 X_PERSON_ID                     => l_visa_rec.person_id,
                 X_VISA_TYPE                     => l_visa_rec.visa_type,
                 X_VISA_NUMBER                   => l_visa_rec.visa_number,
                 X_VISA_ISSUE_DATE               => l_visa_rec.visa_issue_date,
                 X_VISA_EXPIRY_DATE              => l_visa_rec.visa_expiry_date,
                 X_VISA_CATEGORY                 => NULL,
                 X_VISA_ISSUING_POST             => l_visa_rec.visa_issuing_post,
                 X_PASSPORT_ID                   => l_visa_rec.passport_id,
                 X_AGENT_ORG_UNIT_CD             => l_visa_rec.agent_org_unit_cd,
                 X_AGENT_PERSON_ID               => l_visa_rec.agent_person_id,
                 X_AGENT_CONTACT_NAME            => l_visa_rec.agent_contact_name,
                 X_ATTRIBUTE_CATEGORY            => l_visa_rec.attribute_category,
                 X_ATTRIBUTE1                    => l_visa_rec.attribute1,
                 X_ATTRIBUTE2                    => l_visa_rec.attribute2,
                 X_ATTRIBUTE3                    => l_visa_rec.attribute3,
                 X_ATTRIBUTE4                    => l_visa_rec.attribute4,
                 X_ATTRIBUTE5                    => l_visa_rec.attribute5,
                 X_ATTRIBUTE6                    => l_visa_rec.attribute6,
                 X_ATTRIBUTE7                    => l_visa_rec.attribute7,
                 X_ATTRIBUTE8                    => l_visa_rec.attribute8,
                 X_ATTRIBUTE9                    => l_visa_rec.attribute9,
                 X_ATTRIBUTE10                   => l_visa_rec.attribute10,
                 X_ATTRIBUTE11                   => l_visa_rec.attribute11,
                 X_ATTRIBUTE12                   => l_visa_rec.attribute12,
                 X_ATTRIBUTE13                   => l_visa_rec.attribute13,
                 X_ATTRIBUTE14                   => l_visa_rec.attribute14,
                 X_ATTRIBUTE15                   => l_visa_rec.attribute15,
                 X_ATTRIBUTE16                   => l_visa_rec.attribute16,
                 X_ATTRIBUTE17                   => l_visa_rec.attribute17,
                 X_ATTRIBUTE18                   => l_visa_rec.attribute18,
                 X_ATTRIBUTE19                   => l_visa_rec.attribute19,
                 X_ATTRIBUTE20                   => l_visa_rec.attribute20,
                 X_visa_issuing_country          => l_visa_rec.visa_issuing_country);
    ELSE
	   RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_error_code = 'E555' THEN
      x_msg_count := 1;
      x_msg_data := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', l_error_code, 8405);
    END IF;

-- End Here

    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

EXCEPTION
    WHEN E_RESOURCE_BUSY THEN
                ROLLBACK TO Update_Visa_PUB;
                fnd_message.set_name ('IGS', 'IGS_GE_RECORD_LOCKED');
                igs_ge_msg_stack.add;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_FIRST, p_encoded => 'F');
                x_msg_count := 1;
    WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO Update_Visa_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                x_msg_data := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', l_error_code, 8405);
	        x_msg_count := 1;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO Update_Visa_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                    (          p_count                 =>      x_msg_count             ,
                               p_data                  =>      x_msg_data
                    );
    WHEN OTHERS THEN
                ROLLBACK TO Update_Visa_PUB;
                FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED, l_app, l_message_name);

                x_msg_count := 1;
                IF l_message_name IN('IGS_PE_VIS_ASOC_PASS_EXP','IGS_PE_VISA_DUP_EXISTS','IGS_PE_VISA_DATE_OVERLAP','IGS_EN_INV','IGS_PS_LGCY_MANDATORY', 'IGS_PE_VIPS_UPD_ERR','IGS_PE_VIPS_COL_NONUPD','FORM_RECORD_DELETED') THEN
                  x_return_status := FND_API.G_RET_STS_ERROR ;
                  x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_FIRST, p_encoded => 'F');
                ELSE
                  x_msg_data := SQLERRM;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                END IF;

END Update_Visa;


-- Start of comments
--        API name         : Create_VisitHistry
--        Type             : Public
--        Function         :
--        Pre-reqs         : None.
--        Parameters       :
--        IN               :      p_api_version             IN NUMBER        Required
--                                p_init_msg_list           IN VARCHAR2         Optional
--                                Default = FND_API.G_FALSE
--                                p_commit                  IN VARCHAR2        Optional
--                                Default = FND_API.G_FALSE
--                                Default = FND_API.G_VALID_LEVEL_FULL
--                                p_visit_hstry_rec         IN visit_hstry_rec_type
--
--
--        OUT                :    x_return_status           OUT        VARCHAR2(1)
--                                x_msg_count               OUT        NUMBER
--                                x_msg_data                OUT        VARCHAR2(2000)
--
--
--
--
--        Version        : Current version        x.x
--                                Changed....
--                          previous version        y.y
--                                Changed....
--                          .
--                          .
--                          Initial version         1.0
--
--        Notes                :
--
-- End of comments

PROCEDURE Create_VisitHistry
(         p_api_version                   IN        NUMBER,
          p_init_msg_list                 IN        VARCHAR2 DEFAULT FND_API.G_FALSE,
          p_commit                        IN        VARCHAR2 DEFAULT FND_API.G_FALSE,
          x_return_status                 OUT  NOCOPY     VARCHAR2,
          x_msg_count                     OUT  NOCOPY     NUMBER,
          x_msg_data                      OUT  NOCOPY     VARCHAR2,
          p_visit_hstry_rec               IN        visit_hstry_rec_type
)
IS
l_api_name                        CONSTANT VARCHAR2(30)        := 'Create_VisitHistry';
l_api_version                   CONSTANT NUMBER                 := 1.0;

l_error_code VARCHAR2(30);
l_message_name VARCHAR2(30);
l_app          VARCHAR2(50);
l_rowid ROWID := NULL;

l_visit_hstry_rec   visit_hstry_rec_type;

BEGIN
    l_visit_hstry_rec   := p_visit_hstry_rec;

    l_visit_hstry_rec.visit_start_date := TRUNC(l_visit_hstry_rec.visit_start_date);
    l_visit_hstry_rec.visit_end_date := TRUNC(l_visit_hstry_rec.visit_end_date);

    SAVEPOINT        Create_VisitHistry_PUB;
    IF NOT FND_API.Compatible_API_Call (         l_api_version,
                                                 p_api_version,
                                                 l_api_name,
                                                 G_PKG_NAME )
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Start here
   x_msg_count := 0;


   IF l_visit_hstry_rec.port_of_entry IS NULL OR l_visit_hstry_rec.port_of_entry = FND_API.G_MISS_CHAR THEN
      fnd_message.set_name ('IGS', 'IGS_PS_LGCY_MANDATORY');
      fnd_message.set_token('PARAM','PORT_OF_ENTRY');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
   END IF;

   IF l_visit_hstry_rec.cntry_entry_form_num IS NULL OR l_visit_hstry_rec.cntry_entry_form_num = FND_API.G_MISS_CHAR THEN
      fnd_message.set_name ('IGS', 'IGS_PS_LGCY_MANDATORY');
      fnd_message.set_token('PARAM','CNTRY_ENTRY_FORM_NUM');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
   END IF;

   IF l_visit_hstry_rec.visa_id IS NULL OR l_visit_hstry_rec.visa_id = FND_API.G_MISS_NUM  THEN
     fnd_message.set_name ('IGS', 'IGS_PS_LGCY_MANDATORY');
     fnd_message.set_token('PARAM','VISA_ID');
     igs_ge_msg_stack.add;
     app_exception.raise_exception;
   END IF;

   IF l_visit_hstry_rec.visit_start_date IS NULL OR l_visit_hstry_rec.visit_start_date = FND_API.G_MISS_DATE THEN
      fnd_message.set_name ('IGS', 'IGS_PS_LGCY_MANDATORY');
      fnd_message.set_token('PARAM','VISIT_START_DATE');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
   END IF;

   IF l_visit_hstry_rec.visit_end_date = FND_API.G_MISS_DATE THEN
    l_visit_hstry_rec.visit_end_date := NULL;
   END IF;

   IF l_visit_hstry_rec.remarks = FND_API.G_MISS_CHAR THEN
    l_visit_hstry_rec.remarks := NULL;
   END IF;

   IF igs_ad_imp_026.Validate_visit_histry_pub(api_visit_rec => l_visit_hstry_rec, p_err_code => l_error_code) THEN

           igs_pe_visit_histry_pkg.insert_row(
                            X_ROWID                   => l_rowid,
                            X_PORT_OF_ENTRY           => l_visit_hstry_rec.port_of_entry,
                            X_CNTRY_ENTRY_FORM_NUM    => l_visit_hstry_rec.cntry_entry_form_num ,
                            X_VISA_ID                 => l_visit_hstry_rec.visa_id               ,
                            X_VISIT_START_DATE        => l_visit_hstry_rec.visit_start_date      ,
                            X_VISIT_END_DATE          => l_visit_hstry_rec.visit_end_date        ,
                            X_REMARKS                 => l_visit_hstry_rec.remarks,
                            X_ATTRIBUTE_CATEGORY      => NULL,
                            X_ATTRIBUTE1              => NULL,
                            X_ATTRIBUTE2              => NULL,
                            X_ATTRIBUTE3              => NULL,
                            X_ATTRIBUTE4              => NULL,
                            X_ATTRIBUTE5              => NULL,
                            X_ATTRIBUTE6              => NULL,
                            X_ATTRIBUTE7              => NULL,
                            X_ATTRIBUTE8              => NULL,
                            X_ATTRIBUTE9              => NULL,
                            X_ATTRIBUTE10             => NULL,
                            X_ATTRIBUTE11             => NULL,
                            X_ATTRIBUTE12             => NULL,
                            X_ATTRIBUTE13             => NULL,
                            X_ATTRIBUTE14             => NULL,
                            X_ATTRIBUTE15             => NULL,
                            X_ATTRIBUTE16             => NULL,
                            X_ATTRIBUTE17             => NULL,
                            X_ATTRIBUTE18             => NULL,
                            X_ATTRIBUTE19             => NULL,
                            X_ATTRIBUTE20             => NULL,
                            X_MODE                    => 'R');
 ELSE
     RAISE FND_API.G_EXC_ERROR;
 END IF;

    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO Create_VisitHistry_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                x_msg_data := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', l_error_code, 8405);
                x_msg_count := 1;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO Create_VisitHistry_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                    (          p_count                 =>      x_msg_count             ,
                               p_data                  =>      x_msg_data
                    );
    WHEN OTHERS THEN
                ROLLBACK TO Create_VisitHistry_PUB;

                FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED, l_app, l_message_name);

                x_msg_count := 1;

                IF l_message_name IN('IGS_PE_PORT_DATE_OVERLAP','IGS_EN_INV','IGS_PS_LGCY_MANDATORY', 'IGS_PE_VIPS_UPD_ERR','IGS_PE_VIPS_COL_NONUPD') THEN
                  x_return_status := FND_API.G_RET_STS_ERROR ;
                  x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_FIRST, p_encoded => 'F');
		ELSIF l_message_name = 'IGS_PE_PORT_DUP_EXISTS' THEN
                  x_return_status := FND_API.G_RET_STS_ERROR ;
                  fnd_message.set_name ('IGS', 'IGS_PE_UNIQUE_FAILED');
                  fnd_message.set_token('COLUMN','PORT_OF_ENTRY,CNTRY_ENTRY_FORM_NUM');
                  igs_ge_msg_stack.add;
                  x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST, p_encoded => 'F');
                ELSE
                  x_msg_data := ' ' || SQLERRM;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                END IF;

END Create_VisitHistry;


-- Start of comments
--        API name         : Update_VisitHistry
--        Type             : Public
--        Function         :
--        Pre-reqs         : None.
--        Parameters       :
--        IN               :      p_api_version           IN NUMBER        Required
--                                p_init_msg_list         IN VARCHAR2         Optional
--                                Default = FND_API.G_FALSE
--                                p_commit                IN VARCHAR2        Optional
--                                Default = FND_API.G_FALSE
--                                Default = FND_API.G_VALID_LEVEL_FULL
--                                p_visit_hstry_rec       IN        visit_hstry_rec_type
--
--
--        OUT                :    x_return_status         OUT        VARCHAR2(1)
--                                x_msg_count             OUT        NUMBER
--                                x_msg_data              OUT        VARCHAR2(2000)
--
--
--
--        Version        : Current version        x.x
--                                Changed....
--                          previous version        y.y
--                                Changed....
--                          .
--                          .
--                          Initial version         1.0
--
--        Notes                :
--
-- End of comments

PROCEDURE Update_VisitHistry
(         p_api_version                   IN        NUMBER,
          p_init_msg_list                 IN        VARCHAR2 DEFAULT FND_API.G_FALSE,
          p_commit                        IN        VARCHAR2 DEFAULT FND_API.G_FALSE,
          x_return_status                 OUT   NOCOPY    VARCHAR2,
          x_msg_count                     OUT   NOCOPY    NUMBER,
          x_msg_data                      OUT   NOCOPY    VARCHAR2,
          p_visit_hstry_rec               IN        visit_hstry_rec_type
)
IS

CURSOR null_handlng_cur(cp_visit_rec  IN  visit_hstry_rec_type) IS
SELECT rowid,
       port_of_entry, cntry_entry_form_num, visa_id, visit_start_date, visit_end_date, remarks
FROM  IGS_PE_VISIT_HISTRY
WHERE   port_of_entry = cp_visit_rec.port_of_entry AND
        cntry_entry_form_num = cp_visit_rec.cntry_entry_form_num FOR UPDATE NOWAIT;

dup_visit_rec null_handlng_cur%ROWTYPE;
l_error_code VARCHAR2(30);

l_message_name VARCHAR2(30);
l_app          VARCHAR2(50);

l_api_name                        CONSTANT VARCHAR2(30)        := 'Update_VisitHistry';
l_api_version                   CONSTANT NUMBER                 := 1.0;

l_visit_hstry_rec   visit_hstry_rec_type;

E_RESOURCE_BUSY                 EXCEPTION;
PRAGMA EXCEPTION_INIT(E_RESOURCE_BUSY, -54);

BEGIN
    l_visit_hstry_rec := p_visit_hstry_rec;

    l_visit_hstry_rec.visit_start_date := TRUNC(l_visit_hstry_rec.visit_start_date);
    l_visit_hstry_rec.visit_end_date := TRUNC(l_visit_hstry_rec.visit_end_date);

    SAVEPOINT        Update_VisitHistry_PUB;
    IF NOT FND_API.Compatible_API_Call (         l_api_version,
                                                 p_api_version,
                                                 l_api_name,
                                                 G_PKG_NAME )
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Start here
   x_msg_count := 0;

   IF p_visit_hstry_rec.port_of_entry IS NULL OR p_visit_hstry_rec.port_of_entry = FND_API.G_MISS_CHAR THEN
      fnd_message.set_name ('IGS', 'IGS_PS_LGCY_MANDATORY');
      fnd_message.set_token('PARAM','PORT_OF_ENTRY');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
   END IF;

   IF p_visit_hstry_rec.cntry_entry_form_num IS NULL OR p_visit_hstry_rec.cntry_entry_form_num = FND_API.G_MISS_CHAR THEN
      fnd_message.set_name ('IGS', 'IGS_PS_LGCY_MANDATORY');
      fnd_message.set_token('PARAM','CNTRY_ENTRY_FORM_NUM');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
   END IF;

   OPEN null_handlng_cur(p_visit_hstry_rec);
   FETCH null_handlng_cur INTO dup_visit_rec;
   IF null_handlng_cur%NOTFOUND THEN
      CLOSE null_handlng_cur;
      fnd_message.set_name ('IGS', 'IGS_PE_VIPS_UPD_ERR');
      fnd_message.set_token('VALUES','CNTRY_ENTRY_FORM_NUM=' || p_visit_hstry_rec.cntry_entry_form_num || ', PORT_OF_ENTRY=' || p_visit_hstry_rec.port_of_entry );
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
   END IF;
   CLOSE null_handlng_cur;

   IF l_visit_hstry_rec.visa_id = FND_API.G_MISS_NUM THEN
     fnd_message.set_name ('IGS', 'IGS_PS_LGCY_MANDATORY');
     fnd_message.set_token('PARAM','VISA_ID');
     igs_ge_msg_stack.add;
     app_exception.raise_exception;
   ELSIF l_visit_hstry_rec.visa_id IS NULL THEN
    l_visit_hstry_rec.visa_id := dup_visit_rec.visa_id;
   END IF;

   IF l_visit_hstry_rec.visit_start_date = FND_API.G_MISS_DATE THEN
      fnd_message.set_name ('IGS', 'IGS_PS_LGCY_MANDATORY');
      fnd_message.set_token('PARAM','VISIT_START_DATE');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
   ELSIF l_visit_hstry_rec.visit_start_date IS NULL THEN
    l_visit_hstry_rec.visit_start_date := dup_visit_rec.visit_start_date;
   END IF;

   IF l_visit_hstry_rec.visit_end_date = FND_API.G_MISS_DATE THEN
    l_visit_hstry_rec.visit_end_date := NULL;
   ELSIF l_visit_hstry_rec.visit_end_date IS NULL THEN
    l_visit_hstry_rec.visit_end_date := dup_visit_rec.visit_end_date;
   END IF;

   IF l_visit_hstry_rec.remarks = FND_API.G_MISS_CHAR THEN
    l_visit_hstry_rec.remarks := NULL;
   ELSIF l_visit_hstry_rec.remarks IS NULL THEN
    l_visit_hstry_rec.remarks := dup_visit_rec.remarks;
   END IF;

   IF igs_ad_imp_026.Validate_visit_histry_pub(api_visit_rec => l_visit_hstry_rec, p_err_code => l_error_code) THEN

                        igs_pe_visit_histry_pkg.update_row(
                                 X_ROWID                    => dup_visit_rec.rowid,
                                 X_PORT_OF_ENTRY            => l_visit_hstry_rec.port_of_entry,
                                 X_CNTRY_ENTRY_FORM_NUM     => l_visit_hstry_rec.cntry_entry_form_num,
                                 X_VISA_ID                  => l_visit_hstry_rec.visa_id ,
                                 X_VISIT_START_DATE         => l_visit_hstry_rec.visit_start_date,
                                 X_VISIT_END_DATE           => l_visit_hstry_rec.visit_end_date,
                                 X_REMARKS                  => l_visit_hstry_rec.remarks,
                                 X_ATTRIBUTE_CATEGORY       => NULL,
                                 X_ATTRIBUTE1               => NULL,
                                 X_ATTRIBUTE2               => NULL,
                                 X_ATTRIBUTE3               => NULL,
                                 X_ATTRIBUTE4               => NULL,
                                 X_ATTRIBUTE5               => NULL,
                                 X_ATTRIBUTE6               => NULL,
                                 X_ATTRIBUTE7               => NULL,
                                 X_ATTRIBUTE8               => NULL,
                                 X_ATTRIBUTE9               => NULL,
                                 X_ATTRIBUTE10              => NULL,
                                 X_ATTRIBUTE11              => NULL,
                                 X_ATTRIBUTE12              => NULL,
                                 X_ATTRIBUTE13              => NULL,
                                 X_ATTRIBUTE14              => NULL,
                                 X_ATTRIBUTE15              => NULL,
                                 X_ATTRIBUTE16              => NULL,
                                 X_ATTRIBUTE17              => NULL,
                                 X_ATTRIBUTE18              => NULL,
                                 X_ATTRIBUTE19              => NULL,
                                 X_ATTRIBUTE20              => NULL);
    ELSE
	  RAISE FND_API.G_EXC_ERROR;
    END IF;

-- End Here

    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

EXCEPTION
    WHEN E_RESOURCE_BUSY THEN
                ROLLBACK TO Update_VisitHistry_PUB;
                fnd_message.set_name ('IGS', 'IGS_GE_RECORD_LOCKED');
                igs_ge_msg_stack.add;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_FIRST, p_encoded => 'F');
                x_msg_count := 1;
    WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO Update_VisitHistry_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                x_msg_data := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', l_error_code, 8405);
                x_msg_count := 1;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO Update_VisitHistry_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                    (          p_count                 =>      x_msg_count             ,
                               p_data                  =>      x_msg_data
                    );
    WHEN OTHERS THEN
                ROLLBACK TO Update_VisitHistry_PUB;

                FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED, l_app, l_message_name);

		x_msg_count := 1;

                IF l_message_name IN('IGS_PE_PORT_DUP_EXISTS','IGS_PE_PORT_DATE_OVERLAP','IGS_EN_INV','IGS_PS_LGCY_MANDATORY', 'IGS_PE_VIPS_UPD_ERR','IGS_PE_VIPS_COL_NONUPD') THEN
                  x_return_status := FND_API.G_RET_STS_ERROR ;
                  x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_FIRST, p_encoded => 'F');
                ELSE
                  x_msg_data := SQLERRM;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                END IF;

END Update_VisitHistry;


-- Start of comments
--        API name         : Create_Passport
--        Type             : Public
--        Function         :
--        Pre-reqs         : None.
--        Parameters       :
--        IN               :      p_api_version               IN NUMBER        Required
--                                p_init_msg_list             IN VARCHAR2         Optional
--                                Default = FND_API.G_FALSE
--                                p_commit                    IN VARCHAR2        Optional
--                                Default = FND_API.G_FALSE
--                                Default = FND_API.G_VALID_LEVEL_FULL
--                                p_passport_rec              IN passport_rec_type
--
--
--        OUT                :    x_return_status             OUT        VARCHAR2(1)
--                                x_msg_count                 OUT        NUMBER
--                                x_msg_data                  OUT        VARCHAR2(2000)
--                                x_passport_id               OUT     NUMBER
--
--
--
--        Version        : Current version        x.x
--                                Changed....
--                          previous version        y.y
--                                Changed....
--                          .
--                          .
--                          Initial version         1.0
--
--        Notes                :
--
-- End of comments

PROCEDURE Create_Passport
(         p_api_version                   IN        NUMBER,
          p_init_msg_list                 IN        VARCHAR2 DEFAULT FND_API.G_FALSE,
          p_commit                        IN        VARCHAR2 DEFAULT FND_API.G_FALSE,
          x_return_status                 OUT  NOCOPY     VARCHAR2,
          x_msg_count                     OUT  NOCOPY     NUMBER,
          x_msg_data                      OUT  NOCOPY     VARCHAR2,
          p_passport_rec                  IN        passport_rec_type,
          x_passport_id                   OUT  NOCOPY     NUMBER
)
IS

l_api_name                        CONSTANT VARCHAR2(30)        := 'Create_Passport';
l_api_version                   CONSTANT NUMBER                 := 1.0;

l_error_code VARCHAR2(30);
l_message_name VARCHAR2(30);
l_app          VARCHAR2(50);
l_rowid ROWID := NULL;

l_passport_rec      passport_rec_type;

BEGIN
    l_passport_rec := p_passport_rec;
    l_passport_rec.passport_expiry_date := TRUNC(l_passport_rec.passport_expiry_date);
    SAVEPOINT        Create_Passport_PUB;
    IF NOT FND_API.Compatible_API_Call (         l_api_version,
                                                 p_api_version,
                                                 l_api_name,
                                                 G_PKG_NAME )
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
-- Start here

   x_msg_count := 0;

   IF l_passport_rec.person_id IS NULL  OR l_passport_rec.person_id = FND_API.G_MISS_NUM THEN
      fnd_message.set_name ('IGS', 'IGS_PS_LGCY_MANDATORY');
      fnd_message.set_token('PARAM','PERSON_ID');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
   END IF;

   IF l_passport_rec.passport_number IS NULL  OR l_passport_rec.passport_number = FND_API.G_MISS_CHAR THEN
      fnd_message.set_name ('IGS', 'IGS_PS_LGCY_MANDATORY');
      fnd_message.set_token('PARAM','PASSPORT_NUMBER');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
   END IF;

   IF l_passport_rec.passport_expiry_date IS NULL OR l_passport_rec.passport_expiry_date = FND_API.G_MISS_DATE THEN
      fnd_message.set_name ('IGS', 'IGS_PS_LGCY_MANDATORY');
      fnd_message.set_token('PARAM','PASSPORT_EXPIRY_DATE');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
   END IF;

   IF l_passport_rec.passport_cntry_code IS NULL  OR l_passport_rec.passport_cntry_code = FND_API.G_MISS_CHAR THEN
      fnd_message.set_name ('IGS', 'IGS_PS_LGCY_MANDATORY');
      fnd_message.set_token('PARAM','PASSPORT_CNTRY_CODE');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
   END IF;

   IF igs_ad_imp_026.Validate_passport_pub(api_pass_rec => l_passport_rec, p_err_code => l_error_code) THEN

        IGS_PE_PASSPORT_PKG.INSERT_ROW(
                         X_ROWID                    => l_rowid,
                         X_PASSPORT_ID              => x_passport_id ,
                         X_PERSON_ID                => l_passport_rec.person_id,
                         X_PASSPORT_NUMBER          => l_passport_rec.passport_number,
                         X_PASSPORT_EXPIRY_DATE     => l_passport_rec.passport_expiry_date,
                         X_PASSPORT_CNTRY_CODE      => l_passport_rec.passport_cntry_code  ,
                         X_ATTRIBUTE_CATEGORY       => NULL  ,
                         X_ATTRIBUTE1               => NULL,
                         X_ATTRIBUTE2               => NULL,
                         X_ATTRIBUTE3               => NULL,
                         X_ATTRIBUTE4               => NULL,
                         X_ATTRIBUTE5               => NULL,
                         X_ATTRIBUTE6               => NULL,
                         X_ATTRIBUTE7               => NULL,
                         X_ATTRIBUTE8               => NULL,
                         X_ATTRIBUTE9               => NULL,
                         X_ATTRIBUTE10              => NULL,
                         X_ATTRIBUTE11              => NULL,
                         X_ATTRIBUTE12              => NULL,
                         X_ATTRIBUTE13              => NULL,
                         X_ATTRIBUTE14              => NULL,
                         X_ATTRIBUTE15              => NULL,
                         X_ATTRIBUTE16              => NULL,
                         X_ATTRIBUTE17              => NULL,
                         X_ATTRIBUTE18              => NULL,
                         X_ATTRIBUTE19              => NULL,
                         X_ATTRIBUTE20              => NULL,
                         X_MODE                     => 'R'
                         );


 ELSE
     RAISE FND_API.G_EXC_ERROR;
 END IF;

-- End Here

    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO Create_Passport_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                x_msg_data := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', l_error_code, 8405);
		x_msg_count := 1;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO Create_Passport_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                    (          p_count                 =>      x_msg_count             ,
                               p_data                  =>      x_msg_data
                    );
    WHEN OTHERS THEN
                ROLLBACK TO Create_Passport_PUB;
                FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED, l_app, l_message_name);

                x_msg_count := 1;

		IF l_message_name IN('IGS_PE_VIS_ASOC_PASS_EXP','IGS_EN_INV','IGS_PS_LGCY_MANDATORY', 'IGS_PE_VIPS_UPD_ERR','IGS_PE_VIPS_COL_NONUPD') THEN
                  x_return_status := FND_API.G_RET_STS_ERROR ;
                  x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_FIRST, p_encoded => 'F');
		ELSIF l_message_name  = 'FORM_RECORD_DELETED' THEN
                  x_return_status := FND_API.G_RET_STS_ERROR ;
                  fnd_message.set_name ('IGS', 'IGS_EN_INV');
                  fnd_message.set_token('PARAM','PERSON_ID');
                  igs_ge_msg_stack.add;
                  x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST, p_encoded => 'F');
                ELSIF l_message_name = 'IGS_PE_PASSPORT_DUP_EXISTS' THEN
                  x_return_status := FND_API.G_RET_STS_ERROR ;
                  fnd_message.set_name ('IGS', 'IGS_PE_UNIQUE_FAILED');
                  fnd_message.set_token('COLUMN','PERSON_ID,PASSPORT_CNTRY_CODE,PASSPORT_NUMBER');
                  igs_ge_msg_stack.add;
                  x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST, p_encoded => 'F');
                ELSE
                  x_msg_data := ' ' || SQLERRM;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                END IF;


END Create_Passport;



-- Start of comments
--        API name         : Update_Passport
--        Type             : Public
--        Function         :
--        Pre-reqs         : None.
--        Parameters       :
--        IN               :      p_api_version           IN NUMBER        Required
--                                p_init_msg_list         IN VARCHAR2         Optional
--                                Default = FND_API.G_FALSE
--                                p_commit                IN VARCHAR2        Optional
--                                Default = FND_API.G_FALSE
--                                Default = FND_API.G_VALID_LEVEL_FULL
--                                p_passport_rec          IN passport_rec_type
--
--
--        OUT                :    x_return_status         OUT        VARCHAR2(1)
--                                x_msg_count             OUT        NUMBER
--                                x_msg_data              OUT        VARCHAR2(2000)
--
--
--
--        Version        : Current version        x.x
--                                Changed....
--                          previous version        y.y
--                                Changed....
--                          .
--                          .
--                          Initial version         1.0
--
--        Notes          :
--
-- End of comments

PROCEDURE Update_Passport
(         p_api_version                   IN        NUMBER,
          p_init_msg_list                 IN        VARCHAR2 DEFAULT FND_API.G_FALSE,
          p_commit                        IN        VARCHAR2 DEFAULT FND_API.G_FALSE,
          x_return_status                 OUT   NOCOPY    VARCHAR2,
          x_msg_count                     OUT   NOCOPY    NUMBER,
          x_msg_data                      OUT   NOCOPY    VARCHAR2,
          p_passport_rec                  IN        passport_rec_type
)
IS

l_api_name                        CONSTANT VARCHAR2(30)        := 'Update_Passport';
l_api_version                   CONSTANT NUMBER                 := 1.0;

CURSOR null_handlng_cur(cp_pass  IN  passport_rec_type) IS
SELECT rowid,
       PASSPORT_ID, PERSON_ID, PASSPORT_NUMBER, PASSPORT_EXPIRY_DATE, PASSPORT_CNTRY_CODE
FROM  IGS_PE_PASSPORT
WHERE   passport_id = cp_pass.passport_id FOR UPDATE NOWAIT;

dup_pass_rec null_handlng_cur%ROWTYPE;
l_error_code VARCHAR2(30);

l_message_name VARCHAR2(30);
l_app          VARCHAR2(50);

l_passport_rec      passport_rec_type;

E_RESOURCE_BUSY                 EXCEPTION;
PRAGMA EXCEPTION_INIT(E_RESOURCE_BUSY, -54);

BEGIN
    l_passport_rec := p_passport_rec;
    l_passport_rec.passport_expiry_date := TRUNC(l_passport_rec.passport_expiry_date);
    SAVEPOINT        Update_Passport_PUB;
    IF NOT FND_API.Compatible_API_Call (         l_api_version,
                                                 p_api_version,
                                                 l_api_name,
                                                 G_PKG_NAME )
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Start here

   x_msg_count := 0;

   IF p_passport_rec.passport_id IS NULL OR p_passport_rec.passport_id = FND_API.G_MISS_NUM THEN
      fnd_message.set_name ('IGS', 'IGS_PS_LGCY_MANDATORY');
      fnd_message.set_token('PARAM','PASSPORT_ID');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
   END IF;

   OPEN null_handlng_cur(p_passport_rec);
   FETCH null_handlng_cur INTO dup_pass_rec;
   IF null_handlng_cur%NOTFOUND THEN
      fnd_message.set_name ('IGS', 'IGS_PE_VIPS_UPD_ERR');
      fnd_message.set_token('VALUES','PASSPORT_ID=' || p_passport_rec.passport_id );
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
   END IF;
   CLOSE null_handlng_cur;

   IF l_passport_rec.person_id = FND_API.G_MISS_NUM THEN
    fnd_message.set_name ('IGS', 'IGS_PS_LGCY_MANDATORY');
    fnd_message.set_token('PARAM','PERSON_ID');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
   ELSIF l_passport_rec.person_id IS NULL THEN
    l_passport_rec.person_id := dup_pass_rec.person_id;
   ELSIF l_passport_rec.person_id <> dup_pass_rec.person_id THEN
    fnd_message.set_name ('IGS', 'IGS_PE_VIPS_COL_NONUPD');
    fnd_message.set_token('COLUMN','PERSON_ID');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
   END IF;

   IF l_passport_rec.passport_number = FND_API.G_MISS_CHAR THEN
    fnd_message.set_name ('IGS', 'IGS_PS_LGCY_MANDATORY');
    fnd_message.set_token('PARAM','PASSPORT_NUMBER');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
   ELSIF l_passport_rec.passport_number IS NULL THEN
    l_passport_rec.passport_number := dup_pass_rec.passport_number;
   ELSIF l_passport_rec.passport_number <> dup_pass_rec.passport_number THEN
    fnd_message.set_name ('IGS', 'IGS_PE_VIPS_COL_NONUPD');
    fnd_message.set_token('COLUMN','PASSPORT_NUMBER');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
   END IF;

   IF l_passport_rec.passport_expiry_date = FND_API.G_MISS_DATE THEN
    fnd_message.set_name ('IGS', 'IGS_PS_LGCY_MANDATORY');
    fnd_message.set_token('PARAM','PASSPORT_EXPIRY_DATE');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
   ELSIF l_passport_rec.passport_expiry_date IS NULL THEN
    l_passport_rec.passport_expiry_date := dup_pass_rec.passport_expiry_date;
   END IF;

   IF l_passport_rec.passport_cntry_code = FND_API.G_MISS_CHAR THEN
    fnd_message.set_name ('IGS', 'IGS_PS_LGCY_MANDATORY');
    fnd_message.set_token('PARAM','PASSPORT_CNTRY_CODE');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
   ELSIF l_passport_rec.passport_cntry_code IS NULL THEN
    l_passport_rec.passport_cntry_code := dup_pass_rec.passport_cntry_code;
   ELSIF l_passport_rec.passport_cntry_code <> dup_pass_rec.passport_cntry_code THEN
    fnd_message.set_name ('IGS', 'IGS_PE_VIPS_COL_NONUPD');
    fnd_message.set_token('COLUMN','PASSPORT_CNTRY_CODE');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
   END IF;

   IF igs_ad_imp_026.Validate_passport_pub(api_pass_rec => l_passport_rec, p_err_code => l_error_code) THEN

                     igs_pe_passport_pkg.update_row(
                          X_ROWID                   => dup_pass_rec.rowid,
                          X_PASSPORT_ID             => dup_pass_rec.passport_id,
                          X_PERSON_ID               => l_passport_rec.person_id,
                          X_PASSPORT_NUMBER         => l_passport_rec.passport_number,
                          X_PASSPORT_EXPIRY_DATE    => l_passport_rec.passport_expiry_date,
                          X_PASSPORT_CNTRY_CODE     => l_passport_rec.passport_cntry_code,
                          X_ATTRIBUTE_CATEGORY      => NULL,
                          X_ATTRIBUTE1              => NULL,
                          X_ATTRIBUTE2              => NULL,
                          X_ATTRIBUTE3              => NULL,
                          X_ATTRIBUTE4              => NULL,
                          X_ATTRIBUTE5              => NULL,
                          X_ATTRIBUTE6              => NULL,
                          X_ATTRIBUTE7              => NULL,
                          X_ATTRIBUTE8              => NULL,
                          X_ATTRIBUTE9              => NULL,
                          X_ATTRIBUTE10             => NULL,
                          X_ATTRIBUTE11             => NULL,
                          X_ATTRIBUTE12             => NULL,
                          X_ATTRIBUTE13             => NULL,
                          X_ATTRIBUTE14             => NULL,
                          X_ATTRIBUTE15             => NULL,
                          X_ATTRIBUTE16             => NULL,
                          X_ATTRIBUTE17             => NULL,
                          X_ATTRIBUTE18             => NULL,
                          X_ATTRIBUTE19             => NULL,
                          X_ATTRIBUTE20             => NULL,
                          X_MODE                    => 'R'
                                          );
    ELSE
	  RAISE FND_API.G_EXC_ERROR;
    END IF;

-- End Here

    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

EXCEPTION
    WHEN E_RESOURCE_BUSY THEN
                ROLLBACK TO Update_Passport_PUB;
                fnd_message.set_name ('IGS', 'IGS_GE_RECORD_LOCKED');
                igs_ge_msg_stack.add;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_FIRST, p_encoded => 'F');
                x_msg_count := 1;
    WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO Update_Passport_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                x_msg_data := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', l_error_code, 8405);
                x_msg_count := 1;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO Update_Passport_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                    (          p_count                 =>      x_msg_count             ,
                               p_data                  =>      x_msg_data
                    );
    WHEN OTHERS THEN
                ROLLBACK TO Update_Passport_PUB;

                FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED, l_app, l_message_name);

                x_msg_count := 1;
                IF l_message_name IN('IGS_PE_VIS_ASOC_PASS_EXP','IGS_PE_PASSPORT_DUP_EXISTS','IGS_EN_INV','IGS_PS_LGCY_MANDATORY', 'IGS_PE_VIPS_UPD_ERR','IGS_PE_VIPS_COL_NONUPD') THEN
                  x_return_status := FND_API.G_RET_STS_ERROR ;
                  x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_FIRST, p_encoded => 'F');
                ELSE
                  x_msg_data := ' ' || SQLERRM;
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                END IF;

END Update_Passport;

END IGS_PE_VISAPASS_PUB;

/
