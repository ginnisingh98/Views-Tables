--------------------------------------------------------
--  DDL for Package HZ_WORD_RPL_COND_ATTRIBS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_WORD_RPL_COND_ATTRIBS_PKG" AUTHID CURRENT_USER as
/*$Header: ARHWRCAS.pls 120.2 2005/10/30 04:23:14 appldev noship $ */

PROCEDURE Insert_Row (
    x_condition_id                          IN  NUMBER,
    x_assoc_cond_attrib_id                  IN  NUMBER,
    x_object_version_number                 IN  NUMBER
);


PROCEDURE Update_Row (
    x_condition_id                          IN  NUMBER,
    x_assoc_cond_attrib_id                  IN NUMBER,
    x_new_cond_attrib_id                    IN NUMBER,
    x_object_version_number                 IN  OUT NOCOPY NUMBER
);

PROCEDURE Delete_Row (
    x_condition_id                          IN  NUMBER,
    x_assoc_cond_attrib_id                  IN NUMBER
);

PROCEDURE Delete_Row (
    x_condition_id                          IN  NUMBER
);

procedure Lock_Row (
  x_condition_id in NUMBER,
  x_assoc_cond_attrib_id in NUMBER,
  x_object_version_number in  NUMBER
);


END HZ_WORD_RPL_COND_ATTRIBS_PKG ;

 

/
