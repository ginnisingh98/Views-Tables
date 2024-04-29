--------------------------------------------------------
--  DDL for Package Body IEX_CASE_UTL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_CASE_UTL_PUB" as
/* $Header: iexucasb.pls 120.3.12010000.3 2008/08/20 10:51:05 snuthala ship $ */
-- Start of Comments
-- Package name     : IEX_CASE_UTL_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME      CONSTANT    VARCHAR2(100):=  'IEX_CASE_UTL_PUB';
G_FILE_NAME     CONSTANT    VARCHAR2(12) := 'iexucasb.pls';


/**Name   AddInvalidArgMsg
  **Appends to a message  the api name, parameter name and parameter Value
 */

--PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
PG_DEBUG NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

PROCEDURE AddInvalidArgMsg
  ( p_api_name	    IN	VARCHAR2,
    p_param_value	IN	VARCHAR2,
    p_param_name	IN	VARCHAR2 ) IS
BEGIN
   IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
      fnd_message.set_name('IEX', 'IEX_API_ALL_INVALID_ARGUMENT');
      fnd_message.set_token('API_NAME', p_api_name);
      fnd_message.set_token('VALUE', p_param_value);
      fnd_message.set_token('PARAMETER', p_param_name);
      fnd_msg_pub.add;
   END IF;


END AddInvalidArgMsg;

/**Name   AddMissingArgMsg
  **Appends to a message  the api name, parameter name and parameter Value
 */

PROCEDURE AddMissingArgMsg
  ( p_api_name	    IN	VARCHAR2,
    p_param_name	IN	VARCHAR2 )IS
BEGIN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('IEX', 'IEX_API_ALL_MISSING_PARAM');
            fnd_message.set_token('API_NAME', p_api_name);
            fnd_message.set_token('MISSING_PARAM', p_param_name);
            fnd_msg_pub.add;
        END IF;
END AddMissingArgMsg;

/**Name   AddNullArgMsg
**Appends to a message  the api name, parameter name and parameter Value
*/

PROCEDURE AddNullArgMsg
  ( p_api_name	    IN	VARCHAR2,
    p_param_name	IN	VARCHAR2 )IS
BEGIN
   IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
      fnd_message.set_name('IEX', 'IEX_API_ALL_NULL_PARAMETER');
      fnd_message.set_token('API_NAME', p_api_name);
      fnd_message.set_token('NULL_PARAM', p_param_name);
      fnd_msg_pub.add;
   END IF;


END AddNullArgMsg;

/**Name   AddFailMsg
  **Appends to a message  the name of the object anf the operation (insert, update ,delete)
*/
PROCEDURE AddfailMsg
  ( p_object	    IN	VARCHAR2,
    p_operation 	IN	VARCHAR2 ) IS

BEGIN
      fnd_message.set_name('IEX', 'IEX_FAILED_OPERATION');
      fnd_message.set_token('OBJECT',    p_object);
      fnd_message.set_token('OPERATION', p_operation);
      fnd_msg_pub.add;

END    AddfailMsg;

/**Name   Converts Case record type from public to PVT **/
Procedure  Convert_case_Record (
                    p_cas_rec IN iex_case_utl_pub.cas_Rec_Type,
                    x_cas_rec OUT NOCOPY iex_cases_pvt.cas_Rec_Type) IS
Begin
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.LogMessage('Convert_case_Record: ' || '*********Start of Convert Case record *********');
     END IF;
          x_cas_rec.CAS_ID                 := p_cas_rec.CAS_ID;
          x_cas_rec.CASE_NUMBER            := p_cas_rec.CASE_NUMBER;
          x_cas_rec.ACTIVE_FLAG            := p_cas_rec.ACTIVE_FLAG ;
          x_cas_rec.PARTY_ID               := p_cas_rec.party_id;
          x_cas_rec.ORIG_CAS_ID            := p_cas_rec.orig_cas_id;
          x_cas_rec.CASE_STATE             := p_cas_rec.CASE_STATE;
          x_cas_rec.STATUS_CODE            := p_cas_rec.STATUS_CODE;
          x_cas_rec.OBJECT_VERSION_NUMBER  := p_cas_rec.OBJECT_VERSION_NUMBER;
          x_cas_rec.CASE_ESTABLISHED_DATE  := p_cas_rec.CASE_ESTABLISHED_DATE;
          x_cas_rec.CASE_CLOSING_DATE      := p_cas_rec.CASE_CLOSING_DATE;
          x_cas_rec.OWNER_RESOURCE_ID      := p_cas_rec.OWNER_RESOURCE_ID;
          x_cas_rec.ACCESS_RESOURCE_ID     := p_cas_rec.ACCESS_RESOURCE_ID;
          x_cas_rec.COMMENTS               :=P_CAS_REC.COMMENTS;
          x_cas_rec.REQUEST_ID             := p_cas_rec.REQUEST_ID;
          x_cas_rec.PROGRAM_APPLICATION_ID := p_cas_rec.PROGRAM_APPLICATION_ID;
          x_cas_rec.PROGRAM_ID             := p_cas_rec.PROGRAM_ID;
          x_cas_rec.PROGRAM_UPDATE_DATE    := p_cas_rec.PROGRAM_UPDATE_DATE;
          x_cas_rec.ATTRIBUTE_CATEGORY     := p_cas_rec.ATTRIBUTE_CATEGORY;
          x_cas_rec.ATTRIBUTE1             := p_cas_rec.ATTRIBUTE1;
          x_cas_rec.ATTRIBUTE2             := p_cas_rec.ATTRIBUTE2;
          x_cas_rec.ATTRIBUTE3             := p_cas_rec.ATTRIBUTE3;
          x_cas_rec.ATTRIBUTE4             := p_cas_rec.ATTRIBUTE4;
          x_cas_rec.ATTRIBUTE5             := p_cas_rec.ATTRIBUTE5;
          x_cas_rec.ATTRIBUTE6             := p_cas_rec.ATTRIBUTE6;
          x_cas_rec.ATTRIBUTE7             := p_cas_rec.ATTRIBUTE7;
          x_cas_rec.ATTRIBUTE8             := p_cas_rec.ATTRIBUTE8;
          x_cas_rec.ATTRIBUTE9             := p_cas_rec.ATTRIBUTE9;
          x_cas_rec.ATTRIBUTE10            := p_cas_rec.ATTRIBUTE10;
          x_cas_rec.ATTRIBUTE11            := p_cas_rec.ATTRIBUTE11;
          x_cas_rec.ATTRIBUTE12            := p_cas_rec.ATTRIBUTE12;
          x_cas_rec.ATTRIBUTE13            := p_cas_rec.ATTRIBUTE13;
          x_cas_rec.ATTRIBUTE14            := p_cas_rec.ATTRIBUTE14;
          x_cas_rec.ATTRIBUTE15            := p_cas_rec.ATTRIBUTE15;
          x_cas_rec.CREATED_BY             := p_cas_rec.CREATED_BY ;
          x_cas_rec.CREATION_DATE             := p_cas_rec.CREATION_DATE;
          x_cas_rec.LAST_UPDATED_BY           := p_cas_rec.LAST_UPDATED_BY ;
          x_cas_rec.LAST_UPDATE_DATE          :=  p_cas_rec.LAST_UPDATE_DATE;
          x_cas_rec.LAST_UPDATE_LOGIN         := p_cas_rec.LAST_UPDATE_LOGIN;
          x_cas_rec.PREDICTED_RECOVERY_AMOUNT := p_cas_rec.PREDICTED_RECOVERY_AMOUNT;
          x_cas_rec.PREDICTED_CHANCE          := p_cas_rec.PREDICTED_CHANCE;
--         IF PG_DEBUG < 10  THEN
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            iex_debug_pub.LogMessage('Convert_case_Record: ' || '*********End of Convert Case record *********');
         END IF;

end  Convert_case_Record;


/**Name   Converts Case record type from public to PVT **/
Procedure  Convert_case_object_Record (
                    p_attribute_rec IN iex_case_utl_pub.cas_Rec_Type,
                    x_case_object_rec OUT NOCOPY iex_case_objects_pvt.case_object_Rec_Type)IS
Begin
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.LogMessage('Convert_case_object_Record: ' || '*********End of Convert case object Record record *********');
      END IF;
          x_case_object_rec.ACTIVE_FLAG            := p_attribute_rec.ACTIVE_FLAG ;
          x_case_object_rec.REQUEST_ID             := p_attribute_rec.REQUEST_ID;
          x_case_object_rec.PROGRAM_APPLICATION_ID := p_attribute_rec.PROGRAM_APPLICATION_ID;
          x_case_object_rec.PROGRAM_ID             := p_attribute_rec.PROGRAM_ID;
          x_case_object_rec.PROGRAM_UPDATE_DATE    := p_attribute_rec.PROGRAM_UPDATE_DATE;
          x_case_object_rec.ATTRIBUTE_CATEGORY     := p_attribute_rec.ATTRIBUTE_CATEGORY;
          x_case_object_rec.ATTRIBUTE1             := p_attribute_rec.ATTRIBUTE1;
          x_case_object_rec.ATTRIBUTE2             := p_attribute_rec.ATTRIBUTE2;
          x_case_object_rec.ATTRIBUTE3             := p_attribute_rec.ATTRIBUTE3;
          x_case_object_rec.ATTRIBUTE4             := p_attribute_rec.ATTRIBUTE4;
          x_case_object_rec.ATTRIBUTE5             := p_attribute_rec.ATTRIBUTE5;
          x_case_object_rec.ATTRIBUTE6             := p_attribute_rec.ATTRIBUTE6;
          x_case_object_rec.ATTRIBUTE7             := p_attribute_rec.ATTRIBUTE7;
          x_case_object_rec.ATTRIBUTE8             := p_attribute_rec.ATTRIBUTE8;
          x_case_object_rec.ATTRIBUTE9             := p_attribute_rec.ATTRIBUTE9;
          x_case_object_rec.ATTRIBUTE10            := p_attribute_rec.ATTRIBUTE10;
          x_case_object_rec.ATTRIBUTE11            := p_attribute_rec.ATTRIBUTE11;
          x_case_object_rec.ATTRIBUTE12            := p_attribute_rec.ATTRIBUTE12;
          x_case_object_rec.ATTRIBUTE13            := p_attribute_rec.ATTRIBUTE13;
          x_case_object_rec.ATTRIBUTE14            := p_attribute_rec.ATTRIBUTE14;
          x_case_object_rec.ATTRIBUTE15            := p_attribute_rec.ATTRIBUTE15;
          x_case_object_rec.CREATED_BY             := p_attribute_rec.CREATED_BY ;
          x_case_object_rec.CREATION_DATE          := p_attribute_rec.CREATION_DATE;
          x_case_object_rec.LAST_UPDATED_BY        := p_attribute_rec.LAST_UPDATED_BY ;
          x_case_object_rec.LAST_UPDATE_DATE       := p_attribute_rec.LAST_UPDATE_DATE;
          x_case_object_rec.LAST_UPDATE_LOGIN      := p_attribute_rec.LAST_UPDATE_LOGIN;

--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.LogMessage('Convert_case_object_Record: ' || '*********Start of Convert case object Record record *********');
      END IF;
end  Convert_case_object_Record;

/**Name   Converts Case def record type from public to PVT **/
Procedure  Convert_case_def_Record (
                    p_attribute_rec  IN iex_case_utl_pub.cas_Rec_Type,
                    x_case_def_rec   OUT NOCOPY iex_case_definitions_pvt.CASE_DEFINITION_Rec_Type) IS
Begin
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.LogMessage('Convert_case_def_Record: ' || '*********End of Convert case def Record record *********');
      END IF;
          x_case_def_rec.ACTIVE_FLAG            := p_attribute_rec.ACTIVE_FLAG ;
          x_case_def_rec.REQUEST_ID             := p_attribute_rec.REQUEST_ID;
          x_case_def_rec.PROGRAM_APPLICATION_ID := p_attribute_rec.PROGRAM_APPLICATION_ID;
          x_case_def_rec.PROGRAM_ID             := p_attribute_rec.PROGRAM_ID;
          x_case_def_rec.PROGRAM_UPDATE_DATE    := p_attribute_rec.PROGRAM_UPDATE_DATE;
          x_case_def_rec.ATTRIBUTE_CATEGORY     := p_attribute_rec.ATTRIBUTE_CATEGORY;
          x_case_def_rec.ATTRIBUTE1             := p_attribute_rec.ATTRIBUTE1;
          x_case_def_rec.ATTRIBUTE2             := p_attribute_rec.ATTRIBUTE2;
          x_case_def_rec.ATTRIBUTE3             := p_attribute_rec.ATTRIBUTE3;
          x_case_def_rec.ATTRIBUTE4             := p_attribute_rec.ATTRIBUTE4;
          x_case_def_rec.ATTRIBUTE5             := p_attribute_rec.ATTRIBUTE5;
          x_case_def_rec.ATTRIBUTE6             := p_attribute_rec.ATTRIBUTE6;
          x_case_def_rec.ATTRIBUTE7             := p_attribute_rec.ATTRIBUTE7;
          x_case_def_rec.ATTRIBUTE8             := p_attribute_rec.ATTRIBUTE8;
          x_case_def_rec.ATTRIBUTE9             := p_attribute_rec.ATTRIBUTE9;
          x_case_def_rec.ATTRIBUTE10            := p_attribute_rec.ATTRIBUTE10;
          x_case_def_rec.ATTRIBUTE11            := p_attribute_rec.ATTRIBUTE11;
          x_case_def_rec.ATTRIBUTE12            := p_attribute_rec.ATTRIBUTE12;
          x_case_def_rec.ATTRIBUTE13            := p_attribute_rec.ATTRIBUTE13;
          x_case_def_rec.ATTRIBUTE14            := p_attribute_rec.ATTRIBUTE14;
          x_case_def_rec.ATTRIBUTE15            := p_attribute_rec.ATTRIBUTE15;
          x_case_def_rec.CREATED_BY             := p_attribute_rec.CREATED_BY ;
          x_case_def_rec.CREATION_DATE          := p_attribute_rec.CREATION_DATE;
          x_case_def_rec.LAST_UPDATED_BY        := p_attribute_rec.LAST_UPDATED_BY ;
          x_case_def_rec.LAST_UPDATE_DATE       := p_attribute_rec.LAST_UPDATE_DATE;
          x_case_def_rec.LAST_UPDATE_LOGIN      := p_attribute_rec.LAST_UPDATE_LOGIN;

--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.LogMessage('Convert_case_def_Record: ' || '*********Start of Convert case def Record record *********');
      END IF;
end  Convert_case_def_Record;


/* Name   PopulateCaseDefTbl
** Populates  case definition for the given cas_id
*/
Procedure PopulateCaseDefTbl
         ( p_cas_id                     IN  NUMBER,
           X_case_definition_tbl        OUT NOCOPY CASE_DEFINITION_TBL_TYPE
         ) IS

