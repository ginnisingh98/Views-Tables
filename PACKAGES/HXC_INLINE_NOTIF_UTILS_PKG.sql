--------------------------------------------------------
--  DDL for Package HXC_INLINE_NOTIF_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_INLINE_NOTIF_UTILS_PKG" AUTHID CURRENT_USER as
/* $Header: hxcinnotiutl.pkh 120.2 2005/12/02 13:14:23 arundell noship $ */

  PROCEDURE fetch_day_details
     (p_app_bb_id        IN            NUMBER,
      p_tk_audit	 IN            VARCHAR2,
      p_day_detail_array IN OUT NOCOPY HXC_DAY_DETAIL_TABLE_TYPE,
      p_message_string      OUT NOCOPY VARCHAR2
      );

  PROCEDURE tokenizer ( iStart IN NUMBER,
      sPattern IN VARCHAR2,
      sBuffer IN VARCHAR2,
      sResult OUT NOCOPY VARCHAR2,
      iNextPos OUT NOCOPY NUMBER);

  PROCEDURE get_alias_values_from_db
      (p_bb_id IN NUMBER,
       p_bb_ovn IN NUMBER,
       p_layout_comp_id IN NUMBER,
       p_alias_value_list OUT NOCOPY VARCHAR2
      );

end hxc_inline_notif_utils_pkg;

 

/
