--------------------------------------------------------
--  DDL for Package AR_INTEREST_BATCHES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_INTEREST_BATCHES_PKG" AUTHID CURRENT_USER AS
/* $Header: ARIIBATS.pls 120.3 2006/03/31 20:17:46 hyu noship $ */

FUNCTION get_batch_amount
(p_interest_batch_id   IN NUMBER)
RETURN NUMBER;

PROCEDURE Lock_batch
( p_Interest_Batch_Id            IN  NUMBER,
  p_Batch_Name                   IN  VARCHAR2,
  p_Calculate_Interest_To_Date   IN  DATE,
  p_Gl_Date                      IN  DATE,
  p_Transferred_status           IN  VARCHAR2,
  p_batch_status                 IN  VARCHAR2,
  p_Org_Id                       IN  NUMBER,
  p_object_version_number        IN  NUMBER,
  x_return_status        OUT NOCOPY  VARCHAR2,
  x_msg_count            OUT NOCOPY  NUMBER,
  x_msg_data             OUT NOCOPY  VARCHAR2);

PROCEDURE  Validate_batch
( p_action                IN VARCHAR2,
  p_updated_by_program    IN VARCHAR2 DEFAULT 'ARIINR',
  p_old_batch_rec         IN ar_interest_batches%ROWTYPE,
  p_new_batch_rec         IN ar_interest_batches%ROWTYPE,
  x_cascade_update        OUT NOCOPY VARCHAR2,
  x_return_status         IN OUT NOCOPY  VARCHAR2);


PROCEDURE Delete_batch
( p_init_msg_list         IN VARCHAR2 := fnd_api.g_false,
  p_interest_batch_id     IN NUMBER,
  x_object_version_number IN NUMBER,
  x_return_status         OUT NOCOPY  VARCHAR2,
  x_msg_count             OUT NOCOPY  NUMBER,
  x_msg_data              OUT NOCOPY  VARCHAR2);


PROCEDURE update_batch
(p_init_msg_list              IN VARCHAR2 := fnd_api.g_false,
 P_INTEREST_BATCH_ID          IN NUMBER,
 P_BATCH_STATUS               IN VARCHAR2,
 P_TRANSFERRED_status         IN VARCHAR2,
 p_gl_date                    IN DATE     DEFAULT NULL,
 p_updated_by_program         IN VARCHAR2 DEFAULT 'ARIINR',
 x_OBJECT_VERSION_NUMBER      IN OUT NOCOPY NUMBER,
 x_return_status              OUT NOCOPY  VARCHAR2,
 x_msg_count                  OUT NOCOPY  NUMBER,
 x_msg_data                   OUT NOCOPY  VARCHAR2);

END AR_INTEREST_BATCHES_PKG;

 

/
