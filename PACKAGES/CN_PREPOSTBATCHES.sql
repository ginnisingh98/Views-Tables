--------------------------------------------------------
--  DDL for Package CN_PREPOSTBATCHES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PREPOSTBATCHES" AUTHID CURRENT_USER AS
-- $Header: cntpbats.pls 120.1 2005/07/12 19:29:38 appldev ship $ --+

G_BATCH_ID                NUMBER := NULL;

TYPE posting_batch_rec_type IS RECORD
  (posting_batch_id     cn_posting_batches.posting_batch_id%TYPE := null,
   name                 cn_posting_batches.name%TYPE := null,
   start_date           cn_posting_batches.start_date%TYPE := null,
   end_date             cn_posting_batches.end_date%TYPE := null,
   load_status          cn_posting_batches.load_status%TYPE := null,
   attribute_category	cn_posting_batches.attribute_category%TYPE := null,
   attribute1			cn_posting_batches.attribute1%TYPE := null,
   attribute2			cn_posting_batches.attribute2%TYPE := null,
   attribute3			cn_posting_batches.attribute3%TYPE := null,
   attribute4			cn_posting_batches.attribute4%TYPE := null,
   attribute5			cn_posting_batches.attribute5%TYPE := null,
   attribute6			cn_posting_batches.attribute6%TYPE := null,
   attribute7			cn_posting_batches.attribute7%TYPE := null,
   attribute8			cn_posting_batches.attribute8%TYPE := null,
   attribute9			cn_posting_batches.attribute9%TYPE := null,
   attribute10			cn_posting_batches.attribute10%TYPE := nulL,
   attribute11			cn_posting_batches.attribute11%TYPE := null,
   attribute12			cn_posting_batches.attribute12%TYPE := null,
   attribute13			cn_posting_batches.attribute13%TYPE := null,
   attribute14			cn_posting_batches.attribute14%TYPE := null,
   attribute15			cn_posting_batches.attribute15%TYPE := null,
   created_by			cn_posting_batches.created_by%TYPE := null,
   creation_date            cn_posting_batches.creation_date%TYPE := null,
   last_update_login        cn_posting_batches.last_update_login%TYPE := null,
   last_update_date         cn_posting_batches.last_update_date%TYPE := null,
   last_updated_by          cn_posting_batches.last_updated_by%TYPE := null
  );

PROCEDURE Get_UID( x_posting_batch_id  IN OUT NOCOPY NUMBER );

PROCEDURE Begin_Record
(     x_operation              IN       VARCHAR2,
      x_rowid                  IN OUT NOCOPY   VARCHAR2,
      x_posting_batch_rec      IN OUT NOCOPY   posting_batch_rec_type,
      x_program_type           IN       VARCHAR2,  -- not used here
      p_org_id                 IN NUMBER
);

PROCEDURE posting_conc
(  errbuf               OUT NOCOPY   VARCHAR2,
   retcode              OUT NOCOPY   NUMBER,
   start_date           IN    VARCHAR2,
   end_date             IN    VARCHAR2,
   p_org_id             IN    NUMBER
);

END CN_PREPOSTBATCHES;
 

/