Cursor get_case_def is
       Select column_name,column_value,table_name
       From   iex_case_definitions
       where  cas_id =p_cas_id
         	    and active_flag ='Y';
 tbl_ctr NUMBER ;
BEGIN
--   IF PG_DEBUG < 10  THEN
   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage ('*********Start of Procedure =>PopulateCaseDefTbl ********* ');
   END IF;
    tbl_ctr := 1;
  	FOR get_case_def_rec IN get_case_def LOOP
        x_case_definition_tbl(tbl_ctr).column_name :=get_case_def_rec.column_name ;
        x_case_definition_tbl(tbl_ctr).column_value:=get_case_def_rec.column_value ;
        x_case_definition_tbl(tbl_ctr).table_name  :=get_case_def_rec.table_name ;
        tbl_ctr := tbl_ctr +1;
     END LOOP;
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage ('*********End of Procedure =>PopulateCaseDefTbl ********* ');
     END IF;
 END PopulateCaseDefTbl;

/** Populate Case Record **/
PROCEDURE PopCaseRec(p_cas_id     IN NUMBER,
                     x_cas_rec    OUT NOCOPY iex_cases_pvt.cas_rec_type) IS
Cursor Case_rec_cur (p_cas_id in number)is
       select * from iex_cases_all_b
       where  cas_id =p_cas_id
         	    and active_flag ='Y';

Cursor Case_comments_cur (p_cas_id in number)is
       select comments from iex_cases_tl
       where  cas_id =p_cas_id and
       userenv('LANG') in (LANGUAGE, SOURCE_LANG)
       and active_flag ='Y';

BEGIN
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage ('*********Start of Procedure =>PopCaseRec ********* ');
      END IF;
      FOR get_cas_rec in Case_rec_cur(p_cas_id)  LOOP

          x_cas_rec.ORIG_CAS_ID  := p_cas_id ;
          x_cas_rec.CASE_STATE   := 'OPEN' ;
          x_cas_rec.STATUS_CODE  := 'CURRENT' ;
          x_cas_rec.ACTIVE_FLAG  :='Y';

          x_cas_rec.PARTY_ID             := get_cas_rec.PARTY_ID ;
          x_cas_rec.CASE_NUMBER             := get_cas_rec.CASE_NUMBER ;
          x_cas_rec.CASE_ESTABLISHED_DATE   := get_cas_rec.CASE_ESTABLISHED_DATE ;
          x_cas_rec.OWNER_RESOURCE_ID       := get_cas_rec.OWNER_RESOURCE_ID;
          x_cas_rec.ACCESS_RESOURCE_ID      := get_cas_rec.ACCESS_RESOURCE_ID;
          x_cas_rec.REQUEST_ID              := get_cas_rec.REQUEST_ID;
          x_cas_rec.PROGRAM_APPLICATION_ID  := get_cas_rec.PROGRAM_APPLICATION_ID;
          x_cas_rec.PROGRAM_ID              := get_cas_rec.PROGRAM_ID;
          x_cas_rec.PROGRAM_UPDATE_DATE     := get_cas_rec.PROGRAM_UPDATE_DATE;
          x_cas_rec.ATTRIBUTE_CATEGORY      := get_cas_rec.ATTRIBUTE_CATEGORY;
          x_cas_rec.ATTRIBUTE1              := get_cas_rec.ATTRIBUTE1;
          x_cas_rec.ATTRIBUTE2              := get_cas_rec.ATTRIBUTE2;
          x_cas_rec.ATTRIBUTE3              := get_cas_rec.ATTRIBUTE3;
          x_cas_rec.ATTRIBUTE4              := get_cas_rec.ATTRIBUTE4;
          x_cas_rec.ATTRIBUTE5              := get_cas_rec.ATTRIBUTE5;
          x_cas_rec.ATTRIBUTE6              := get_cas_rec.ATTRIBUTE6;
          x_cas_rec.ATTRIBUTE7              := get_cas_rec.ATTRIBUTE7;
          x_cas_rec.ATTRIBUTE8                := get_cas_rec.ATTRIBUTE8;
          x_cas_rec.ATTRIBUTE9                := get_cas_rec.ATTRIBUTE9;
          x_cas_rec.ATTRIBUTE10               := get_cas_rec.ATTRIBUTE10;
          x_cas_rec.ATTRIBUTE11               := get_cas_rec.ATTRIBUTE11;
          x_cas_rec.ATTRIBUTE12               := get_cas_rec.ATTRIBUTE12;
          x_cas_rec.ATTRIBUTE13               := get_cas_rec.ATTRIBUTE13;
          x_cas_rec.ATTRIBUTE14               := get_cas_rec.ATTRIBUTE14;
          x_cas_rec.ATTRIBUTE15               := get_cas_rec.ATTRIBUTE15;
          x_cas_rec.CLOSE_REASON              := get_cas_rec.CLOSE_REASON;
          x_cas_rec.org_id                    :=get_cas_rec.org_id;
          x_cas_rec.PREDICTED_RECOVERY_AMOUNT := get_cas_rec.PREDICTED_RECOVERY_AMOUNT;
          x_cas_rec.PREDICTED_CHANCE          := get_cas_rec.PREDICTED_CHANCE;

      END LOOP;
      --get comments
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage ('PopCaseRec: ' || 'Get comments for the case');
      END IF;
      For Case_comments_rec in Case_comments_cur (p_cas_id)
      LOOP
          x_cas_rec.COMMENTS               :=Case_comments_rec.COMMENTS;
      END LOOP;

--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage ('*********End of Procedure =>PopCaseRec *********');
     END IF;
END PopCaseRec;

/** Populate Case Definition Record **/
PROCEDURE PopulateCaseDefRec(p_table_name     IN  VARCHAR2,
                             p_column_name    IN  VARCHAR2,
                             p_column_value   IN  VARCHAR2,
                             p_cas_id         IN  NUMBER,
                             p_attribute_rec  IN  CAS_Rec_Type  := G_MISS_CAS_REC,
                             x_case_def_rec    OUT NOCOPY
                                  iex_case_definitions_pvt.case_definition_rec_type) IS
BEGIN
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage ('*********Start of Procedure =>PopulateCaseDefRec*********');
      END IF;
      --to populate attributes 1-15 and concurrent programs
      convert_case_def_record(p_attribute_rec,
                              x_case_def_rec);
      x_case_def_rec.table_name     := p_table_name;
      x_case_def_rec.column_name    := p_column_name;
      x_case_def_rec.column_value   := p_column_value;
      x_case_def_rec.cas_id         := p_cas_id;
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage ('*********End of Procedure =>PopulateCaseDefRec*********');
      END IF;
END  PopulateCaseDefRec;

/** Populate Case Record **/
PROCEDURE PopulateCaseRec(p_case_number           IN VARCHAR2 ,
                          p_comments              IN VARCHAR2 ,
                          p_org_id                IN NUMBER   ,
                          p_case_established_date IN DATE     ,
                          p_attribute_rec         IN  CAS_Rec_Type  := G_MISS_CAS_REC,
                          x_cas_rec               OUT NOCOPY iex_cases_pvt.cas_rec_type) IS
BEGIN
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage ('*********Start of Procedure =>PopulateCaseRec ********* ');
      END IF;
      --to populate attributes 1-15 and concurrent programs
      convert_case_record(p_attribute_rec,x_cas_rec);
      x_cas_rec.CASE_NUMBER            :=p_case_number;
      x_cas_rec.org_id                 :=p_org_id;
      x_cas_rec.COMMENTS               :=p_comments;
      x_cas_rec.case_established_date  :=p_case_established_date;

--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage ('*********End of Procedure =>PopulateCaseRec *********');
      END IF;
END PopulateCaseRec;

/** Populate Case Objects Record **/
PROCEDURE PopulateCaseObjectRec(p_object_code     IN  VARCHAR2,
                                p_object_id       IN  NUMBER,
                                p_cas_id          IN  NUMBER,
                                p_attribute_rec   IN  CAS_Rec_Type  := G_MISS_CAS_REC,
                                x_case_object_rec OUT NOCOPY
                                           iex_case_objects_pvt.case_object_rec_type)IS

BEGIN
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage ('*********Start of Procedure =>PopulateCaseObjectRec*********');
      END IF;
      --to populate attributes 1-15 and concurrent programs
      convert_case_object_record(p_attribute_rec,x_case_object_rec);

       x_case_object_rec.object_code         :=p_object_code;
       x_case_object_rec.object_id           :=p_object_id;
       x_case_object_rec.cas_id              :=p_cas_id ;
--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          IEX_DEBUG_PUB.LogMessage ('*********End of Procedure =>PopulateCaseObjectRec *********');
       END IF;

END  PopulateCaseObjectRec;

/* Name   CheckAdvanceDelinquencies
** Used by the OKL wrapper to decide whether to call createCaseObjects or
** reassign Case when Bill_to_address or any case attribute is changed
*/
Function CheckAdvanceDelinquencies
          (P_CaseID       IN NUMBER,
           x_del_id       OUT NOCOPY NUMBER
          )Return BOOLEAN IS


cursor c_writeoffs is
    Select del.delinquency_id
    from iex_delinquencies del,
         iex_writeoffs wrioff
    where del.case_id           = p_caseid
    and   wrioff.delinquency_id = del.delinquency_id

--Start of BUG 4408860
-- For Bug 4408860
--jsanju 06/05/05
-- we shpudl npot be looking for status ='CLOSE'
--since from iex.h, we do not have case delinquencies and
-- and the old delinquencies with case id has been update to status ='CLOSE'
    --and   del.status            <> 'CURRENT';
    and   del.status           NOT IN ('CURRENT','CLOSE');
--End of bug 4408860


cursor c_bankruptcies is
    Select del.delinquency_id
    from iex_delinquencies del,
         iex_bankruptcies bank
    where del.case_id           = p_caseid
    and   bank.delinquency_id   = del.delinquency_id
--Start of BUG 4408860
-- For Bug 4408860
--jsanju 06/05/05
-- we shpudl npot be looking for status ='CLOSE'
--since from iex.h, we do not have case delinquencies and
-- and the old delinquencies with case id has been update to status ='CLOSE'
    --and   del.status            <> 'CURRENT';
    and   del.status           NOT IN ('CURRENT','CLOSE');
--End of bug 4408860

cursor c_repossessions is
    Select del.delinquency_id
    from iex_delinquencies del,
         iex_repossessions repo
    where del.case_id           = p_caseid
    and   repo.delinquency_id   = del.delinquency_id
--Start of BUG 4408860
-- For Bug 4408860
--jsanju 06/05/05
-- we shpudl npot be looking for status ='CLOSE'
--since from iex.h, we do not have case delinquencies and
-- and the old delinquencies with case id has been update to status ='CLOSE'
    --and   del.status            <> 'CURRENT';
    and   del.status           NOT IN ('CURRENT','CLOSE');
--End of bug 4408860

cursor c_litigations is
    Select del.delinquency_id
    from iex_delinquencies del,
         iex_litigations litg
    where del.case_id           = p_caseid
    and   litg.delinquency_id   = del.delinquency_id
--Start of BUG 4408860
-- For Bug 4408860
--jsanju 06/05/05
-- we shpudl npot be looking for status ='CLOSE'
--since from iex.h, we do not have case delinquencies and
-- and the old delinquencies with case id has been update to status ='CLOSE'
    --and   del.status            <> 'CURRENT';
    and   del.status           NOT IN ('CURRENT','CLOSE');
--End of bug 4408860


Begin

     OPEN c_writeoffs;
     FETCH c_writeoffs INTO x_del_id;
     CLOSE c_writeoffs;

     If x_del_id IS NOT NULL THEN
        return TRUE;

     END IF;

     OPEN c_litigations;
     FETCH c_litigations INTO x_del_id;
     CLOSE c_litigations;

     If x_del_id IS NOT NULL THEN
        return TRUE;

     END IF;

     OPEN c_repossessions;
     FETCH c_repossessions INTO x_del_id;
     CLOSE c_repossessions;

     If x_del_id IS NOT NULL THEN
        return TRUE;

     END IF;

     OPEN c_bankruptcies;
     FETCH c_bankruptcies INTO x_del_id;
     CLOSE c_bankruptcies;

     If x_del_id IS NOT NULL THEN
        return TRUE;
     END IF;

    x_del_id := NULL;
    return FALSE;


EXCEPTION WHEN OTHERS THEN
     x_del_id := NULL;
     Return FALSE;

End CheckAdvanceDelinquencies;

/** Send notification to the agent who case has
 ** been reassigned
  */
  Procedure send_notification
   ( p_OldCaseID      IN NUMBER,
     p_NewCaseID      IN NUMBER,
     p_ContractNumber IN VARCHAR2,
     p_CaseAgent      IN VARCHAR2,
     x_return_status  OUT NOCOPY VARCHAR2) IS

  l_result        VARCHAR2(100);
  itemkey         VARCHAR2(1000);
  l_return_status VARCHAR2(100);


  BEGIN

           select iex_cases_all_b_s.nextval
           into itemkey
           from dual;

--           IF PG_DEBUG < 10  THEN
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              iex_debug_pub.logmessage ('send_notification: ' || 'item Key in send notification of iex_cas_utl_pub '
                                     || itemkey );
           END IF;

            wf_engine.createprocess(itemtype => 'IEXCASNF',
                                    itemkey  =>  itemkey,
                                    process => 'IEXCASNF');

            wf_engine.setitemattrnumber(itemtype => 'IEXCASNF',
                                        itemkey  =>  itemkey,
                                        aname    =>  'CASE_ID',
                                        avalue   =>  p_OldCaseID);

            wf_engine.setitemattrnumber(itemtype => 'IEXCASNF',
                                        itemkey  =>  itemkey,
                                        aname    =>  'NEW_CASE_ID',
                                        avalue   =>  p_NewCaseID);

            wf_engine.setitemattrtext(itemtype => 'IEXCASNF',
                                        itemkey  =>  itemkey,
                                        aname    =>  'CONTRACT_NUMBER',
                                        avalue   =>  p_ContractNumber);

            wf_engine.setitemattrtext(itemtype => 'IEXCASNF',
                                      itemkey  =>  itemkey,
                                      aname    =>  'CASE_AGENT',
                                      avalue   =>  p_CaseAgent);

           wf_engine.startprocess(itemtype => 'IEXCASNF',
                                  itemkey  =>  itemkey);

           wf_engine.ItemStatus(itemtype => 'IEXCASNF',
                                itemkey  =>  itemkey,
                                status   =>   l_return_status,
                                result   =>   l_result);


          if (l_return_status in ('COMPLETE', 'ACTIVE')) THEN
               x_return_status := 'S';
          else
              x_return_status := 'F';
          end if;
--          IF PG_DEBUG < 10  THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             iex_debug_PUB.logmessage ('send_notification: ' || 'send notification status ' || x_return_status);
          END IF;
EXCEPTION
WHEN OTHERS THEN
    x_return_status := 'F';

END  send_notification;

