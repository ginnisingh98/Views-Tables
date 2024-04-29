--------------------------------------------------------
--  DDL for Package BOM_RTG_APPLET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_RTG_APPLET_PKG" AUTHID CURRENT_USER AS
/* $Header: BOMJONWS.pls 120.1 2006/03/02 01:35:12 vhymavat noship $ */

  PROCEDURE Associate_Event(
              x_event_op_seq_id		NUMBER,
	      x_operation_type		NUMBER, -- proc(2)/lnop(3)
              x_new_parent_op_seq_id	NUMBER, -- new proc/lnop
              x_last_updated_by		NUMBER,
              x_last_update_date	DATE,
	      x_return_code      OUT NOCOPY    VARCHAR, -- S/F
              x_error_msg        OUT NOCOPY   VARCHAR
         );

  PROCEDURE Alter_Link(
              x_from_op_seq_id		NUMBER,
              x_to_op_seq_id		NUMBER,
              x_transition_type		NUMBER,
              x_planning_pct		NUMBER,
	      x_transaction_type	VARCHAR2, -- insert/update/delete
         --   x_effectivity_date	DATE,
         --   x_disable_date		DATE,
              x_last_updated_by		NUMBER,
              x_creation_date      	DATE,
              x_last_update_date   	DATE,
              x_created_by         	NUMBER,
              x_last_update_login  	NUMBER,
              x_attribute_category 	VARCHAR2,
              x_attribute1         	VARCHAR2,
              x_attribute2         	VARCHAR2,
              x_attribute3         	VARCHAR2,
              x_attribute4         	VARCHAR2,
              x_attribute5         	VARCHAR2,
              x_attribute6         	VARCHAR2,
              x_attribute7         	VARCHAR2,
              x_attribute8         	VARCHAR2,
              x_attribute9         	VARCHAR2,
              x_attribute10         	VARCHAR2,
              x_attribute11         	VARCHAR2,
              x_attribute12         	VARCHAR2,
              x_attribute13         	VARCHAR2,
              x_attribute14         	VARCHAR2,
              x_attribute15         	VARCHAR2,
	      x_return_code   	OUT NOCOPY	VARCHAR2, -- S/F
	      x_error_msg	OUT NOCOPY	VARCHAR2
         );

  PROCEDURE Validate_Link(
              x_from_op_seq_id 	  IN	NUMBER,
              x_to_op_seq_id	  IN	NUMBER,
              x_transition_type	  IN	NUMBER,
              x_planning_pct	  IN	NUMBER,
	      x_transaction_type  IN	VARCHAR2,
	      x_return_code	  OUT NOCOPY	VARCHAR2, -- S/F
	      x_error_msg	  OUT NOCOPY	VARCHAR2
         );

  PROCEDURE Move_Node(
	      x_operation_sequence_id	NUMBER,
              x_x_coordinate		NUMBER,
              x_y_coordinate		NUMBER,
              x_last_updated_by		NUMBER,
              x_last_update_date	DATE,
	      x_return_code       OUT NOCOPY   VARCHAR2, -- S/F
              x_error_msg         OUT NOCOPY  VARCHAR2
         );

END BOM_RTG_APPLET_PKG;

 

/
