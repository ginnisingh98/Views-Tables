--------------------------------------------------------
--  DDL for Package PO_VALIDATE_NIFVAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_VALIDATE_NIFVAT" AUTHID CURRENT_USER AS
/* $Header: povlnifs.pls 115.4 2002/12/11 09:42:34 amtripat ship $ */

     FUNCTION po_check_numeric(check_value VARCHAR2,
                               pos_from    NUMBER,
                               pos_for     NUMBER  )  RETURN VARCHAR2;

     PROCEDURE po_coordinate_validation(X_RESP_APPL_ID       NUMBER,
                                        X_VALIDATION_TYPE    VARCHAR2,
                                        X_TABLE_NAME         VARCHAR2,
                                        X_RECORD_ID          NUMBER,
                                        X_FIELD_VALUE        VARCHAR2,
                                        X_PROFILE_CTY        VARCHAR2,
                                        X_COUNTRY_NAME       VARCHAR2,
                                        X_HOME_COUNTRY       VARCHAR2,
                                        X_RESULT_FLAG OUT NOCOPY    VARCHAR2,
                                        X_RESULT_MESSAGE OUT NOCOPY VARCHAR2);


     PROCEDURE po_validate_vat_be(Xi_NIF               VARCHAR2,
                                  Xi_CHECK_UNIQUE_FLAG VARCHAR2,
                                      Xo_RET_VAR OUT NOCOPY varchar2,
                                      Xo_RET_MESSAGE OUT NOCOPY varchar2);

     PROCEDURE po_validate_vat_at(Xi_NIF               VARCHAR2,
                                  Xi_CHECK_UNIQUE_FLAG VARCHAR2,
                                      Xo_RET_VAR OUT NOCOPY varchar2,
                                      Xo_RET_MESSAGE OUT NOCOPY varchar2);

     PROCEDURE po_validate_vat_nl(Xi_NIF               VARCHAR2,
                                  Xi_CHECK_UNIQUE_FLAG VARCHAR2,
                                      Xo_RET_VAR OUT NOCOPY varchar2,
                                      Xo_RET_MESSAGE OUT NOCOPY varchar2);

     PROCEDURE po_validate_nif_es(Xi_NIF               VARCHAR2,
                                  Xi_VAL_TYPE          VARCHAR2,
                                  Xi_CHECK_UNIQUE_FLAG VARCHAR2,
                                      Xo_RET_VAR OUT NOCOPY varchar2,
                                      Xo_RET_MESSAGE OUT NOCOPY varchar2);

     PROCEDURE po_validate_vat_it(VAT_VALUE               VARCHAR2,
                                  Xi_UNIQUE_FLAG       VARCHAR2,
                                      RET_VAR      OUT NOCOPY varchar2,
                                      RET_MESSAGE  OUT NOCOPY varchar2);

     PROCEDURE po_validate_nif_it(NIF                  VARCHAR2,
                                  Xi_UNIQUE_FLAG       VARCHAR2,
                                      RET_VAR OUT NOCOPY varchar2,
                                      RET_MESSAGE OUT NOCOPY varchar2);

     PROCEDURE po_validate_nif_pt(Xi_NIF                  VARCHAR2,
                                  Xi_UNIQUE_FLAG       VARCHAR2,
                                      RET_VAR OUT NOCOPY varchar2,
                                      RET_MESSAGE OUT NOCOPY varchar2);

    -- Bug 2637182 Forward porting the changes in 11.0
    --
     PROCEDURE po_validate_vat_gr(Xi_NIF  in  VARCHAR2,
                             Xi_CHECK_UNIQUE_FLAG in VARCHAR2,
                             Xo_RET_VAR OUT NOCOPY varchar2,
                             Xo_RET_MESSAGE OUT NOCOPY varchar2);


     FUNCTION  po_validate_vat_eu(Xi_VAT_VALUE  in  VARCHAR2) RETURN BOOLEAN;

     PROCEDURE po_validate_vat_de(Xi_VAT_VALUE    IN  VARCHAR2,
                                  Xo_RET_VAR      OUT NOCOPY VARCHAR2,
                                  Xo_RET_MESSAGE  OUT NOCOPY VARCHAR2);

     PROCEDURE po_validate_vat_dk(Xi_VAT_VALUE    IN  VARCHAR2,
                                  Xo_RET_VAR      OUT NOCOPY VARCHAR2,
                                  Xo_RET_MESSAGE  OUT NOCOPY VARCHAR2);

     PROCEDURE po_validate_vat_fi(Xi_VAT_VALUE    IN  VARCHAR2,
                                  Xo_RET_VAR      OUT NOCOPY VARCHAR2,
                                  Xo_RET_MESSAGE  OUT NOCOPY VARCHAR2);

     PROCEDURE po_validate_vat_fr(Xi_VAT_VALUE    IN  VARCHAR2,
                                  Xo_RET_VAR      OUT NOCOPY VARCHAR2,
                                  Xo_RET_MESSAGE  OUT NOCOPY VARCHAR2);
     PROCEDURE po_validate_vat_gb(Xi_VAT_VALUE    IN  VARCHAR2,
                                  Xo_RET_VAR      OUT NOCOPY VARCHAR2,
                                  Xo_RET_MESSAGE  OUT NOCOPY VARCHAR2);

     PROCEDURE po_validate_vat_ie(Xi_VAT_VALUE    IN  VARCHAR2,
                                  Xo_RET_VAR      OUT NOCOPY VARCHAR2,
                                  Xo_RET_MESSAGE  OUT NOCOPY VARCHAR2);

     PROCEDURE po_validate_vat_lu(Xi_VAT_VALUE    IN  VARCHAR2,
                                  Xo_RET_VAR      OUT NOCOPY VARCHAR2,
                                  Xo_RET_MESSAGE  OUT NOCOPY VARCHAR2);

     PROCEDURE po_validate_vat_pt(Xi_VAT_VALUE    IN  VARCHAR2,
                                  Xo_RET_VAR      OUT NOCOPY VARCHAR2,
                                  Xo_RET_MESSAGE  OUT NOCOPY VARCHAR2);

     PROCEDURE po_validate_vat_se(Xi_VAT_VALUE    IN  VARCHAR2,
                                  Xo_RET_VAR      OUT NOCOPY VARCHAR2,
                                  Xo_RET_MESSAGE  OUT NOCOPY VARCHAR2);

END PO_VALIDATE_NIFVAT;

 

/