--******************Public routines****************************
/* Name   CheckCaseDef
** It Checks if all the elements of the case which defines a case are valid
** Values
*/
Function CheckCaseDef
          (P_case_definition_tbl       IN   CASE_DEFINITION_TBL_TYPE

          )Return BOOLEAN IS

  x_sql          VARCHAR2(32767);
  x_count        NUMBER;

  -- clchang updated for sql bind var 05/07/2003
  vstr1          VARCHAR2(100) := 'SELECT COUNT(*) FROM ' ;
  vstr2          VARCHAR2(100) := ' WHERE ' ;
  vstr3          VARCHAR2(100) := ' = ';

BEGIN
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage ('********* Start of Function =>CheckCaseDef ******** ');
     END IF;
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('CheckCaseDef: ' || 'table count'||   P_case_definition_tbl.COUNT );
     END IF;



   	 FOR i IN 1..P_case_definition_tbl.COUNT LOOP
     /* If Column value or column name is Null return False */


        IF  ((P_case_definition_tbl(i).column_name  IS NOT NULL) and
             (P_case_definition_tbl(i).column_value IS NOT NULL)) THEN

--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           iex_debug_pub.logmessage ('CheckCaseDef: ' ||  'inside loop' ||P_case_definition_tbl(i).column_name||
                                     P_case_definition_tbl(i).column_value);
        END IF;

              If P_case_definition_tbl(i).table_name IS NOT NULL THEN

                   -- clchang updated for sql bind var 05/07/2003
                   --x_sql := 'SELECT COUNT(*) FROM ' || P_case_definition_tbl(i).table_name ;
                   --x_sql := x_sql || ' WHERE '      || P_case_definition_tbl(i).column_name|| ' = ';
                   x_sql := vstr1 || P_case_definition_tbl(i).table_name ;
                   x_sql := x_sql || vstr2  || P_case_definition_tbl(i).column_name|| vstr3;
                   -- end updated

                   IF P_case_definition_tbl(i).data_type = g_varchar2 THEN
                      x_sql := x_sql || '''' || P_case_definition_tbl(i).column_value || '''';
                   ELSE
                      x_sql := x_sql || P_case_definition_tbl(i).column_value;
                   END IF;
--                   IF PG_DEBUG < 10  THEN
                   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                      IEX_DEBUG_PUB.LogMessage ('CheckCaseDef: ' || 'SQL  =>'|| x_sql);
                   END IF;
                   BEGIN
                        EXECUTE IMMEDIATE x_sql INTO x_count;
                        If x_count =0 THEN
--                           IF PG_DEBUG < 10  THEN
                           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                              IEX_DEBUG_PUB.LogMessage ('CheckCaseDef: ' || 'Invalid Case defintion');
                           END IF;
                           return FALSE;
                        End if;
                   EXCEPTION WHEN OTHERS THEN
--                       IF PG_DEBUG < 10  THEN
                       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                          IEX_DEBUG_PUB.LogMessage ('CheckCaseDef: ' || 'In Exception When Others =>'||SQLERRM);
                       END IF;
                       return FALSE;
                   END ;
               END IF; --if table name is not null
           ELSE -- else if column name or column value is null
--                IF PG_DEBUG < 10  THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                   IEX_DEBUG_PUB.LogMessage ('CheckCaseDef: ' || 'Column Name or column value is Null');
                END IF;
                return FALSE;
           END IF;  --if column name or column value is null
        END LOOP;
        Return TRUE;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage ('*************End of iex =>CheckCaseDef ******** ');
    END IF;
 END CheckCaseDef;

