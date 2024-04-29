--------------------------------------------------------
--  DDL for Package HZ_WORD_RPL_CONDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_WORD_RPL_CONDS_PKG" AUTHID CURRENT_USER as
/*$Header: ARHWRCDS.pls 120.4 2005/10/30 04:23:16 appldev noship $ */

PROCEDURE Insert_Row (
    x_condition_id                          IN  OUT NOCOPY NUMBER,
    x_entity                                IN VARCHAR2,
    x_condition_function                    IN VARCHAR2,
    x_condition_val_fmt_flag                IN VARCHAR2,
    x_condition_name                        IN VARCHAR2,
    x_condition_description                 IN VARCHAR2,
    x_object_version_number                 IN  NUMBER
);

procedure Update_Row (
    x_condition_id                          IN NUMBER,
    x_entity                                IN VARCHAR2,
    x_condition_function                    IN VARCHAR2,
    x_condition_val_fmt_flag                IN VARCHAR2,
    x_condition_name                        IN VARCHAR2,
    x_condition_description                 IN VARCHAR2,
    x_object_version_number                 IN  OUT NOCOPY NUMBER
);

procedure Delete_Row (
  x_condition_id in NUMBER
);

procedure Lock_Row (
  x_condition_id in NUMBER,
  x_object_version_number in  NUMBER
);

procedure Add_Language ;

procedure Load_Row (
    x_condition_id                          IN  OUT NOCOPY NUMBER,
    x_entity                                IN VARCHAR2,
    x_condition_function                    IN VARCHAR2,
    x_condition_val_fmt_flag                IN VARCHAR2,
    x_condition_name                        IN VARCHAR2,
    x_condition_description                 IN VARCHAR2,
    x_object_version_number                 IN  NUMBER,
    x_last_update_date                      IN DATE,
    x_last_updated_by                       IN NUMBER,
    x_last_update_login                     IN NUMBER,
    x_owner                                 IN VARCHAR2,
    x_custom_mode                           IN VARCHAR2
    );

 procedure Translate_Row (
  x_condition_id in NUMBER,
  x_condition_name in VARCHAR2,
  x_condition_description in VARCHAR2,
  x_owner in VARCHAR2);



END HZ_WORD_RPL_CONDS_PKG ;

 

/
