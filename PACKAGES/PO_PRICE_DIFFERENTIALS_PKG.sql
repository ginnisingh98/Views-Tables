--------------------------------------------------------
--  DDL for Package PO_PRICE_DIFFERENTIALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_PRICE_DIFFERENTIALS_PKG" AUTHID CURRENT_USER AS
/* $Header: POXVPDTS.pls 120.1 2005/08/31 07:13:01 arudas noship $*/
g_pkg_name CONSTANT VARCHAR2(30) := 'PO_PRICE_DIFFERENTIALS_PKG';
PROCEDURE insert_row
(   p_price_differential_rec      IN           PO_PRICE_DIFFERENTIALS%ROWTYPE
,   x_row_id                      OUT NOCOPY   ROWID
);

PROCEDURE update_row
(   p_price_differential_rec      IN           PO_PRICE_DIFFERENTIALS%ROWTYPE
,   p_row_id                      IN           ROWID
);

PROCEDURE lock_row
(   p_form_rec                    IN           PO_PRICE_DIFFERENTIALS%ROWTYPE
,   p_row_id                      IN           ROWID
);

PROCEDURE delete_row
(   p_row_id                      IN           ROWID
);

--<HTML Agreements R12 Start>
PROCEDURE del_level_specific_price_diff( p_doc_level    IN VARCHAR2
                                        ,p_doc_level_id IN NUMBER);
--<HTML Agreements R12 End>
END PO_PRICE_DIFFERENTIALS_PKG;

 

/
