--------------------------------------------------------
--  DDL for Package CSI_ML_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_ML_UTIL_PVT" AUTHID CURRENT_USER AS
-- $Header: csimutls.pls 120.2 2007/10/30 02:34:50 anjgupta ship $

PROCEDURE resolve_ids
 (
    p_txn_from_date         IN     VARCHAR2,
    p_txn_to_date           IN     VARCHAR2,
    p_batch_name            IN     VARCHAR2,
    p_source_system_name    IN     VARCHAR2,
    x_return_status         OUT NOCOPY   VARCHAR2,
    x_error_message         OUT NOCOPY   VARCHAR2
 );

PROCEDURE resolve_pw_ids
 (
    p_txn_from_date         IN     VARCHAR2,
    p_txn_to_date           IN     VARCHAR2,
    p_source_system_name    IN     VARCHAR2,
    p_worker_id             IN     NUMBER,
    x_return_status         OUT NOCOPY   VARCHAR2,
    x_error_message         OUT NOCOPY   VARCHAR2
 );

PROCEDURE resolve_update_ids
 (
    p_source_system_name    IN     VARCHAR2,
    p_txn_identifier        IN     VARCHAR2,
    x_return_status         OUT NOCOPY   VARCHAR2,
    x_error_message         OUT NOCOPY   VARCHAR2
 );


FUNCTION Get_Txn_Type_Id(P_Txn_Type IN VARCHAR2, P_App_Short_Name IN VARCHAR2) RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(Get_Txn_Type_Id, WNDS);

PROCEDURE log_create_errors
 (
    p_txn_from_date         IN     VARCHAR2,
    p_txn_to_date           IN     VARCHAR2,
    x_return_status         OUT NOCOPY   VARCHAR2,
    x_error_message         OUT NOCOPY   VARCHAR2
 );

PROCEDURE log_create_pw_errors (p_txn_from_date         IN     VARCHAR2,
                                p_txn_to_date           IN     VARCHAR2,
                                p_source_system_name    IN     VARCHAR2,
                                p_worker_id             IN     NUMBER,
                                x_return_status         OUT NOCOPY   VARCHAR2,
                                x_error_message         OUT NOCOPY   VARCHAR2
 );

PROCEDURE set_pty_process_status
 (
    p_txn_from_date         IN     VARCHAR2,
    p_txn_to_date           IN     VARCHAR2,
    x_return_status         OUT NOCOPY   VARCHAR2,
    x_error_message         OUT NOCOPY   VARCHAR2
 );

PROCEDURE set_ext_process_status
 (
    p_txn_from_date         IN     VARCHAR2,
    p_txn_to_date           IN     VARCHAR2,
    x_return_status         OUT NOCOPY   VARCHAR2,
    x_error_message         OUT NOCOPY   VARCHAR2
 );

 TYPE INST_INTERFACE_REC_TYPE IS RECORD
(     INST_INTERFACE_ID               NUMBER       := FND_API.G_MISS_NUM,
      PROCESS_STATUS                  VARCHAR2(1)  := FND_API.G_MISS_CHAR
);
   TYPE INST_INTERFACE_TBL_TYPE is TABLE OF INST_INTERFACE_REC_TYPE INDEX BY BINARY_INTEGER;

 TYPE PARTY_CONTACT_REC_TYPE IS RECORD
(     IP_INTERFACE_ID                 NUMBER        := FND_API.G_MISS_NUM,
      INST_INTERFACE_ID               NUMBER        := FND_API.G_MISS_NUM,
      CONTACT_PARTY_ID                NUMBER        := FND_API.G_MISS_NUM,
      CONTACT_PARTY_NUMBER            VARCHAR2(30)  := FND_API.G_MISS_CHAR,
      CONTACT_PARTY_NAME              VARCHAR2(250) := FND_API.G_MISS_CHAR,
      CONTACT_PARTY_REL_TYPE          VARCHAR2(30)  := FND_API.G_MISS_CHAR,
      PARENT_TBL_IDX                  NUMBER  := FND_API.G_MISS_NUM,
      CONTACT_PARENT_TBL_INDEX        NUMBER  := FND_API.G_MISS_NUM
);
   TYPE PARTY_CONTACT_TBL_TYPE is TABLE OF PARTY_CONTACT_REC_TYPE INDEX BY BINARY_INTEGER;

