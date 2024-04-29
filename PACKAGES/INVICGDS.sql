--------------------------------------------------------
--  DDL for Package INVICGDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVICGDS" AUTHID CURRENT_USER as
/* $Header: INVICGDS.pls 120.1 2005/06/21 06:31:45 appldev ship $ */

PROCEDURE inv_update_item_desc(
inv_item_id                 IN    NUMBER   DEFAULT  NULL,
org_id                      IN    NUMBER   DEFAULT  NULL,
first_elem_break            IN    NUMBER   DEFAULT 30,
use_name_as_first_elem      IN    VARCHAR2 DEFAULT 'N',
delimiter                   IN    VARCHAR2 DEFAULT NULL,
show_all_delim              IN    VARCHAR2 DEFAULT 'Y'
);


FUNCTION inv_fn_get_icg_desc(
inv_item_id                 IN    NUMBER,
first_elem_break            IN    NUMBER   DEFAULT 30,
use_name_as_first_elem      IN    VARCHAR2 DEFAULT 'N',
delimiter                   IN    VARCHAR2 DEFAULT NULL,
show_all_delim              IN    VARCHAR2 DEFAULT 'Y',
show_error_flag             IN    VARCHAR2 DEFAULT 'Y'
) return VARCHAR2;

PROCEDURE inv_get_icg_desc(
inv_item_id                 IN    NUMBER,
first_elem_break            IN    NUMBER   DEFAULT 30,
use_name_as_first_elem      IN    VARCHAR2 DEFAULT 'N',
delimiter                   IN    VARCHAR2 DEFAULT NULL,
show_all_delim              IN    VARCHAR2 DEFAULT 'Y',
description_for_item       OUT    NOCOPY VARCHAR2,
error_text                IN OUT    NOCOPY VARCHAR2
);

PROCEDURE inv_concat_desc_values(
   inv_item_id                  IN  NUMBER,
   icg_id                       IN  NUMBER,
   delimiter                    IN  VARCHAR2 DEFAULT NULL,
   show_all_delim               IN  VARCHAR2 DEFAULT 'Y',
   concat_desc                  OUT NOCOPY VARCHAR2,
   err_text                     IN OUT NOCOPY VARCHAR2
 );

END INVICGDS;

 

/
