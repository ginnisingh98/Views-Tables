--------------------------------------------------------
--  DDL for Package Body CN_PREPOSTBATCHES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PREPOSTBATCHES" AS
-- $Header: cntpbatb.pls 120.2 2005/09/14 12:32:40 fmburu ship $

-- Default Posting Batch.Load_Status Value
C_UNLOADED     CONSTANT VARCHAR2(30) := 'UNLOADED';
G_PKG_NAME       CONSTANT VARCHAR2(30) := 'CN_PREPOSTBATCHES';
G_LAST_UPDATE_DATE        DATE         := SYSDATE;
G_LAST_UPDATED_BY         NUMBER       := FND_GLOBAL.USER_ID;
G_CREATION_DATE           DATE         := SYSDATE;
G_CREATED_BY              NUMBER       := FND_GLOBAL.USER_ID;
G_LAST_UPDATE_LOGIN       NUMBER       := FND_GLOBAL.LOGIN_ID;

PROCEDURE Get_UID( x_posting_batch_id  IN OUT NOCOPY NUMBER )
IS
   CURSOR get_id IS
      SELECT cn_posting_batches_s.nextval
      FROM   dual;
BEGIN
   OPEN  get_id;
   FETCH get_id INTO x_posting_batch_id;
   CLOSE get_id;
END Get_UID;

PROCEDURE Insert_Record
(   x_rowid                          IN OUT NOCOPY VARCHAR2,
    x_posting_batch_id                      NUMBER,
    x_name                                  VARCHAR2,
    x_start_date                            DATE    ,
    x_end_date                              DATE    ,
    x_load_status                           VARCHAR2    := C_UNLOADED,
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
    x_last_update_date                      DATE    ,
    x_last_updated_by                       NUMBER  ,
    x_last_update_login                     NUMBER  ,
    x_creation_date                         DATE        := G_CREATION_DATE,
    x_created_by                            NUMBER      := G_CREATED_BY,
    p_org_id                                NUMBER
  )
IS
      l_api_name                  CONSTANT VARCHAR2(30)      := 'Insert_Record';
BEGIN
   INSERT INTO cn_posting_batches(
      posting_batch_id,
      name,
      start_date,
      end_date,
      load_status,
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
      created_by,
      org_id
      )
   VALUES(
      x_posting_batch_id,
      x_name,
      x_start_date,
      x_end_date,
      x_load_status,
      x_attribute_category,
      x_attribute1      ,
      x_attribute2      ,
      x_attribute3      ,
      x_attribute4      ,
      x_attribute5      ,
      x_attribute6      ,
      x_attribute7      ,
      x_attribute8      ,
      x_attribute9      ,
      x_attribute10      ,
      x_attribute11      ,
      x_attribute12      ,
      x_attribute13      ,
      x_attribute14      ,
      x_attribute15      ,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_creation_date,
      x_created_by,
      p_org_id
      );
END Insert_Record;

PROCEDURE Begin_Record
(     x_operation              IN       VARCHAR2                    ,
      x_rowid                  IN OUT NOCOPY   VARCHAR2                    ,
      x_posting_batch_rec      IN OUT NOCOPY   posting_batch_rec_type      ,
      x_program_type           IN       VARCHAR2,
      p_org_id                 IN NUMBER
)
IS
      l_api_name               CONSTANT VARCHAR2(30)      := 'Begin_Record';
      l_api_version            CONSTANT NUMBER            := 1.0;
      l_posting_batch_rec      posting_batch_rec_type;