/* Name   GetCaseID
** Return matching case id for the given case definition
*/
Procedure GetCaseID
          (P_case_definition_tbl        IN   CASE_DEFINITION_TBL_TYPE
                                            ,
           x_cas_id                     OUT NOCOPY NUMBER    ) IS


 l_column_name   VARCHAR2(1000) :=P_case_definition_tbl(1).column_name;
 l_column_value  VARCHAR2(1000) :=P_case_definition_tbl(1).column_value;
 l_table_name    VARCHAR2(1000) :=P_case_definition_tbl(1).table_name;
 l_case_sql VARCHAR2(2000):= ' and exists (select null from iex_cases_all_b ICAS where ICAS.cas_id = a.cas_id'||
                             ' and ICAS.case_state='||'''OPEN''' ||
                             ' and ICAS.active_flag='||'''Y''' ||' ) ';

 -- clchang updated for sql bind var 05/07/2003
 vstr1           VARCHAR2 (2000):= ' select a.cas_id  from ';
 vstr2           VARCHAR2 (2000):= ' iex_case_definitions a ';
 vstr3           VARCHAR2 (2000):= ' where a.column_name = ' ;
 vstr4           VARCHAR2 (2000):= '''';
 vstr5           VARCHAR2 (2000):= ' and  a.column_value = ';
 vstr6           VARCHAR2 (2000):= ' and a.active_flag= ''Y'' ';
 l_first_sql     VARCHAR2 (2000);
 vstr7           VARCHAR2 (100) := ' and table_name=' ;
 l_table_clause  VARCHAR2 (100);
 /*
 l_first_sql VARCHAR2 (2000):=' select a.cas_id  from '||
                              ' iex_case_definitions a '||
                              ' where a.column_name ='   ||''''|| l_column_name  || ''''||
                              ' and  a.column_value ='    ||''''|| l_column_value || ''''||
                              ' and a.active_flag='||'''Y''';
  l_table_clause    VARCHAR2(100) := ' and table_name='  ||''''|| l_table_name   || '''' ;
 */

  -- for l_sql
  v_sql_str1     VARCHAR2(100) := ' and exists ( select null from ';
  v_sql_str2     VARCHAR2(100) := ' iex_case_definitions ';
  v_sql_str3     VARCHAR2(100) := ' where column_name = ';
  v_sql_str4     VARCHAR2(100) := ' and column_value = ' ;
  v_sql_str5     VARCHAR2(100) := ' and ';
  v_sql_str6     VARCHAR2(100) := '.cas_id= a.cas_id ' ;
  v_sql_str7     VARCHAR2(100) := '.active_flag= ''Y'' ' ;

  v_sql_str8     VARCHAR2(100) := ' and table_name= ';


 --

l_no_table_clause VARCHAR2(100) :=   ' and table_name IS NULL ';
l_end             VARCHAR2(10)  := ' )';
l_table_alias     VARCHAR2(100);
l_sql             VARCHAR2(32767);

-- if multiple rows are returned pick the first one
--since the dynamic sql may return more than 1 row
l_multiple_rows  VARCHAR2(32767) :='and rownum <2 ';

BEGIN
--   IF PG_DEBUG < 10  THEN
   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage ('*********Start of Procedure =>GetCaseID ********* ');
   END IF;

   -- clchang updated for sql bind var 05/07/2003
   l_first_sql := vstr1 || vstr2 ||
                  vstr3 || vstr4 || l_column_name || vstr4 ||
                  vstr5 || vstr4 || l_column_value || vstr4 ||
                  vstr6;

   l_table_clause := vstr7 || vstr4 || l_table_name || vstr4;

--   IF PG_DEBUG < 10  THEN
   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage ('l_first_sql='|| l_first_sql);
      IEX_DEBUG_PUB.LogMessage ('l_table_clause='|| l_table_clause);
   END IF;
   -- end

    x_cas_id := NULL;
    l_sql := l_first_sql ;

    /* check if table name passed is null  */
    if l_table_name is NOT NULL THEN
       l_sql :=l_sql ||l_table_clause;
    else
        l_sql :=l_sql ||l_no_table_clause;
    end if;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logMessage('GetCaseID: ' || 'First Sql Stmt =>'||l_sql);
    END IF;

  	FOR i IN 2..P_case_definition_tbl.COUNT LOOP

         l_table_alias :='ICDF'||i;
         l_column_name   :=P_case_definition_tbl(i).column_name;
         l_column_value  :=P_case_definition_tbl(i).column_value;
         l_table_name    :=P_case_definition_tbl(i).table_name;

         -- clchang updated for sql bind var 05/07/2003
         l_sql := l_sql || v_sql_str1 ||
                           v_sql_str2 || l_table_alias ||
                           v_sql_str3 || vstr4 || l_column_name ||  vstr4 ||
                           v_sql_str4 || vstr4 || l_column_value || vstr4 ||
                           v_sql_str5 || l_table_alias || v_sql_str6 ||
                           v_sql_str5 || l_table_alias || v_sql_str7 ;
        /*
         l_sql := l_sql  ||   ' and exists ( select null from '||
                              ' iex_case_definitions ' || l_table_alias  ||
                              ' where column_name ='   ||''''|| l_column_name  || ''''||
                              ' and column_value ='    ||''''|| l_column_value || ''''||
                              ' and '||l_table_alias   ||'.cas_id= ' ||'a.cas_id'||
                              ' and '||l_table_alias   ||'.active_flag='||'''Y''' ;
        */

--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage ('l_sql='|| l_sql);
        END IF;
        -- end updated

         /* check if table name passed is null  */
            if l_table_name is NOT NULL THEN
               -- clchang updated for sql bind var 05/07/2003
               l_sql := l_sql || v_sql_str8 || vstr4 ||
                                 l_table_name || vstr4 || l_end;
               /*
               l_sql :=l_sql || ' and table_name='   ||''''||
                                 l_table_name || ''''||l_end;
               */
--               IF PG_DEBUG < 10  THEN
               IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                  IEX_DEBUG_PUB.LogMessage ('l_sql='|| l_sql);
               END IF;
               -- end updated
            else
               l_sql :=l_sql ||l_no_table_clause||l_end;
            end if;
--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               iex_debug_pub.logMessage('GetCaseID: ' || '                        ');
            END IF;
--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               iex_debug_pub.logMessage('GetCaseID: ' || 'Sql Stmt =>'||l_sql);
            END IF;
    END LOOP;
    l_sql := l_sql ||l_case_sql;

    l_sql := l_sql ||l_multiple_rows ;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logMessage('GetCaseID: ' || '                        ');
    END IF;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logMessage('GetCaseID: ' || 'Final Sql  Stmt =>'||l_sql);
    END IF;
    BEGIN
        EXECUTE IMMEDIATE l_sql INTO x_cas_id;
    EXCEPTION
    WHEN OTHERS THEN
--          IF PG_DEBUG < 10  THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             IEX_DEBUG_PUB.LogMessage ('GetCaseID: ' || '*********IN WHEN OTHERS => '||SQLERRM ||' ********* ');
          END IF;
          x_cas_id := NULL;
    END;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage ('*********End of Procedure =>GetCaseID ********* ');
    END IF;
 END GetCaseID;


/* Name   CloseCase
**  api  : Current version 2.0
** Updates the status of a case. Also create a new case and updates the case objects to the new case
**  if specified ( the p_copy_objects parameter should be equal to 'Y')
** Required Parameters are
** a) p_Cas_id     --> Cas Id
** Optional Parameters
** a) p_copy_objects   --> default is 'N'. If 'Y' then create new case and copy all the case objects to
**                         the new case. If Value is 'N',then do not copy the case objects.
** p_close_date      -->Closing date of the case.
*/
PROCEDURE CloseCase(
          P_Api_Version_Number         IN  NUMBER,
          P_Init_Msg_List              IN  VARCHAR2   ,
          P_Commit                     IN  VARCHAR2  ,
          P_validation_level           IN  NUMBER     ,
          P_cas_id                     IN NUMBER,
          p_close_date                 IN DATE,
          p_copy_objects               IN VARCHAR2,
          p_cas_Rec                    IN cas_Rec_Type,
          X_Return_Status              OUT NOCOPY  VARCHAR2,
          X_Msg_Count                  OUT NOCOPY  NUMBER,
          X_Msg_Data                   OUT NOCOPY  VARCHAR2
          ) IS


l_api_name                CONSTANT VARCHAR2(30) := 'CloseCase';
l_api_name_full	          CONSTANT VARCHAR2(61) := g_pkg_name || '.' || l_api_name;
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_cas_new_id              NUMBER;
l_cas_id                  NUMBER :=p_cas_id;
l_closing_date            DATE :=p_close_Date;
l_case_comments           VARCHAR2(240);
l_object_version_number   NUMBER;
l_return_status           VARCHAR2(1);
l_msg_count               NUMBER;
l_msg_data                VARCHAR2(32767);
l_case_object_id          NUMBER;
l_case_definition_id      NUMBER;
l_cas_rec                 iex_cases_pvt.cas_rec_type
                                         := iex_cases_pvt.g_miss_cas_rec;
l_case_definition_rec            iex_case_definitions_pvt.case_definition_rec_type
                                         := iex_case_definitions_pvt.g_miss_case_definition_rec;
l_case_object_rec         iex_case_objects_pvt.case_object_rec_type
                                         := iex_case_objects_pvt.g_miss_case_object_rec;
l_case_definition_tbl     CASE_DEFINITION_TBL_TYPE
                                       DEFAULT G_MISS_CASE_DEF_TBL;

l_resource_tab iex_utilities.resource_tab_type;  -- added by ehuh Aug 1 2003
l_resource_id NUMBER   :=  nvl(fnd_profile.value('IEX_STRY_DEFAULT_RESOURCE'),0);

Cursor get_case_objects_obj_ver_num (p_cas_id in number) is
       select object_version_number,
               case_object_id
       from iex_case_objects
       where  cas_id =p_cas_id
	  and active_flag ='Y';

 BEGIN
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logMessage('CloseCase: ' || '---------------------------------');
     END IF;
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage ('CloseCase: ' || '*********Start of Procedure => '||l_api_name||' *********');
     END IF;
      -- Standard Start of API savepoint
      SAVEPOINT CLOSECASE_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                           	               p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logMessage('CloseCase: ' || 'After Api compatability Check');
     END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- API body
      --
      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('IEX', 'IEX_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logMessage('CloseCase: ' || 'After FND_GLOBAL_USER Check');
      END IF;

      -- Item level validation
      IF (p_validation_level > fnd_api.g_valid_level_none) THEN

         -- Check for valid cas_id
         BEGIN
              IF (l_cas_id IS NOT NULL) AND (l_cas_id <> FND_API.G_MISS_NUM) THEN
                 --May have to check for status_code too.
                  SELECT cas_id,object_version_number
                  INTO l_cas_id,l_object_version_number
                  FROM iex_cases_all_b
                  WHERE cas_id      = p_cas_id
                  AND   case_state  = 'OPEN'
	             and active_flag ='Y';
               ELSE
                   AddMissingArgMsg(
                          p_api_name    =>  l_api_name_full,
                          p_param_name  =>  'p_object_id' );
                    RAISE FND_API.G_EXC_ERROR;
               END IF;
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
                    AddInvalidArgMsg(
                          p_api_name    =>  l_api_name_full,
                          p_param_name  =>  'p_cas_id' ,
                          p_param_value => p_cas_id);
                    RAISE FND_API.G_EXC_ERROR;
                   fnd_msg_pub.add;
                   RAISE FND_API.G_EXC_ERROR;
          WHEN OTHERS THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END;

   END IF; --end of item level validation
--   IF PG_DEBUG < 10  THEN
   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      iex_debug_pub.logMessage('CloseCase: ' || 'After Item validation ');
   END IF;
   -- Call update Case PVT to update the case_state to 'CLOSE';
   l_cas_rec.cas_id                :=l_cas_id;
   l_cas_rec.object_version_number :=l_object_version_number;
   l_cas_rec.case_state            :='CLOSE';
   l_cas_rec.case_closing_date          :=p_close_date;

--   IF PG_DEBUG < 10  THEN
   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      iex_debug_pub.logMessage('CloseCase: ' || 'Before Calling  Update  PVT');
   END IF;
   iex_cases_pvt.update_cas
                        (P_Api_Version_Number         =>l_api_version_number,
                         P_Init_Msg_List              =>FND_API.G_FALSE,
                         P_Commit                     =>FND_API.G_FALSE,
                         p_validation_level           =>P_validation_level,
                         P_cas_Rec                    =>l_cas_Rec,
                         X_Return_Status              =>l_return_status,
                         X_Msg_Count                  =>l_msg_count,
                         X_Msg_Data                   =>l_msg_data,
                         xo_object_version_number     =>l_object_version_number);
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logMessage('CloseCase: ' || 'After Calling update case  PVT and Status =>'||l_return_status);
    END IF;

    IF l_return_status = FND_API.G_RET_STS_ERROR then
     AddFailMsg( p_object     =>  'CASE',
                 p_operation  =>  'UPDATE' );
       raise FND_API.G_EXC_ERROR;
    elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
       raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
   -- Update of case is successful and if Copy object ='Y'
   --Create a new case with the same case definition (copy case definition and
   -- create case definitions for the new case id)
   --Update case object with the new case ID.
   IF p_copy_objects =g_yes THEN
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logMessage('CloseCase: ' || 'Before Calling Create Case  PVT');
      END IF;
      PopCaseRec(p_cas_id      =>l_cas_id,
                 x_cas_rec     =>l_cas_rec);

      -- added by ehuh Aug 10 2003

      begin

      --Begin bug#5373412 schekuri 10-Jul-2006
      --Call new consolidated procedure get_assigned_collector
        /*iex_utilities.get_case_resources(p_api_version      => 1.0,
                                         p_init_msg_list    => FND_API.G_TRUE,
                                         p_commit           => FND_API.G_FALSE,
                                         p_validation_level => p_validation_level,
                                         x_msg_count        => l_msg_count,
                                         x_msg_data         => l_msg_data,
                                         x_return_status    => l_return_status,
                                         p_party_id         => l_cas_rec.party_id,
                                         x_resource_tab     => l_resource_tab);*/

	iex_utilities.get_assigned_collector(p_api_version => 1.0,
	  				     p_init_msg_list     => FND_API.G_TRUE,
					     p_commit            => FND_API.G_FALSE,
					     p_validation_level  => p_validation_level,
					     p_level             => 'CASE',
					     p_level_id          => l_cas_rec.party_id,
					     x_msg_count         => l_msg_count,
					     x_msg_data          => l_msg_data,
					     x_return_status     => l_return_status,
					     x_resource_tab      => l_resource_tab);
      --End bug#5373412 schekuri 10-Jul-2006

      if l_resource_tab.COUNT >0 THEN
          l_cas_rec.owner_resource_id := l_resource_tab(1).resource_id;
      else
         l_cas_rec.owner_resource_id := l_resource_id;
     end if;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      iex_debug_pub.logMessage('Get_assign_resource(C) : ' || 'After Calling Get_assign_resource and Status =>'||l_return_status);
      iex_debug_pub.logMessage('Resource ID : ' || l_cas_rec.owner_resource_id );
END IF;

      exception
         when others then
              null;
      end;
      -- ended by ehuh Aug 10 2003

      iex_cases_pvt.Create_CAS(
                    P_Api_Version_Number         =>l_api_version_number,
                    P_Init_Msg_List              =>FND_API.G_FALSE,
                    P_Commit                     =>FND_API.G_FALSE,
                    p_validation_level           =>P_validation_level,
                    P_cas_Rec                    =>l_cas_Rec,
                    x_case_id                    =>l_cas_new_id,
                    X_Return_Status              =>l_return_status,
                    X_Msg_Count                  =>l_msg_count,
                    X_Msg_Data                   =>l_msg_data);
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           iex_debug_pub.logMessage('CloseCase: ' || 'After Calling Create Case  PVT and Status =>'||l_return_status);
        END IF;
        IF l_return_status = FND_API.G_RET_STS_ERROR then
             AddFailMsg( p_object     =>  'CASE',
                         p_operation  =>  'INSERT' );
            raise FND_API.G_EXC_ERROR;
        elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
             raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        --Get case Case definition for the old case (l_cas_id)
           PopulateCaseDefTbl( p_cas_id             =>l_cas_id,
                               X_case_definition_tbl=>l_case_definition_tbl);
         --Call iex_case_definition_pvt to create case_def
    	   FOR i IN 1..l_case_definition_tbl.COUNT
           LOOP
               --Populate Case Definition record
               PopulateCaseDefRec
                                 (p_column_name    =>l_case_definition_tbl(i).column_name,
                                  p_column_value   =>l_case_definition_tbl(i).column_value,
                                  p_table_name     =>l_case_definition_tbl(i).table_name,
                                  p_cas_id         =>l_cas_new_id,
                                  p_attribute_rec  =>p_cas_rec,
                                  x_case_def_rec   =>l_case_definition_Rec);
--               IF PG_DEBUG < 10  THEN
               IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                  iex_debug_pub.logMessage('CloseCase: ' || 'Before Calling Create Case Definition  PVT');
               END IF;
               iex_case_definitions_pvt.create_case_definitions(
                             P_Api_Version_Number         =>l_api_version_number,
                             P_Init_Msg_List              =>FND_API.G_FALSE,
                             P_Commit                     =>FND_API.G_FALSE,
                             p_validation_level           =>P_validation_level,
                             p_case_definition_rec        =>l_case_definition_Rec,
                             x_case_definition_id         =>l_case_definition_id,
                             X_Return_Status              =>l_return_status,
                             X_Msg_Count                  =>l_msg_count,
                             X_Msg_Data                   =>l_msg_data);
--                 IF PG_DEBUG < 10  THEN
                 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                    iex_debug_pub.logMessage('CloseCase: ' || 'After Calling Create Case Definition PVT and Status =>'||l_return_status);
                 END IF;
                 IF l_return_status = FND_API.G_RET_STS_ERROR then
                    AddFailMsg( p_object     =>  'CASE DEFINITION',
                                p_operation  =>  'INSERT' );
                     raise FND_API.G_EXC_ERROR;
                 elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
                      raise FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;
             END LOOP;
--             IF PG_DEBUG < 10  THEN
             IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                iex_debug_pub.logMessage('CloseCase: ' || 'End of Case Definition' );
             END IF;
             --Populate Case object record for one CASE
             For cas_obj_rec in get_case_objects_obj_ver_num(l_cas_id) LOOP
--                   IF PG_DEBUG < 10  THEN
                   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                      IEX_DEBUG_PUB.LogMessage ('CloseCase: ' || ' the case object ID updated is =>'
                                             ||cas_obj_rec.case_object_id ||' and  new cas ID is '||
                                               l_cas_new_id||' and old case id is => '||l_cas_id );
                   END IF;

                   l_case_object_Rec.cas_id         :=l_cas_new_id;
                   l_case_object_Rec.case_object_id :=cas_obj_rec.case_object_id;
                   l_case_object_Rec.object_version_number
                                                   :=cas_obj_rec.object_version_number;

                    --Call update_case_object_pvt to update Case object_id
--                    IF PG_DEBUG < 10  THEN
                    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                       iex_debug_pub.logMessage('CloseCase: ' || 'Before Calling update Case Object PVT');
                    END IF;
                    iex_case_objects_pvt.update_case_objects(
                             P_Api_Version_Number         =>l_api_version_number,
                             P_Init_Msg_List              =>FND_API.G_FALSE,
                             P_Commit                     =>FND_API.G_FALSE,
                             p_validation_level           =>P_validation_level,
                             P_case_object_Rec            =>l_case_object_Rec,
                             X_Return_Status              =>l_return_status,
                             X_Msg_Count                  =>l_msg_count,
                             X_Msg_Data                   =>l_msg_data,
                             xo_object_version_number     =>l_object_version_number);
--                    IF PG_DEBUG < 10  THEN
                    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                       iex_debug_pub.logMessage('CloseCase: ' || 'After Calling update Case Object PVT and Status =>'||l_return_status);
                    END IF;
                 -- Check return status from the above procedure call
                     IF l_return_status = FND_API.G_RET_STS_ERROR then
                         AddFailMsg( p_object     =>  'CASE OBJECTS',
                                     p_operation  =>  'INSERT' );

                        raise FND_API.G_EXC_ERROR;
                    elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                     END IF;
             END LOOP;
    END IF; -- p_copy_objects =g_yes

      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage ('CloseCase: ' || '*********End of Procedure => '||l_api_name||' *********');
     END IF;
 -- Debug Message
 -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
   END CloseCase;


/* Name   CreateCaseObjects
**  api  : Current version 2.0
** Purpose To create case object. It first checks if a case exists, else creates
** a new case with the given case definition. Also checks if the case definition
** elements passed are valid or not.The logic is as follows
** 1. Checks validity of Case Definition
** 2.Gets Case Id for the given Valid Case Definition
** 3.Create Case if case does not exists with the valid case definition
** 4.Creates Case Object
Optional Parameters
** p_cas_rec --> populate other attributes of a case, like attributes 1-15, concurrent program fields
**
*/
PROCEDURE CreateCaseObjects(
          P_Api_Version_Number         IN   NUMBER,
          P_Init_Msg_List              IN   VARCHAR2    ,
          P_Commit                     IN   VARCHAR2    ,
          P_validation_level           IN   NUMBER   ,
          P_case_definition_tbl        IN   CASE_DEFINITION_TBL_TYPE
                                                    ,
          P_cas_id                     IN NUMBER        ,
          P_case_number                IN VARCHAR2      ,
          P_case_comments              IN VARCHAR2      ,
          P_case_established_date      IN DATE          ,
          P_org_id                     IN NUMBER        ,
          P_object_code                IN VARCHAR2      ,
          P_party_id                   IN NUMBER,
          P_object_id                  IN NUMBER,
          p_cas_rec                    IN    CAS_Rec_Type ,
          X_case_object_id             OUT  NOCOPY  NUMBER,
          X_Return_Status              OUT  NOCOPY  VARCHAR2,
          X_Msg_Count                  OUT  NOCOPY  NUMBER,
          X_Msg_Data                   OUT  NOCOPY  VARCHAR2
          ) IS

l_api_name                CONSTANT VARCHAR2(30) := 'CreateCaseObjects';
l_api_name_full	          CONSTANT VARCHAR2(61) := g_pkg_name || '.' || l_api_name;
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_org_id			      NUMBER            :=p_org_id;
l_cas_id		          NUMBER            :=p_cas_id;
l_object_code             VARCHAR2(30)      :=p_object_code;
l_case_established_date   DATE              :=p_case_established_date;
l_return_status           VARCHAR2(1);
l_msg_count               NUMBER;
l_msg_data                VARCHAR2(32767);
l_case_object_id          NUMBER;
l_case_definition_id      NUMBER;
l_cas_rec                 iex_cases_pvt.cas_rec_type
                                         := iex_cases_pvt.g_miss_cas_rec;
l_case_definition_rec            iex_case_definitions_pvt.case_definition_rec_type
                                         := iex_case_definitions_pvt.g_miss_case_definition_rec;
l_case_object_rec         iex_case_objects_pvt.case_object_rec_type
                                          := iex_case_objects_pvt.g_miss_case_object_rec;

l_resource_tab iex_utilities.resource_tab_type;  -- added by ehuh Aug 1 2003
l_resource_id NUMBER   :=  nvl(fnd_profile.value('IEX_STRY_DEFAULT_RESOURCE'),0);

--Begin Bug#6962575 barathsr 29-Jul-2008
--While creating cases in bulk skip finding the resource and assign default resource
l_orig_system_source OKC_K_HEADERS_B.ORIG_SYSTEM_SOURCE_CODE%type;

cursor c_orig_system_source(p_contract_id number) is
select ORIG_SYSTEM_SOURCE_CODE
from OKC_K_HEADERS_B
where id=p_contract_id;
--End Bug#6962575 barathsr 29-Jul-2008


 BEGIN
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage ('CreateCaseObjects: ' || '*********Start of Procedure => '||l_api_name||' *********');
     END IF;
      -- Standard Start of API savepoint
      SAVEPOINT CREATECASEOBJECTS_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                           	               p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logMessage('CreateCaseObjects: ' || 'After Api compatability Check');
     END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- API body
      --
      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('IEX', 'IEX_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logMessage('CreateCaseObjects: ' || 'After FND_GLOBAL_USER Check');
      END IF;

      -- Item level validation
      --IF (p_validation_level > fnd_api.g_valid_level_none) THEN

          -- Get org_id if not present
          IF (p_org_id IS NULL) OR
                      (p_org_id = FND_API.G_MISS_NUM) THEN
		 --Bug#4679639 schekuri 20-OCT-2005
                 --Used mo_global.get_current_org_id to get ORG_ID
          	 --l_org_id := fnd_profile.value('ORG_ID');
		 l_org_id := mo_global.get_current_org_id;
          END IF;
--          IF PG_DEBUG < 10  THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             IEX_DEBUG_PUB.LogMessage('CreateCaseObjects: ' || 'After ORG ID Check and Org_id is => '||l_org_id);
          END IF;

         --Default Case_established_date to sysdate if null
         IF (p_Case_established_date IS NULL)OR
                     (p_Case_established_date = FND_API.G_MISS_DATE) THEN
              l_Case_established_date := sysdate;
         END IF;
--         IF PG_DEBUG < 10  THEN
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            IEX_DEBUG_PUB.LogMessage('CreateCaseObjects: ' || 'After Case ESTABLISHED Date Check and case_established is => '||l_case_ESTABLISHED_DATE);
         END IF;

           -- Get object_code if not present
          IF (p_object_code IS NULL) OR
                   (p_object_code =  FND_API.G_MISS_CHAR) THEN
          	 l_object_code := 'CONTRACTS';
          END IF;
--         IF PG_DEBUG < 10  THEN
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            IEX_DEBUG_PUB.LogMessage('CreateCaseObjects: ' || 'After Object Code Check and object is => '||l_object_code);
         END IF;

          -- Check for required parameter object_id
         IF (p_object_id IS NULL) OR (p_object_id = FND_API.G_MISS_NUM) THEN
--             IF PG_DEBUG < 10  THEN
             IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                IEX_DEBUG_PUB.LogMessage('CreateCaseObjects: ' || 'Required Parameter p_object_id is invalid');
             END IF;
              AddMissingArgMsg(
                      p_api_name    =>  l_api_name_full,
                      p_param_name  =>  'p_object_id' );
              RAISE FND_API.G_EXC_ERROR;
          END IF;

          -- Check for required parameter party_id
         IF (p_party_id IS NULL) OR (p_party_id = FND_API.G_MISS_NUM) THEN
--             IF PG_DEBUG < 10  THEN
             IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                IEX_DEBUG_PUB.LogMessage('CreateCaseObjects: ' || 'Required Parameter p_party_id is invalid');
             END IF;
              AddMissingArgMsg(
                      p_api_name    =>  l_api_name_full,
                      p_param_name  =>  'p_party_id' );
              RAISE FND_API.G_EXC_ERROR;
          END IF;

         -- Check for valid cas_id or Case Definition has to be passed
         BEGIN
              IF (l_cas_id IS NOT NULL) AND (l_cas_id <> FND_API.G_MISS_NUM) THEN
                  SELECT cas_id INTO l_cas_id
                  FROM iex_cases_all_b
                  WHERE cas_id      = p_cas_id
                  AND   case_state = 'OPEN'
 	              and active_flag ='Y';

               ELSIF ( P_case_definition_tbl.COUNT = 0 )   THEN
--                     IF PG_DEBUG < 10  THEN
                     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                        IEX_DEBUG_PUB.LogMessage('CreateCaseObjects: ' || 'Required Parameter P_case_definition_tbl is EMPTY');
                     END IF;
                      AddMissingArgMsg(
                           p_api_name    =>  l_api_name_full,
                           p_param_name  =>  'p_cas_id' );
                      RAISE FND_API.G_EXC_ERROR;
               END IF;
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
--              IF PG_DEBUG < 10  THEN
              IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                 IEX_DEBUG_PUB.LogMessage('CreateCaseObjects: ' || 'Required Parameter p_cas_id is invalid');
              END IF;
              AddInvalidArgMsg(
                   p_api_name    =>  l_api_name_full,
                   p_param_value =>  p_cas_id,
                   p_param_name  =>  'p_cas_id' );
               RAISE FND_API.G_EXC_ERROR;
        WHEN OTHERS THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;


   --END IF; --end of item level validation
--   IF PG_DEBUG < 10  THEN
   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      iex_debug_pub.logMessage('CreateCaseObjects: ' || 'After Item validation ');
   END IF;

 --- Check Case Definition
 --  If case Id exists, call case_object_pvt with the given case_id
 -- To create the case objects
 -- otherwise, check case def, retrieve case number and then
 -- call case_object_pvt. If case does not exist, create case defintiton and
 -- and create case and then finally create case object.

   IF (l_cas_id IS NOT NULL) AND (l_cas_id <> FND_API.G_MISS_NUM) THEN
--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logMessage('CreateCaseObjects: ' || 'case Id is passed '||l_cas_id);
       END IF;
       --Populate Case object record
         PopulateCaseObjectRec(p_object_code           =>l_object_code,
                               p_object_id             =>p_object_id,
                               p_cas_id                =>l_cas_id,
                               p_attribute_rec         =>p_cas_rec,
                               x_case_object_rec       =>l_case_object_Rec);
       --Call create_case_object_pvt to create Case object_id
--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logMessage('CreateCaseObjects: ' || '---------------------------------');
       END IF;
       iex_case_objects_pvt.Create_case_objects(
          P_Api_Version_Number         =>l_api_version_number,
          P_Init_Msg_List              =>FND_API.G_FALSE,
          P_Commit                     =>FND_API.G_FALSE,
          p_validation_level           =>P_validation_level,
          P_case_object_Rec            =>l_case_object_Rec,
          x_case_object_id             =>l_case_object_id,
          X_Return_Status              =>l_return_status,
          X_Msg_Count                  =>l_msg_count,
          X_Msg_Data                   =>l_msg_data);

--         IF PG_DEBUG < 10  THEN
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            iex_debug_pub.logMessage('CreateCaseObjects: ' || 'Status of Create Case object PVT => '||l_return_status);
         END IF;
           -- Check return status from the above procedure call
          IF l_return_status = FND_API.G_RET_STS_ERROR then
  		    FND_MESSAGE.SET_NAME('IEX', 'IEX_FAILED_CREATE_CO');
		    FND_MSG_PUB.Add;
            raise FND_API.G_EXC_ERROR;
          elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
             raise FND_API.G_EXC_UNEXPECTED_ERROR;
          else
              x_case_object_id :=l_case_object_id;
--              IF PG_DEBUG < 10  THEN
              IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                 iex_debug_pub.logMessage('CreateCaseObjects: ' || 'Value of x_case_object_id =>' ||x_case_object_id);
              END IF;
          END IF;

    ELSE  -- Check if case definition is valid and
          --get case id for the given case definition
--          IF PG_DEBUG < 10  THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             iex_debug_pub.logMessage('CreateCaseObjects: ' || 'case Id is not passed ');
          END IF;
--          IF PG_DEBUG < 10  THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             iex_debug_pub.logMessage('CreateCaseObjects: ' || '---------------------------------');
          END IF;
           If CheckCaseDef(P_case_definition_tbl) THEN
--               IF PG_DEBUG < 10  THEN
               IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                  iex_debug_pub.logMessage('CreateCaseObjects: ' || 'case Defintion is Valid ');
               END IF;
               --Get case Id for the given Case definition
--               IF PG_DEBUG < 10  THEN
               IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                  iex_debug_pub.logMessage('CreateCaseObjects: ' || '---------------------------------');
               END IF;
               GetCaseId(
                           P_case_definition_tbl=>P_case_definition_tbl,
                           x_cas_id             =>l_cas_id);
               --Case definition is valid and if a matching case is found
--               IF PG_DEBUG < 10  THEN
               IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                  iex_debug_pub.logMessage('CreateCaseObjects: ' || '---------------------------------');
               END IF;
               if l_cas_id  is NOT NULL THEN
--                   IF PG_DEBUG < 10  THEN
                   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                      iex_debug_pub.logMessage('CreateCaseObjects: ' || 'Matching case is found and CAS ID is => '||l_Cas_id);
                   END IF;
                   --Populate Case object record
                     PopulateCaseObjectRec(p_object_code           =>l_object_code,
                                           p_object_id             =>p_object_id,
                                           p_cas_id                =>l_cas_id,
                                           p_attribute_rec         =>p_cas_rec,
                                           x_case_object_rec       =>l_case_object_Rec);
                      --Call create_case_object_pvt to create Case object_id
--                         IF PG_DEBUG < 10  THEN
                         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                            iex_debug_pub.logMessage('CreateCaseObjects: ' || 'Before Calling Create Case Object PVT');
                         END IF;
--                          IF PG_DEBUG < 10  THEN
                          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                             iex_debug_pub.logMessage('CreateCaseObjects: ' || '---------------------------------');
                          END IF;
                          iex_case_objects_pvt.Create_case_objects(
                             P_Api_Version_Number         =>l_api_version_number,
                             P_Init_Msg_List              =>FND_API.G_FALSE,
                             P_Commit                     =>FND_API.G_FALSE,
                             p_validation_level           =>P_validation_level,
                             P_case_object_Rec            =>l_case_object_Rec,
                             x_case_object_id             =>l_case_object_id,
                             X_Return_Status              =>l_return_status,
                             X_Msg_Count                  =>l_msg_count,
                             X_Msg_Data                   =>l_msg_data);
--                    IF PG_DEBUG < 10  THEN
                    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                       iex_debug_pub.logMessage('CreateCaseObjects: ' || 'After Calling Create Case Object PVT and Status =>'||l_return_status);
                    END IF;
                 -- Check return status from the above procedure call
                     IF l_return_status = FND_API.G_RET_STS_ERROR then
                         AddFailMsg( p_object     =>  'CASE OBJECTS',
                                     p_operation  =>  'INSERT' );
                        raise FND_API.G_EXC_ERROR;
                    elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                    else
                        x_case_object_id :=l_case_object_id;
--                        IF PG_DEBUG < 10  THEN
                        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                           iex_debug_pub.logMessage('CreateCaseObjects: ' || 'Value of x_case_object_id =>' ||x_case_object_id);
                        END IF;

                     END IF;
               Else
                 --If Case Definition is valid , but no matching Case,then create
                 -- Case , Create case defintion and then create case object
                 -- Populate Case Record
--                    IF PG_DEBUG < 10  THEN
                    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                       iex_debug_pub.logMessage('CreateCaseObjects: ' || 'Case Definition is Valid , no case found');
                    END IF;
                    PopulateCaseRec(p_case_number           =>p_case_number,
                                    p_comments              =>p_case_comments,
                                    p_org_id                =>l_org_id,
                                    p_case_established_date =>l_case_established_date,
                                    p_attribute_rec         =>p_cas_rec,
                                    x_cas_rec               =>l_cas_rec);

                    l_cas_rec.party_id :=p_party_id;

                    -- added by ehuh Aug 10 2003
                    begin
                    --Begin bug#5373412 schekuri 10-Jul-2006
		    --Call new consolidated procedure get_assigned_collector
                    /*iex_utilities.get_case_resources(p_api_version      => 1.0,
                                                       p_init_msg_list    => FND_API.G_TRUE,
                                                       p_commit           => FND_API.G_FALSE,
                                                       p_validation_level => p_validation_level,
                                                       x_msg_count        => l_msg_count,
                                                       x_msg_data         => l_msg_data,
                                                       x_return_status    => l_return_status,
                                                       p_party_id         => l_cas_rec.party_id,
                                                       x_resource_tab     => l_resource_tab);*/

		     --Begin Bug#6962575 barathsr 29-Jul-2008
		     --While creating cases in bulk skip finding the resource and assign default resource
                     open c_orig_system_source(p_object_id);
		     fetch c_orig_system_source into l_orig_system_source;
		     close c_orig_system_source;
		     if l_orig_system_source<>'OKL_IMPORT' then

		     iex_utilities.get_assigned_collector(p_api_version => 1.0,
	  				     p_init_msg_list     => FND_API.G_TRUE,
					     p_commit            => FND_API.G_FALSE,
					     p_validation_level  => p_validation_level,
					     p_level             => 'CASE',
					     p_level_id          => l_cas_rec.party_id,
					     x_msg_count         => l_msg_count,
					     x_msg_data          => l_msg_data,
					     x_return_status     => l_return_status,
					     x_resource_tab      => l_resource_tab);
                    --End bug#5373412 schekuri 10-Jul-2006
                   end if;
                   --End Bug#6962575 barathsr 29-Jul-2008
                   if l_resource_tab.COUNT >0 THEN
                      l_cas_rec.owner_resource_id := l_resource_tab(1).resource_id;
                   else
                       l_cas_rec.owner_resource_id := l_resource_id;
                   end if;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                    iex_debug_pub.logMessage('Get_assign_resource(O) : ' || 'After Calling Get_assign_resource and Status =>'||l_return_status);
                    iex_debug_pub.logMessage('Resource ID : ' || l_cas_rec.owner_resource_id );
END IF;

                    exception
                      when others then
                           null;
                    end;
                    -- ended by ehuh Aug 10 2003

                    --Call iex_cases_pvt to create a case
--                    IF PG_DEBUG < 10  THEN
                    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                       iex_debug_pub.logMessage('CreateCaseObjects: ' || 'Before Calling Create Case  PVT');
                    END IF;

--                    IF PG_DEBUG < 10  THEN
                    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                       iex_debug_pub.logMessage('CreateCaseObjects: ' || '---------------------------------');
                    END IF;

                    iex_cases_pvt.Create_CAS(
                             P_Api_Version_Number         =>l_api_version_number,
                             P_Init_Msg_List              =>FND_API.G_FALSE,
                             P_Commit                     =>FND_API.G_FALSE,
                             p_validation_level           =>P_validation_level,
                             P_cas_Rec                    =>l_cas_Rec,
                             x_case_id                    =>l_cas_id,
                             X_Return_Status              =>l_return_status,
                             X_Msg_Count                  =>l_msg_count,
                             X_Msg_Data                   =>l_msg_data);
--                     IF PG_DEBUG < 10  THEN
                     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                        iex_debug_pub.logMessage('CreateCaseObjects: ' || 'After Calling Create Case  PVT and Status =>'||l_return_status);
                     END IF;
                      IF l_return_status = FND_API.G_RET_STS_ERROR then
                         AddFailMsg( p_object     =>  'CASE',
                                     p_operation  =>  'INSERT' );
                        raise FND_API.G_EXC_ERROR;
                    elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                     END IF;
                  --Call iex_case_definition_pvt to create case_def
               		FOR i IN 1..P_case_definition_tbl.COUNT LOOP
                        --Populate Case Definition record
                         PopulateCaseDefRec(p_column_name    =>p_case_definition_tbl(i).column_name,
                                            p_column_value   =>p_case_definition_tbl(i).column_value,
                                            p_table_name     =>p_case_definition_tbl(i).table_name,
                                            p_cas_id         =>l_cas_id,
                                            p_attribute_rec  =>p_cas_rec,
                                            x_case_def_rec   =>l_case_definition_Rec);
--                        IF PG_DEBUG < 10  THEN
                        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                           iex_debug_pub.logMessage('CreateCaseObjects: ' || 'Before Calling Create Case Definition  PVT');
                        END IF;
--                        IF PG_DEBUG < 10  THEN
                        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                           iex_debug_pub.logMessage('CreateCaseObjects: ' || '---------------------------------');
                        END IF;
                        iex_case_definitions_pvt.create_case_definitions(
                             P_Api_Version_Number         =>l_api_version_number,
                             P_Init_Msg_List              =>FND_API.G_FALSE,
                             P_Commit                     =>FND_API.G_FALSE,
                             p_validation_level           =>P_validation_level,
                             p_case_definition_rec        =>l_case_definition_Rec,
                             x_case_definition_id         =>l_case_definition_id,
                             X_Return_Status              =>l_return_status,
                             X_Msg_Count                  =>l_msg_count,
                             X_Msg_Data                   =>l_msg_data);
--                      IF PG_DEBUG < 10  THEN
                      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                         iex_debug_pub.logMessage('CreateCaseObjects: ' || 'After Calling Create Case Definition PVT and Status =>'||l_return_status);
                      END IF;
                      IF l_return_status = FND_API.G_RET_STS_ERROR then
                        AddFailMsg( p_object      =>  'CASE DEFINITIONS',
                                     p_operation  =>  'INSERT' );
                        raise FND_API.G_EXC_ERROR;
                    elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                     END IF;
                  END LOOP;
                     --Populate Case object record
                     PopulateCaseObjectRec(p_object_code           =>l_object_code,
                                           p_object_id             =>p_object_id,
                                           p_cas_id                =>l_cas_id,
                                           p_attribute_rec         =>p_cas_rec,
                                           x_case_object_rec       =>l_case_object_Rec);
                      --Call create_case_object_pvt to create Case object_id
--                      IF PG_DEBUG < 10  THEN
                      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                         iex_debug_pub.logMessage('CreateCaseObjects: ' || 'Before Calling Create Case Object PVT');
                      END IF;
--                      IF PG_DEBUG < 10  THEN
                      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                         iex_debug_pub.logMessage('CreateCaseObjects: ' || '---------------------------------');
                      END IF;
                      iex_case_objects_pvt.Create_case_objects(
                             P_Api_Version_Number         =>l_api_version_number,
                             P_Init_Msg_List              =>FND_API.G_FALSE,
                             P_Commit                     =>FND_API.G_FALSE,
                             p_validation_level           =>P_validation_level,
                             P_case_object_Rec            =>l_case_object_Rec,
                             x_case_object_id             =>l_case_object_id,
                             X_Return_Status              =>l_return_status,
                             X_Msg_Count                  =>l_msg_count,
                             X_Msg_Data                   =>l_msg_data);
--                     IF PG_DEBUG < 10  THEN
                     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                        iex_debug_pub.logMessage('CreateCaseObjects: ' || 'After Calling Create Case Object PVT and Status =>'||l_return_status);
                     END IF;
                 -- Check return status from the above procedure call
                     IF l_return_status = FND_API.G_RET_STS_ERROR then
                            AddFailMsg( p_object     =>  'CASE OBJECTS',
                                        p_operation  =>  'INSERT' );
                        raise FND_API.G_EXC_ERROR;
                    elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                    else
                       x_case_object_id :=l_case_object_id;
--                       IF PG_DEBUG < 10  THEN
                       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                          iex_debug_pub.logMessage('CreateCaseObjects: ' || 'Value of x_case_object_id =>' ||x_case_object_id);
                       END IF;
                     END IF;

               END IF; -- end of if G_match_Case_id  is NOT NULL
        ELSE -- if case Definition is invalid then error out.
             --How to assign value of parameter,since it is table?
--               IF PG_DEBUG < 10  THEN
               IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                  iex_debug_pub.logMessage('CreateCaseObjects: ' || 'Case Definition is invalid');
               END IF;
               AddInvalidArgMsg(
                      p_api_name    =>  l_api_name_full,
                      p_param_value =>  'P_case_definition_tbl',
                      p_param_name  =>  'P_case_definition_tbl' );
               RAISE FND_API.G_EXC_ERROR;

        END IF; --If CheckCaseDef(P_case_definition_tbl)
    END IF; -- (l_cas_id IS NOT NULL) OR (l_cas_id <> FND_API.G_MISS_NUM)

      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage ('CreateCaseObjects: ' || '*********End of Procedure => '||l_api_name||' *********');
     END IF;
      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
   END CreateCaseObjects;


/* Name   ReassignCaseObjects
**  api  : Current version 2.0
** Purpose To Reassign case object.
** Delete the contracts from iex_case_objects
** It first checks if a case exists, else creates
** a new case with the given case definition. Also checks if the case definition
** elements passed are valid or not.The logic is as follows
** 1. Checks validity of Case Definition
** 2.Gets Case Id for the given Valid Case Definition
** 3.Create Case if case does not exists with the valid case definition
** 4.Creates Case Object
** Rescore both the cases and creates/updates the delinquencies.
Optional Parameters
** p_cas_rec --> populate other attributes of a case, like attributes 1-15, concurrent program fields
**
*/
PROCEDURE ReassignCaseObjects(
          P_Api_Version_Number         IN   NUMBER,
          P_Init_Msg_List              IN   VARCHAR2    ,
          P_Commit                     IN   VARCHAR2    ,
          P_validation_level           IN   NUMBER     ,
          P_case_definition_tbl        IN   CASE_DEFINITION_TBL_TYPE
                                                       ,
          P_cas_id                     IN NUMBER        ,
          P_case_number                IN VARCHAR2      ,
          P_case_comments              IN VARCHAR2      ,
          P_case_established_date      IN DATE          ,
          P_org_id                     IN NUMBER        ,
          P_object_code                IN VARCHAR2      ,
          P_party_id                   IN NUMBER,
          P_object_id                  IN NUMBER,
          p_cas_rec                    IN    CAS_Rec_Type  ,
          X_case_object_id             OUT  NOCOPY  NUMBER,
          X_Return_Status              OUT  NOCOPY  VARCHAR2,
          X_Msg_Count                  OUT  NOCOPY  NUMBER,
          X_Msg_Data                   OUT  NOCOPY  VARCHAR2

          ) IS

l_api_name                CONSTANT VARCHAR2(30) := 'ReassignCaseObjects';
l_api_name_full	          CONSTANT VARCHAR2(61) := g_pkg_name || '.' || l_api_name;
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_org_id			      NUMBER            :=p_org_id;
l_cas_id		          NUMBER            :=p_cas_id;
l_object_code             VARCHAR2(30)      :=p_object_code;
l_case_established_date   DATE              :=p_case_established_date;
l_return_status           VARCHAR2(1);
l_msg_count               NUMBER;
l_msg_data                VARCHAR2(32767);
l_case_object_id          NUMBER;
l_case_definition_id      NUMBER;
l_cas_rec                 iex_cases_pvt.cas_rec_type
                                         := iex_cases_pvt.g_miss_cas_rec;
l_case_definition_rec            iex_case_definitions_pvt.case_definition_rec_type
                                         := iex_case_definitions_pvt.g_miss_case_definition_rec;
l_case_object_rec         iex_case_objects_pvt.case_object_rec_type
                                          := iex_case_objects_pvt.g_miss_case_object_rec;

l_old_case_id      NUMBER;
l_new_case_id      NUMBER;
x_del_id           NUMBER;

l_case_agent       VARCHAR2(120);
l_contract_number  VARCHAR2(120);

l_resource_tab iex_utilities.resource_tab_type;  -- added by ehuh Aug 1 2003
l_resource_id NUMBER   :=  nvl(fnd_profile.value('IEX_STRY_DEFAULT_RESOURCE'),0);


cursor c_getname(p_old_case_id IN NUMBER) is
Select user_name
from jtf_rs_resource_extns a,
     iex_Cases_all_b b
where b.cas_id =p_old_case_id
      and a.resource_id =  nvl(b.access_resource_id,
         fnd_profile.value('IEX_DEFAULT_CASE_AGENT'));


cursor c_contract (p_contract_id IN NUMBER) is
Select contract_number
from   okc_k_headers_b
where id =p_contract_id;
l_del_id NUMBER;

 BEGIN

--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage ('ReassignCaseObjects: ' || '*********Start of Procedure => '||l_api_name||' *********');
     END IF;
      -- Standard Start of API savepoint
      SAVEPOINT REASSIGNCASEOBJECTS_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                           	               p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logMessage('ReassignCaseObjects: ' || 'After Api compatability Check');
     END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('IEX', 'IEX_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logMessage('ReassignCaseObjects: ' || 'After FND_GLOBAL_USER Check');
      END IF;

      -- Item level validation
      --IF (p_validation_level > fnd_api.g_valid_level_none) THEN

          -- Get org_id if not present
          IF (p_org_id IS NULL) OR
                      (p_org_id = FND_API.G_MISS_NUM) THEN

		 --Bug#4679639 schekuri 20-OCT-2005
                 --Used mo_global.get_current_org_id to get ORG_ID
          	 --l_org_id := fnd_profile.value('ORG_ID');
		 l_org_id := mo_global.get_current_org_id;
          END IF;
--          IF PG_DEBUG < 10  THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             IEX_DEBUG_PUB.LogMessage('ReassignCaseObjects: ' || 'After ORG ID Check and Org_id is => '||l_org_id);
          END IF;

         --Default Case_established_date to sysdate if null
         IF (p_Case_established_date IS NULL)OR
                     (p_Case_established_date = FND_API.G_MISS_DATE) THEN
              l_Case_established_date := sysdate;
         END IF;
--         IF PG_DEBUG < 10  THEN
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            IEX_DEBUG_PUB.LogMessage('ReassignCaseObjects: ' || 'After Case ESTABLISHED Date Check and case_established is => '||l_case_ESTABLISHED_DATE);
         END IF;

           -- Get object_code if not present
          IF (p_object_code IS NULL) OR
                   (p_object_code =  FND_API.G_MISS_CHAR) THEN
          	 l_object_code := 'CONTRACTS';
          END IF;
--         IF PG_DEBUG < 10  THEN
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            IEX_DEBUG_PUB.LogMessage('ReassignCaseObjects: ' || 'After Object Code Check and object is => '||l_object_code);
         END IF;

          -- Check for required parameter object_id
         IF (p_object_id IS NULL) OR (p_object_id = FND_API.G_MISS_NUM) THEN
--             IF PG_DEBUG < 10  THEN
             IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                IEX_DEBUG_PUB.LogMessage('ReassignCaseObjects: ' || 'Required Parameter p_object_id is invalid');
             END IF;
              AddMissingArgMsg(
                      p_api_name    =>  l_api_name_full,
                      p_param_name  =>  'p_object_id' );
              RAISE FND_API.G_EXC_ERROR;
          END IF;

          -- Check for required parameter party_id
         IF (p_party_id IS NULL) OR (p_party_id = FND_API.G_MISS_NUM) THEN
--             IF PG_DEBUG < 10  THEN
             IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                IEX_DEBUG_PUB.LogMessage('ReassignCaseObjects: ' || 'Required Parameter p_party_id is invalid');
             END IF;
              AddMissingArgMsg(
                      p_api_name    =>  l_api_name_full,
                      p_param_name  =>  'p_party_id' );
              RAISE FND_API.G_EXC_ERROR;
          END IF;

         -- Check for valid cas_id or Case Definition has to be passed
         BEGIN
              IF (l_cas_id IS NOT NULL) AND (l_cas_id <> FND_API.G_MISS_NUM) THEN
                  SELECT cas_id INTO l_cas_id
                  FROM iex_cases_all_b
                  WHERE cas_id      = p_cas_id
                  AND   case_state = 'OPEN'
 	              and active_flag ='Y';

               ELSIF ( P_case_definition_tbl.COUNT = 0 )   THEN
--                     IF PG_DEBUG < 10  THEN
                     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                        IEX_DEBUG_PUB.LogMessage('ReassignCaseObjects: ' || 'Required Parameter P_case_definition_tbl is EMPTY');
                     END IF;
                      AddMissingArgMsg(
                           p_api_name    =>  l_api_name_full,
                           p_param_name  =>  'p_cas_id' );
                      RAISE FND_API.G_EXC_ERROR;
               END IF;
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
--              IF PG_DEBUG < 10  THEN
              IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                 IEX_DEBUG_PUB.LogMessage('ReassignCaseObjects: ' || 'Required Parameter p_cas_id is invalid');
              END IF;
              AddInvalidArgMsg(
                   p_api_name    =>  l_api_name_full,
                   p_param_value =>  p_cas_id,
                   p_param_name  =>  'p_cas_id' );
               RAISE FND_API.G_EXC_ERROR;
        WHEN OTHERS THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;

    -- Store the old case Id , will be used for re-score
       BEGIN
            select a.cas_id ,b.contract_number
            into l_old_case_id,l_contract_number
            from iex_case_objects a, okc_k_headers_b b
            where a.object_id =p_object_id
            and b.id =a.object_id;

--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               iex_debug_pub.logmessage ('ReassignCaseObjects: ' || 'old case Id ' || l_old_case_id);
            END IF;
--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               iex_debug_pub.logmessage ('ReassignCaseObjects: ' || 'Contract Number ' || l_contract_number);
            END IF;

       EXCEPTION WHEN OTHERS THEN
          NULL;
       END;

   -- Check if the case has any later stage delinquencies
   --if there is do not re assign, exit out.
      IF CheckAdvanceDelinquencies(l_old_case_id,x_del_id) THEN
--          IF PG_DEBUG < 10  THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             iex_debug_pub.logmessage ('ReassignCaseObjects: ' || l_old_case_id  || ' has later stage of delinquencies');
          END IF;
          fnd_message.set_name('IEX', 'IEX_ADVANCE_DEL_EXISTS');
          fnd_message.set_token('DEL_ID', x_del_id);
          fnd_message.set_token('CASE_ID',l_old_case_id);
          fnd_message.set_token('CON_NUM',l_contract_number);
          fnd_msg_pub.add;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

       END IF;

     --Delete the contract/object from case objects table
      select case_object_id into l_case_object_id
      from iex_case_objects
      where object_id =p_object_id;

       iex_case_objects_pvt.delete_case_objects(
          P_Api_Version_Number         =>l_api_version_number,
          P_Init_Msg_List              =>FND_API.G_TRUE,
          P_Commit                     =>FND_API.G_FALSE,
          p_validation_level           =>P_validation_level,
          P_case_object_ID             =>l_case_object_id,
          X_Return_Status              =>l_return_status,
          X_Msg_Count                  =>l_msg_count,
          X_Msg_Data                   =>l_msg_data);

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
             AddFailMsg( p_object     =>  'CASE OBJECTS',
                         p_operation  =>  'DELETE' );
             raise FND_API.G_EXC_ERROR;
         ELSE
--              IF PG_DEBUG < 10  THEN
              IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                 iex_debug_pub.logmessage ('ReassignCaseObjects: ' ||  'deletion of ' || p_object_id
                                         ||' successfull');
              END IF;
         END IF;



   --END IF; --end of item level validation
--   IF PG_DEBUG < 10  THEN
   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      iex_debug_pub.logMessage('ReassignCaseObjects: ' || 'After Item validation ');
   END IF;

 --- Check Case Definition
 --  If case Id exists, call case_object_pvt with the given case_id
 -- To create the case objects
 -- otherwise, check case def, retrieve case number and then
 -- call case_object_pvt. If case does not exist, create case defintiton and
 -- and create case and then finally create case object.

   IF (l_cas_id IS NOT NULL) AND (l_cas_id <> FND_API.G_MISS_NUM) THEN
--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logMessage('ReassignCaseObjects: ' || 'case Id is passed '||l_cas_id);
       END IF;
       --Populate Case object record
         PopulateCaseObjectRec(p_object_code           =>l_object_code,
                               p_object_id             =>p_object_id,
                               p_cas_id                =>l_cas_id,
                               p_attribute_rec         =>p_cas_rec,
                               x_case_object_rec       =>l_case_object_Rec);
       --Call create_case_object_pvt to create Case object_id
--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logMessage('ReassignCaseObjects: ' || '---------------------------------');
       END IF;
       iex_case_objects_pvt.Create_case_objects(
          P_Api_Version_Number         =>l_api_version_number,
          P_Init_Msg_List              =>FND_API.G_FALSE,
          P_Commit                     =>FND_API.G_FALSE,
          p_validation_level           =>P_validation_level,
          P_case_object_Rec            =>l_case_object_Rec,
          x_case_object_id             =>l_case_object_id,
          X_Return_Status              =>l_return_status,
          X_Msg_Count                  =>l_msg_count,
          X_Msg_Data                   =>l_msg_data);

--         IF PG_DEBUG < 10  THEN
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            iex_debug_pub.logMessage('ReassignCaseObjects: ' || 'Status of Create Case object PVT => '||l_return_status);
         END IF;
           -- Check return status from the above procedure call
          IF l_return_status = FND_API.G_RET_STS_ERROR then
  		    FND_MESSAGE.SET_NAME('IEX', 'IEX_FAILED_CREATE_CO');
		    FND_MSG_PUB.Add;
            raise FND_API.G_EXC_ERROR;
          elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
             raise FND_API.G_EXC_UNEXPECTED_ERROR;
          else
              x_case_object_id :=l_case_object_id;
--              IF PG_DEBUG < 10  THEN
              IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                 iex_debug_pub.logMessage('ReassignCaseObjects: ' || 'Value of x_case_object_id =>' ||x_case_object_id);
              END IF;
          END IF;

    ELSE  -- Check if case definition is valid and
          --get case id for the given case definition
--          IF PG_DEBUG < 10  THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             iex_debug_pub.logMessage('ReassignCaseObjects: ' || 'case Id is not passed ');
          END IF;
--          IF PG_DEBUG < 10  THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             iex_debug_pub.logMessage('ReassignCaseObjects: ' || '---------------------------------');
          END IF;
           If CheckCaseDef(P_case_definition_tbl) THEN
--               IF PG_DEBUG < 10  THEN
               IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                  iex_debug_pub.logMessage('ReassignCaseObjects: ' || 'case Defintion is Valid ');
               END IF;
               --Get case Id for the given Case definition
--               IF PG_DEBUG < 10  THEN
               IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                  iex_debug_pub.logMessage('ReassignCaseObjects: ' || '---------------------------------');
               END IF;
               GetCaseId(
                           P_case_definition_tbl=>P_case_definition_tbl,
                           x_cas_id             =>l_cas_id);
               --Case definition is valid and if a matching case is found
--               IF PG_DEBUG < 10  THEN
               IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                  iex_debug_pub.logMessage('ReassignCaseObjects: ' || '---------------------------------');
               END IF;
               if l_cas_id  is NOT NULL THEN
--                   IF PG_DEBUG < 10  THEN
                   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                      iex_debug_pub.logMessage('ReassignCaseObjects: ' || 'Matching case is found and CAS ID is => '||l_Cas_id);
                   END IF;
                   --Populate Case object record
                     PopulateCaseObjectRec(p_object_code           =>l_object_code,
                                           p_object_id             =>p_object_id,
                                           p_cas_id                =>l_cas_id,
                                           p_attribute_rec         =>p_cas_rec,
                                           x_case_object_rec       =>l_case_object_Rec);
                      --Call create_case_object_pvt to create Case object_id
--                         IF PG_DEBUG < 10  THEN
                         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                            iex_debug_pub.logMessage('ReassignCaseObjects: ' || 'Before Calling Create Case Object PVT');
                         END IF;
--                          IF PG_DEBUG < 10  THEN
                          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                             iex_debug_pub.logMessage('ReassignCaseObjects: ' || '---------------------------------');
                          END IF;
                          iex_case_objects_pvt.Create_case_objects(
                             P_Api_Version_Number         =>l_api_version_number,
                             P_Init_Msg_List              =>FND_API.G_FALSE,
                             P_Commit                     =>FND_API.G_FALSE,
                             p_validation_level           =>P_validation_level,
                             P_case_object_Rec            =>l_case_object_Rec,
                             x_case_object_id             =>l_case_object_id,
                             X_Return_Status              =>l_return_status,
                             X_Msg_Count                  =>l_msg_count,
                             X_Msg_Data                   =>l_msg_data);
--                    IF PG_DEBUG < 10  THEN
                    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                       iex_debug_pub.logMessage('ReassignCaseObjects: ' || 'After Calling Create Case Object PVT and Status =>'||l_return_status);
                    END IF;
                 -- Check return status from the above procedure call
                     IF l_return_status = FND_API.G_RET_STS_ERROR then
                         AddFailMsg( p_object     =>  'CASE OBJECTS',
                                     p_operation  =>  'INSERT' );
                        raise FND_API.G_EXC_ERROR;
                    elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                    else
                        x_case_object_id :=l_case_object_id;
--                        IF PG_DEBUG < 10  THEN
                        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                           iex_debug_pub.logMessage('ReassignCaseObjects: ' || 'Value of x_case_object_id =>' ||x_case_object_id);
                        END IF;

                     END IF;
               Else
                 --If Case Definition is valid , but no matching Case,then create
                 -- Case , Create case defintion and then create case object
                 -- Populate Case Record
--                    IF PG_DEBUG < 10  THEN
                    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                       iex_debug_pub.logMessage('ReassignCaseObjects: ' || 'Case Definition  is Valid , no case found');
                    END IF;
                    PopulateCaseRec(p_case_number           =>p_case_number,
                                    p_comments              =>p_case_comments,
                                    p_org_id                =>l_org_id,
                                    p_case_established_date =>l_case_established_date,
                                    p_attribute_rec         =>p_cas_rec,
                                    x_cas_rec               =>l_cas_rec);
				 l_cas_rec.party_id :=p_party_id;
                    --Call iex_cases_pvt to create a case

--                    IF PG_DEBUG < 10  THEN
                    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                       iex_debug_pub.logMessage('ReassignCaseObjects: ' || 'Before Calling Create Case  PVT');
                    END IF;
--                    IF PG_DEBUG < 10  THEN
                    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                       iex_debug_pub.logMessage('ReassignCaseObjects: ' || '---------------------------------');
                    END IF;

                    -- added by ehuh Aug 10 2003

                    begin

		    --Begin bug#5373412 schekuri 10-Jul-2006
		    --Call new consolidated procedure get_assigned_collector
                    /*iex_utilities.get_case_resources(p_api_version      => 1.0,
                                                       p_init_msg_list    => FND_API.G_TRUE,
                                                       p_commit           => FND_API.G_FALSE,
                                                       p_validation_level => p_validation_level,
                                                       x_msg_count        => l_msg_count,
                                                       x_msg_data         => l_msg_data,
                                                       x_return_status    => l_return_status,
                                                       p_party_id         => l_cas_rec.party_id,
                                                       x_resource_tab     => l_resource_tab);*/

		    iex_utilities.get_assigned_collector(p_api_version => 1.0,
	  				     p_init_msg_list     => FND_API.G_TRUE,
					     p_commit            => FND_API.G_FALSE,
					     p_validation_level  => p_validation_level,
					     p_level             => 'CASE',
					     p_level_id          => l_cas_rec.party_id,
					     x_msg_count         => l_msg_count,
					     x_msg_data          => l_msg_data,
					     x_return_status     => l_return_status,
					     x_resource_tab      => l_resource_tab);

                    --End bug#5373412 schekuri 10-Jul-2006

                  if l_resource_tab.COUNT >0 THEN
                     l_cas_rec.owner_resource_id := l_resource_tab(1).resource_id;
                  else
                     l_cas_rec.owner_resource_id := l_resource_id;
                  end if;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                    iex_debug_pub.logMessage('Get_assign_resource(R) : ' || 'After Calling Get_assign_resource and Status =>'||l_return_status);
                    iex_debug_pub.logMessage('Resource ID : ' || l_cas_rec.owner_resource_id );
END IF;

                    exception
                      when others then
                           null;

                    end;

                    -- ended by ehuh Aug 10 2003

                    iex_cases_pvt.Create_CAS(
                             P_Api_Version_Number         =>l_api_version_number,
                             P_Init_Msg_List              =>FND_API.G_FALSE,
                             P_Commit                     =>FND_API.G_FALSE,
                             p_validation_level           =>P_validation_level,
                             P_cas_Rec                    =>l_cas_Rec,
                             x_case_id                    =>l_cas_id,
                             X_Return_Status              =>l_return_status,
                             X_Msg_Count                  =>l_msg_count,
                             X_Msg_Data                   =>l_msg_data);
--                     IF PG_DEBUG < 10  THEN
                     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                        iex_debug_pub.logMessage('ReassignCaseObjects: ' || 'After Calling Create Case  PVT and Status =>'||l_return_status);
                     END IF;
                      IF l_return_status = FND_API.G_RET_STS_ERROR then
                         AddFailMsg( p_object     =>  'CASE',
                                     p_operation  =>  'INSERT' );
                        raise FND_API.G_EXC_ERROR;
                    elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                     END IF;
                  --Call iex_case_definition_pvt to create case_def
               		FOR i IN 1..P_case_definition_tbl.COUNT LOOP
                        --Populate Case Definition record
                         PopulateCaseDefRec(p_column_name    =>p_case_definition_tbl(i).column_name,
                                            p_column_value   =>p_case_definition_tbl(i).column_value,
                                            p_table_name     =>p_case_definition_tbl(i).table_name,
                                            p_cas_id         =>l_cas_id,
                                            p_attribute_rec  =>p_cas_rec,
                                            x_case_def_rec   =>l_case_definition_Rec);
--                        IF PG_DEBUG < 10  THEN
                        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                           iex_debug_pub.logMessage('ReassignCaseObjects: ' || 'Before Calling Create Case Definition  PVT');
                        END IF;
--                        IF PG_DEBUG < 10  THEN
                        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                           iex_debug_pub.logMessage('ReassignCaseObjects: ' || '---------------------------------');
                        END IF;
                        iex_case_definitions_pvt.create_case_definitions(
                             P_Api_Version_Number         =>l_api_version_number,
                             P_Init_Msg_List              =>FND_API.G_FALSE,
                             P_Commit                     =>FND_API.G_FALSE,
                             p_validation_level           =>P_validation_level,
                             p_case_definition_rec        =>l_case_definition_Rec,
                             x_case_definition_id         =>l_case_definition_id,
                             X_Return_Status              =>l_return_status,
                             X_Msg_Count                  =>l_msg_count,
                             X_Msg_Data                   =>l_msg_data);
--                      IF PG_DEBUG < 10  THEN
                      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                         iex_debug_pub.logMessage('ReassignCaseObjects: ' || 'After Calling Create Case Definition PVT and Status =>'||l_return_status);
                      END IF;
                      IF l_return_status = FND_API.G_RET_STS_ERROR then
                        AddFailMsg( p_object      =>  'CASE DEFINITIONS',
                                     p_operation  =>  'INSERT' );
                        raise FND_API.G_EXC_ERROR;
                    elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                     END IF;
                  END LOOP;
                     --Populate Case object record
                     PopulateCaseObjectRec(p_object_code           =>l_object_code,
                                           p_object_id             =>p_object_id,
                                           p_cas_id                =>l_cas_id,
                                           p_attribute_rec         =>p_cas_rec,
                                           x_case_object_rec       =>l_case_object_Rec);
                      --Call create_case_object_pvt to create Case object_id
--                      IF PG_DEBUG < 10  THEN
                      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                         iex_debug_pub.logMessage('ReassignCaseObjects: ' || 'Before Calling Create Case Object PVT');
                      END IF;
--                      IF PG_DEBUG < 10  THEN
                      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                         iex_debug_pub.logMessage('ReassignCaseObjects: ' || '---------------------------------');
                      END IF;
                      iex_case_objects_pvt.Create_case_objects(
                             P_Api_Version_Number         =>l_api_version_number,
                             P_Init_Msg_List              =>FND_API.G_FALSE,
                             P_Commit                     =>FND_API.G_FALSE,
                             p_validation_level           =>P_validation_level,
                             P_case_object_Rec            =>l_case_object_Rec,
                             x_case_object_id             =>l_case_object_id,
                             X_Return_Status              =>l_return_status,
                             X_Msg_Count                  =>l_msg_count,
                             X_Msg_Data                   =>l_msg_data);
--                     IF PG_DEBUG < 10  THEN
                     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                        iex_debug_pub.logMessage('ReassignCaseObjects: ' || 'After Calling Create Case Object PVT and Status =>'||l_return_status);
                     END IF;
                 -- Check return status from the above procedure call
                     IF l_return_status = FND_API.G_RET_STS_ERROR then
                            AddFailMsg( p_object     =>  'CASE OBJECTS',
                                        p_operation  =>  'INSERT' );
                        raise FND_API.G_EXC_ERROR;
                    elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                    else
                       x_case_object_id :=l_case_object_id;
--                       IF PG_DEBUG < 10  THEN
                       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                          iex_debug_pub.logMessage('ReassignCaseObjects: ' || 'Value of x_case_object_id =>' ||x_case_object_id);
                       END IF;
                     END IF;

               END IF; -- end of if G_match_Case_id  is NOT NULL
        ELSE -- if case Definition is invalid then error out.
             --How to assign value of parameter,since it is table?
--               IF PG_DEBUG < 10  THEN
               IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                  iex_debug_pub.logMessage('ReassignCaseObjects: ' || 'Case Definition is invalid');
               END IF;
               AddInvalidArgMsg(
                      p_api_name    =>  l_api_name_full,
                      p_param_value =>  'P_case_definition_tbl',
                      p_param_name  =>  'P_case_definition_tbl' );
               RAISE FND_API.G_EXC_ERROR;

        END IF; --If CheckCaseDef(P_case_definition_tbl)
    END IF; -- (l_cas_id IS NOT NULL) OR (l_cas_id <> FND_API.G_MISS_NUM)

--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage ('ReassignCaseObjects: ' ||  'Case creation over, ready for notification');
    END IF;


     OPEN c_contract(p_object_id);
     FETCH c_contract INTO l_contract_number;
     CLOSE c_contract;
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('ReassignCaseObjects: ' || 'contract Number'||l_contract_number);
     END IF;


     OPEN c_getname(l_old_case_id);
     FETCH c_getname INTO l_case_agent;
     CLOSE c_getname;
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage ('ReassignCaseObjects: ' || 'case agent'||l_case_Agent);
     END IF;

     --l_case_agent :='KWALKER';

     if l_case_agent is not null THEN
        send_notification
          ( p_OldCaseID      => l_old_case_id,
            p_NewCaseID      => l_cas_id,
            p_ContractNumber =>l_contract_number,
            p_CaseAgent      =>l_case_agent,
            x_return_status  =>l_return_status);
     else
--          IF PG_DEBUG < 10  THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             iex_debug_pub.logmessage ('ReassignCaseObjects: ' || 'Could not send notification');
          END IF;
          l_return_status :='F';
     end if;



      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

     -- we still want to commit the changes , but send the message indicating notification did
     --not happen

     if l_return_status <> 'S' THEN

          FND_MSG_PUB.initialize;
         fnd_message.set_name('IEX', 'IEX_CASE_NOTIFICATION');
          fnd_message.set_token('OLD_CASE',l_old_case_id);
          fnd_message.set_token('NEW_CASE',l_cas_id);
          fnd_message.set_token('CON_NUM',l_contract_number);
          fnd_msg_pub.add;
          x_return_status := 'N';
     End if;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage ('ReassignCaseObjects: ' || '*********End of Procedure => '||l_api_name||' *********');
     END IF;
     EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO REASSIGNCASEOBJECTS_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                x_msg_count := l_msg_count ;
                x_msg_data  := l_msg_data ;
                FND_MSG_PUB.Count_And_Get( p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data);
           WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO REASSIGNCASEOBJECTS_PUB;
                x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
                x_msg_count := l_msg_count ;
                x_msg_data  := l_msg_data ;
                FND_MSG_PUB.Count_And_Get( p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data);

          WHEN OTHERS THEN
                ROLLBACK TO REASSIGNCASEOBJECTS_PUB;
                x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
                x_msg_count := l_msg_count ;
                x_msg_data  := l_msg_data ;
                FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME,l_api_name);
                FND_MSG_PUB.Count_And_Get( p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data);
  END ReassignCaseObjects;


/* Name   UpdateCase
**  api  : Current version 2.0
** Purpose To update a case. Change the status from delinquent to current when the case
** comes out NOCOPY of delinquency
**
*/
PROCEDURE UpdateCase(
          P_Api_Version_Number         IN   NUMBER,
          P_Init_Msg_List              IN   VARCHAR2     ,
          P_Commit                     IN   VARCHAR2    ,
          P_validation_level           IN   NUMBER       ,
          p_cas_rec                    IN    CAS_Rec_Type  ,
          X_Return_Status              OUT NOCOPY  VARCHAR2,
          X_Msg_Count                  OUT NOCOPY  NUMBER,
          X_Msg_Data                   OUT NOCOPY  VARCHAR2
          ) IS

l_api_name                CONSTANT VARCHAR2(30) := 'UpdateCase';
l_api_name_full           CONSTANT VARCHAR2(61) := g_pkg_name || '.' || l_api_name;
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_cas_id		           NUMBER            ;
l_return_status           VARCHAR2(1);
l_msg_count               NUMBER;
l_msg_data                VARCHAR2(32767);
l_case_object_id          NUMBER;
l_case_definition_id      NUMBER;
l_cas_rec                 iex_cases_pvt.cas_rec_type
                                         := iex_cases_pvt.g_miss_cas_rec;
l_object_version_number   NUMBER;
 BEGIN
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage ('UpdateCase: ' || '*********Start of Procedure => '||l_api_name||' *********');
     END IF;
      -- Standard Start of API savepoint
      SAVEPOINT UPDATECASE_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                           	               p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logMessage('UpdateCase: ' || 'After Api compatability Check');
     END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- API body
      --
      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('IEX', 'IEX_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logMessage('UpdateCase: ' || 'After FND_GLOBAL_USER Check');
      END IF;

          -- Item level validation
      IF (p_validation_level > fnd_api.g_valid_level_none) THEN

         -- Check for valid cas_id
         BEGIN
              IF (p_cas_rec.cas_id IS NOT NULL) AND (p_cas_rec.cas_id <> FND_API.G_MISS_NUM) THEN
                 --May have to check for status_code too.
                  SELECT cas_id,object_version_number
                  INTO l_cas_id,l_object_version_number
                  FROM iex_cases_all_b
                  WHERE cas_id = p_cas_rec.cas_id
			   and active_flag ='Y';

               ELSE
                   AddMissingArgMsg(
                          p_api_name    =>  l_api_name_full,
                          p_param_name  =>  'p_cas_rec.cas_id' );
                    RAISE FND_API.G_EXC_ERROR;
               END IF;
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
                    AddInvalidArgMsg(
                          p_api_name    =>  l_api_name_full,
                          p_param_name  =>  'p_cas_rec.cas_id' ,
                          p_param_value =>  p_cas_rec.cas_id);
                    RAISE FND_API.G_EXC_ERROR;
                   fnd_msg_pub.add;
                   RAISE FND_API.G_EXC_ERROR;
          WHEN OTHERS THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END;

   END IF; --end of item level validation
--   IF PG_DEBUG < 10  THEN
   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      iex_debug_pub.logMessage('UpdateCase: ' || 'After Item validation ');
   END IF;

   -- Call update Case PVT to update
        PopulateCaseRec(p_attribute_rec         =>p_cas_rec,
                       p_comments            => fnd_api.g_miss_char,
                       p_org_id               =>  fnd_api.g_miss_num,
                       p_case_established_date => fnd_api.g_miss_date,
                       x_cas_rec               =>l_cas_rec,
                       p_case_number           => fnd_api.g_miss_char);

       l_cas_rec.cas_id                :=l_cas_id;
       l_cas_rec.object_version_number :=l_object_version_number;


--   IF PG_DEBUG < 10  THEN
   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      iex_debug_pub.logMessage('UpdateCase: ' || 'Before Calling  Update  PVT');
   END IF;
   iex_cases_pvt.update_cas
                        (P_Api_Version_Number         =>l_api_version_number,
                         P_Init_Msg_List              =>FND_API.G_FALSE,
                         P_Commit                     =>FND_API.G_FALSE,
                         p_validation_level           =>P_validation_level,
                         P_cas_Rec                    =>l_cas_Rec,
                         X_Return_Status              =>l_return_status,
                         X_Msg_Count                  =>l_msg_count,
                         X_Msg_Data                   =>l_msg_data,
                         xo_object_version_number     =>l_object_version_number);
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logMessage('UpdateCase: ' || 'After Calling update case  PVT and Status =>'||l_return_status);
    END IF;

    IF l_return_status = FND_API.G_RET_STS_ERROR then
        AddFailMsg( p_object     =>  'CASE ',
                    p_operation  =>  'UPDATE' );
       raise FND_API.G_EXC_ERROR;
    elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
       raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage ('UpdateCase: ' || '*********End of Procedure => '||l_api_name||' *********');
     END IF;
      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
   END UpdateCase;

/* Name   CreateCaseContacts
**  api  : Current version 2.0
** Purpose: To create case Contacts. A table of contacts along with
** the table of roles is passed.
** For a case. There could only be 1 primary contact per case
** the address id and phone for a contact are optional, if it is not passed
** the procedure picks the default address and phone id based on the contact id.
** The contact id in the contact_tbl and roles_tbl are party id's with party type of
** 'party_Relationship'
** 11/20/01******
** since a contact could have multiple roles,the primary flag has been moved over
** to contact roles from contacts table.
** 01/07/02
**  The contact roles has been descoped, so primary flag has been moved to
**  contacts table and the contact roles table is obsolete.

*/
PROCEDURE CreateCasecontacts(
          P_Api_Version_Number         IN   NUMBER,
          P_Init_Msg_List              IN   VARCHAR2     ,
          P_Commit                     IN   VARCHAR2     ,
          P_validation_level           IN   NUMBER       ,
          P_case_contact_tbl           IN   CASE_CONTACT_TBL_TYPE ,
          P_cas_id                     IN NUMBER        ,
          X_Return_Status              OUT NOCOPY  VARCHAR2,
          X_Msg_Count                  OUT NOCOPY  NUMBER,
          X_Msg_Data                   OUT NOCOPY  VARCHAR2)
          IS
l_api_name                CONSTANT VARCHAR2(30) := 'CREATECASECONTACTS';
l_api_name_full	          CONSTANT VARCHAR2(61) := g_pkg_name || '.' || l_api_name;
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_cas_id		          NUMBER            :=p_cas_id;
l_return_status           VARCHAR2(1);
l_msg_count               NUMBER;
l_msg_data                VARCHAR2(32767);
l_case_object_id          NUMBER;
l_case_contact_id         NUMBER;
l_case_contact_role_id    NUMBER;
l_case_contact_rec                iex_case_contacts_pvt.case_contact_rec_type
                                    := iex_case_contacts_pvt.g_miss_case_contact_rec;
--l_case_contact_role_rec          iex_case_contact_roles_pvt.case_contact_role_rec_type
--                                  := iex_case_contact_roles_pvt.g_miss_case_contact_role_rec;
l_assign                  BOOLEAN  DEFAULT FALSE;
BEGIN
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage ('CreateCasecontacts: ' || '*********Start of Procedure => '||l_api_name||' *********');
     END IF;
      -- Standard Start of API savepoint
      SAVEPOINT CREATECASECONTACTS_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                           	               p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logMessage('CreateCasecontacts: ' || 'After Api compatability Check');
     END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- API body
      --
      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('IEX', 'IEX_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logMessage('CreateCasecontacts: ' || 'After FND_GLOBAL_USER Check');
     END IF;
      -- Check for required parameter cas_id
         IF (p_cas_id IS NULL) OR (p_cas_id = FND_API.G_MISS_NUM) THEN
--             IF PG_DEBUG < 10  THEN
             IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                IEX_DEBUG_PUB.LogMessage('CreateCasecontacts: ' || 'Required Parameter p_cas_id is invalid');
             END IF;
              AddMissingArgMsg(
                      p_api_name    =>  l_api_name_full,
                      p_param_name  =>  'p_cas_id' );
              RAISE FND_API.G_EXC_ERROR;
          END IF;
          --Call iex_case_contacts_pvt to create contacts
        	FOR i IN 1..P_case_contact_tbl.COUNT LOOP
                l_case_contact_Rec.cas_id           :=P_cas_id;
                l_case_contact_Rec.contact_party_id :=P_case_contact_tbl(i).contact_party_id;
                l_case_contact_Rec.address_id       :=P_case_contact_tbl(i).address_id;
                l_case_contact_Rec.phone_id         :=P_case_contact_tbl(i).phone_id;
                l_case_contact_Rec.primary_flag     :=P_case_contact_tbl(i).primary_flag;
--                IF PG_DEBUG < 10  THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                   iex_debug_pub.logMessage('CreateCasecontacts: ' || 'Before Calling Create Case Contacts  PVT');
                END IF;
--                IF PG_DEBUG < 10  THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                   iex_debug_pub.logMessage('CreateCasecontacts: ' || '---------------------------------');
                END IF;
                iex_case_contacts_pvt.create_case_contact(
                             P_Api_Version_Number         =>l_api_version_number,
                             P_Init_Msg_List              =>FND_API.G_FALSE,
                             P_Commit                     =>FND_API.G_FALSE,
                             p_validation_level           =>P_validation_level,
                             p_case_contact_rec           =>l_case_contact_Rec,
                             x_cas_contact_id             =>l_case_contact_id,
                             X_Return_Status              =>l_return_status,
                             X_Msg_Count                  =>l_msg_count,
                             X_Msg_Data                   =>l_msg_data);
--                IF PG_DEBUG < 10  THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                   iex_debug_pub.logMessage('CreateCasecontacts: ' || 'After Calling Create Case'||
                            'contacts PVT and Status =>'||l_return_status);
                END IF;
                IF l_return_status = FND_API.G_RET_STS_ERROR then
                         AddFailMsg( p_object     =>  'CASE CONTACTS',
                                     p_operation  =>  'INSERT' );
                    raise FND_API.G_EXC_ERROR;
                elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
                 /*
                 ELSE -- if case contact insert = success
                     --if it is a primary contact
                     if P_case_contact_tbl(i).primary_flag = 'Y' THEN
                        l_assign := TRUE;
                     END IF;

                     FOR j IN 1..P_case_contact_roles_tbl.COUNT LOOP
--                         IF PG_DEBUG < 10  THEN
                         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                            iex_debug_pub.LogMessage ('CreateCasecontacts: ' || 'Roles for contact Party_id = '||
                                                    P_case_contact_roles_tbl(j).contact_party_id||
                                                   'P_case_contact_tbl(i).contact_party_id ='||
                                                    P_case_contact_tbl(i).contact_party_id);
                         END IF;
                         If P_case_contact_roles_tbl(j).contact_party_id =
                                  P_case_contact_tbl(i).contact_party_id   THEN

                               -- if the contact is primary , assign the first role as the primary
                              If P_case_contact_tbl(i).primary_flag = 'Y' and l_assign THEN
                                 l_case_contact_role_Rec.primary_role_flag  := 'Y';
                                 l_assign := FALSE;
                              else
                                 l_case_contact_role_Rec.primary_role_flag  := 'N';
                              End if;

                              l_case_contact_role_rec.cas_contact_id        :=l_case_contact_id;
                              l_case_contact_role_rec.cas_contact_role_code :=P_case_contact_roles_tbl(j).CONTACT_ROLE;


--                              IF PG_DEBUG < 10  THEN
                              IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                                 iex_debug_pub.logMessage('CreateCasecontacts: ' || 'Before Calling Create Case Contact roles  PVT');
                              END IF;
--                              IF PG_DEBUG < 10  THEN
                              IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                                 iex_debug_pub.logMessage('CreateCasecontacts: ' || '---------------------------------');
                              END IF;
                              iex_case_contact_roles_pvt.create_case_contact_roles(
                                  P_Api_Version_Number         =>l_api_version_number,
                                  P_Init_Msg_List              =>FND_API.G_FALSE,
                                  P_Commit                     =>FND_API.G_FALSE,
                                  p_validation_level           =>P_validation_level,
                                  p_case_contact_role_rec      =>l_case_contact_role_Rec,
                                  x_cas_contact_role_id       =>l_case_contact_role_id,
                                  X_Return_Status              =>l_return_status,
                                  X_Msg_Count                  =>l_msg_count,
                                  X_Msg_Data                   =>l_msg_data);
--                              IF PG_DEBUG < 10  THEN
                              IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                                 iex_debug_pub.logMessage('CreateCasecontacts: ' || 'After Calling Create Case'||
                                       'contacts roles PVT and Status =>'||l_return_status);
                              END IF;
                              IF l_return_status = FND_API.G_RET_STS_ERROR then
                       	             AddFailMsg( p_object     =>  'CASE CONTACT ROLES',
                                                 p_operation  =>  'INSERT' );
                                 raise FND_API.G_EXC_ERROR;
                              elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
                                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
                              END IF;
                         END IF; --contact party id are similar
                     END LOOP; --contact roles table loop
--                     IF PG_DEBUG < 10  THEN
                     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                        iex_debug_pub.logMessage('CreateCasecontacts: ' || 'After creation of Case'||
                                  'contacts roles for cas_contact_id '||l_case_contact_id);
                     END IF;
                 */
                 END IF; --checking return status of case contact insert
           END LOOP;
--          IF PG_DEBUG < 10  THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             IEX_DEBUG_PUB.LogMessage ('CreateCasecontacts: ' || '*********End of Procedure => '||l_api_name||' *********');
          END IF;

 -- Debug Message
 -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

END CreateCasecontacts;

/* Name   CheckContract
** Used by the OKL wrapper to decide whether to call createCaseObjects or
** reassign Case when Bill_to_address or any case attribute is changed
*/
Function CheckContract
          (P_ObjectID   IN NUMBER
          )Return BOOLEAN IS
x_ObjectID iex_case_Objects.object_id%TYPE;
Begin
      Select object_id  INTO x_ObjectID
      from iex_case_objects
      where object_id =P_ObjectID;
      return TRUE;
EXCEPTION WHEN OTHERS THEN
     Return FALSE;

End CheckContract;


END IEX_CASE_UTL_PUB;



/
