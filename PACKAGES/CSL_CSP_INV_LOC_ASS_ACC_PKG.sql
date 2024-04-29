--------------------------------------------------------
--  DDL for Package CSL_CSP_INV_LOC_ASS_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_CSP_INV_LOC_ASS_ACC_PKG" AUTHID CURRENT_USER AS
/* $Header: cslilacs.pls 115.6 2002/11/08 14:02:41 asiegers ship $ */

/***
  Function that checks if Inventory Location Assignment record should be replicated.
  Returns TRUE if it should
***/
FUNCTION Replicate_Record
  ( p_csp_inv_loc_assignment_id NUMBER
  )
RETURN BOOLEAN;

/***
  Public function that gets called when a Inventory Location Assignment needs to be inserted into ACC table.
  Returns TRUE when record already was or has been inserted into ACC table.
***/
FUNCTION Pre_Insert_Child
  ( p_csp_inv_loc_assignment_id     IN NUMBER
   ,p_resource_id                   IN NUMBER
  )
RETURN BOOLEAN;

/***
  Public procedure that gets called when a Inventory Location Assignment needs to be deleted from ACC table.
***/
PROCEDURE Post_Delete_Child
  ( p_csp_inv_loc_assignment_id   IN NUMBER
   ,p_resource_id                 IN NUMBER
  );

/* Called before assignment Insert */
PROCEDURE PRE_INSERT_INV_LOC_ASSIGNMENT   ( x_return_status OUT NOCOPY VARCHAR2);

/* Called after assignment Insert */
PROCEDURE POST_INSERT_INV_LOC_ASSIGNMENT  ( x_return_status OUT NOCOPY VARCHAR2);

/* Called before assignment Update */
PROCEDURE PRE_UPDATE_INV_LOC_ASSIGNMENT   ( x_return_status OUT NOCOPY VARCHAR2);

/* Called after assignment Update */
PROCEDURE POST_UPDATE_INV_LOC_ASSIGNMENT  ( x_return_status OUT NOCOPY VARCHAR2);

/* Called before assignment Delete */
PROCEDURE PRE_DELETE_INV_LOC_ASSIGNMENT   ( x_return_status OUT NOCOPY VARCHAR2);

/* Called after assignment Delete */
PROCEDURE POST_DELETE_INV_LOC_ASSIGNMENT  ( x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE Delete_All_ACC_Records(
                                      p_resource_id     IN  NUMBER,
                                      x_return_status   OUT NOCOPY VARCHAR2
                                );

PROCEDURE Insert_All_ACC_Records(
                                      p_resource_id     IN  NUMBER,
                                      x_return_status   OUT NOCOPY VARCHAR2
                                );

END CSL_CSP_INV_LOC_ASS_ACC_PKG;

 

/