BEGIN

      IF x_operation = 'INSERT' THEN

         Insert_Record(
          x_rowid,
          x_posting_batch_rec.posting_batch_id,
          x_posting_batch_rec.name,
          x_posting_batch_rec.start_date,
          x_posting_batch_rec.end_date,
          C_UNLOADED,
          x_posting_batch_rec.attribute_category,
          x_posting_batch_rec.attribute1      ,
          x_posting_batch_rec.attribute2      ,
          x_posting_batch_rec.attribute3      ,
          x_posting_batch_rec.attribute4      ,
          x_posting_batch_rec.attribute5      ,
          x_posting_batch_rec.attribute6      ,
          x_posting_batch_rec.attribute7      ,
          x_posting_batch_rec.attribute8      ,
          x_posting_batch_rec.attribute9      ,
          x_posting_batch_rec.attribute10      ,
          x_posting_batch_rec.attribute11      ,
          x_posting_batch_rec.attribute12      ,
          x_posting_batch_rec.attribute13      ,
          x_posting_batch_rec.attribute14      ,
          x_posting_batch_rec.attribute15      ,
          x_posting_batch_rec.last_update_date,
          x_posting_batch_rec.last_updated_by,
          x_posting_batch_rec.last_update_login,
          x_posting_batch_rec.creation_date,
          x_posting_batch_rec.created_by,
          p_org_id
         );

      END IF;
END Begin_Record;

PROCEDURE posting_conc
(  errbuf               OUT NOCOPY   VARCHAR2,
   retcode              OUT NOCOPY   NUMBER,
   start_date           IN    VARCHAR2,
   end_date             IN    VARCHAR2,
   p_org_id             IN    NUMBER
)
IS
  l_api_version         NUMBER := 1.0;
  l_init_msg_list       VARCHAR2(1) := FND_API.G_TRUE;
  l_commit              VARCHAR2(1) := FND_API.G_TRUE;
  l_return_status       VARCHAR2(50);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);
  l_proc_audit_id       NUMBER(15);
  ABORT                 EXCEPTION;

  -- to convert from FND_STANDARD_DATE value set to DATE (concurrent manager
  -- passes as VARCHAR2)
  l_start_date          DATE := fnd_date.canonical_to_date(start_date);
  l_end_date            DATE := fnd_date.canonical_to_date(end_date);

BEGIN
  retcode := 0; -- success = 0, warning = 1, fail = 2

  cn_message_pkg.begin_batch(x_process_type => 'POSTING',
           x_process_audit_id => l_proc_audit_id,
           x_parent_proc_audit_id => l_proc_audit_id,
           x_request_id => fnd_global.conc_request_id,
           p_org_id       => p_org_id);

  cn_message_pkg.debug('Start Posting Details...');

  IF (l_end_date IS NULL OR l_start_date > l_end_date) THEN
     cn_message_pkg.debug('End_date is null or start date is later than the end date.');
     RAISE ABORT;
  END IF;

  --initialize message list
  fnd_msg_pub.initialize;

  cn_posting_pvt.posting_details(l_api_version,
             l_init_msg_list,
             l_commit,
             l_return_status,
             l_msg_count,
             l_msg_data,
             l_start_date,
             l_end_date,
             l_proc_audit_id);

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     retcode := 2; -- failure
  END IF;

  cn_api.get_fnd_message(l_msg_count, l_msg_data);
  cn_message_pkg.debug('End of Posting Details.');
  cn_message_pkg.end_batch(l_proc_audit_id);

  IF retcode = 0 THEN
     fnd_message.set_name('CN', 'ALL_PROCESS_DONE_OK');
     fnd_msg_pub.ADD;
     errbuf := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_last,
             p_encoded => fnd_api.g_false);
   ELSIF retcode = 1 THEN
     fnd_message.set_name('CN', 'ALL_PROCESS_DONE_WARN');
     fnd_msg_pub.ADD;
     errbuf := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_last,
             p_encoded => fnd_api.g_false);
   ELSE
     fnd_message.set_name('CN', 'ALL_PROCESS_DONE_FAIL');
     fnd_msg_pub.ADD;
     errbuf := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_last,
             p_encoded => fnd_api.g_false);
  END IF;

EXCEPTION
   WHEN OTHERS THEN
      retcode := 2;
      errbuf := SQLCODE||' '||Sqlerrm;
      cn_message_pkg.end_batch(l_proc_audit_id);
END posting_conc;

END CN_PREPOSTBATCHES;

/
