--------------------------------------------------------
--  DDL for Package EGO_ORCHESTRATION_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_ORCHESTRATION_UTIL_PUB" AUTHID CURRENT_USER as
/* $Header: EGOORCHS.pls 120.1.12010000.2 2009/10/29 10:38:44 yjain ship $ */

C_OBSOLETE_STATUS  	    NUMBER := -1;
C_TRANSACTION_SYNC      VARCHAR2(10) := 'SYNC';
C_INIT_PROCESS_FLAG     NUMBER := 0;
G_RET_STS_SUCCESS   CONSTANT    VARCHAR2(1)  :=  FND_API.g_RET_STS_SUCCESS;     --'S'
G_RET_STS_ERROR     CONSTANT    VARCHAR2(1)  :=  FND_API.g_RET_STS_ERROR;       --'E'
G_RET_STS_UNEXP_ERROR   CONSTANT    VARCHAR2(1)  :=  FND_API.g_RET_STS_UNEXP_ERROR; --'U'



FUNCTION PRE_PRE_PROCESS_BATCHES ( X_BUNDLE_COLLECTION_ID IN NUMBER,
                                   X_COMMIT               IN VARCHAR2
                                 )
                                 RETURN NUMBER;

PROCEDURE GET_SUPPLIER_INFO ( X_EXT_SUP_ID            IN VARCHAR2,
                              X_EXT_SUP_TYPE          IN VARCHAR2,
                              X_SUP_LEVEL             IN VARCHAR2,
                              X_SUPPLIER_ID           OUT NOCOPY NUMBER,
                              X_SUPPLIER_NAME         OUT NOCOPY VARCHAR2
                            );


PROCEDURE ADD_BUNDLES_TO_COL (x_bundle_collection_id   IN NUMBER,
                              p_bundles_clob           IN CLOB,
                              x_new_bundle_col_id      OUT NOCOPY NUMBER,
                              p_commit                 IN VARCHAR2 := 'Y',
                              p_entity_name            IN VARCHAR2 := 'BUNDLE'
                              );


FUNCTION GET_BUNDLES_FROM_COL ( p_bundle_collection_id   IN NUMBER,
                                 p_prior_bundle_id        IN NUMBER,
                                 p_max_elements           IN NUMBER
                              )
                               RETURN XMLTYPE;

PROCEDURE SAVE_DATA ( p_xml_clob           IN  CLOB,
                      p_commit             IN  VARCHAR2,
                      p_source_sys_id      IN  NUMBER,
                      p_default_batch      IN  VARCHAR2,
                      x_new_bundle_col_id  OUT NOCOPY NUMBER,
                      x_err_bundle_col_id  OUT NOCOPY NUMBER);

PROCEDURE PROCESS_TL_ROWS(p_table_name     IN VARCHAR2,
                p_batch_id       IN NUMBER,
                p_unique_id      IN NUMBER,
                p_bundle_id      IN NUMBER,
                p_xml_data       IN XMLTYPE,
                p_entity_name    IN VARCHAR2,
                p_column_name    IN VARCHAR2
                );


PROCEDURE Set_ICC_For_Rec_Bundle
(  p_rb_id              IN          NUMBER ,
   x_Status               OUT NOCOPY  VARCHAR2,
   x_Gpc_list             OUT NOCOPY  VARCHAR2
);

PROCEDURE Set_ACC_For_Rec_Bundle
(  p_rb_id              IN          NUMBER ,
   x_Status               OUT NOCOPY  VARCHAR2,
   x_Gpc_list             OUT NOCOPY  VARCHAR2
);


PROCEDURE Set_ICC_For_Rec_Collection
(  p_rc_id              IN          NUMBER ,
   x_BundleWithICC               OUT NOCOPY  NUMBER,
   x_BundleWithoutICC             OUT NOCOPY  NUMBER
);

PROCEDURE Set_ACC_For_Rec_Collection
(  p_rc_id              IN          NUMBER ,
   x_BundleWithACC               OUT NOCOPY  NUMBER,
   x_BundleWithoutACC             OUT NOCOPY  NUMBER
);

PROCEDURE validate_batch
(   p_batch_name IN VARCHAR2 ,
    p_default_batch_name IN VARCHAR2 ,
    x_batch_id OUT NOCOPY  NUMBER,
    x_error_msg OUT NOCOPY  VARCHAR2
);

PROCEDURE Import_Conc_Prg
( 	p_batch_id   IN   NUMBER
);



END EGO_ORCHESTRATION_UTIL_PUB;



/