-- The following code is added for OI enhacements

TYPE T_DATE  IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE T_NUM   IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE T_V1    IS TABLE OF VARCHAR(01) INDEX BY BINARY_INTEGER;
TYPE T_V30   IS TABLE OF VARCHAR(30) INDEX BY BINARY_INTEGER;
TYPE T_V150  IS TABLE OF VARCHAR(150) INDEX BY BINARY_INTEGER;

TYPE II_RELATIONSHIP_REC_TAB IS RECORD
   (
       REL_INTERFACE_ID                T_NUM,
       RELATIONSHIP_TYPE_CODE          T_V30,
       OBJECT_ID                       T_NUM,
       SUBJECT_ID                      T_NUM,
       CONFIG_ROOT_NODE                T_NUM,
       POSITION_REFERENCE              T_V30,
       ACTIVE_START_DATE               T_DATE,
       ACTIVE_END_DATE                 T_DATE,
       DISPLAY_ORDER                   T_NUM,
       MANDATORY_FLAG                  T_V1,
       CONTEXT                         T_V30,
       ATTRIBUTE1                      T_V150,
       ATTRIBUTE2                      T_V150,
       ATTRIBUTE3                      T_V150,
       ATTRIBUTE4                      T_V150,
       ATTRIBUTE5                      T_V150,
       ATTRIBUTE6                      T_V150,
       ATTRIBUTE7                      T_V150,
       ATTRIBUTE8                      T_V150,
       ATTRIBUTE9                      T_V150,
       ATTRIBUTE10                     T_V150,
       ATTRIBUTE11                     T_V150,
       ATTRIBUTE12                     T_V150,
       ATTRIBUTE13                     T_V150,
       ATTRIBUTE14                     T_V150,
       ATTRIBUTE15                     T_V150,
       OBJECT_VERSION_NUMBER           T_NUM
   );

TYPE ii_rel_interface_rec IS RECORD
(
       REL_INTERFACE_ID                NUMBER,
       RELATIONSHIP_TYPE_CODE          VARCHAR2(30),
       OBJECT_ID                       NUMBER,
       SUBJECT_ID                      NUMBER
);

TYPE  ii_rel_interface_tbl IS TABLE OF ii_rel_interface_rec
                                    INDEX BY BINARY_INTEGER;

PROCEDURE resolve_rel_ids
 (  p_source_system         IN     VARCHAR2,
    p_txn_from_date         IN     varchar2,
    p_txn_to_date           IN     varchar2,
    x_return_status         OUT NOCOPY   VARCHAR2,
    x_error_message         OUT NOCOPY   VARCHAR2);


PROCEDURE Get_Next_Level
 (p_object_id               IN  NUMBER,
  p_rel_tbl                 OUT NOCOPY csi_ml_util_pvt.ii_rel_interface_tbl
 );

PROCEDURE Get_Children
 (p_object_id               IN  NUMBER,
  p_rel_tbl                 OUT NOCOPY csi_ml_util_pvt.ii_rel_interface_tbl
 );

PROCEDURE Get_top_most_parent
     ( p_subject_id      IN  NUMBER,
       p_rel_type_code   IN  VARCHAR2,
       p_process_status  IN  VARCHAR2,
       p_object_id       OUT NOCOPY NUMBER
     );

PROCEDURE Validate_relationship(
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    p_mode                       IN          VARCHAR2,
    p_worker_id                  IN          NUMBER,
    p_txn_from_date              IN          varchar2,
    p_txn_to_date                IN          varchar2,
    p_source_system_name         IN          VARCHAR2
    );

PROCEDURE Eliminate_dup_records;
PROCEDURE Eliminate_dup_subject;
PROCEDURE check_cyclic;
-- End of code addition for OI enhancements


END CSI_ML_UTIL_PVT;

/
