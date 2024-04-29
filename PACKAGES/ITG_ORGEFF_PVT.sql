--------------------------------------------------------
--  DDL for Package ITG_ORGEFF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ITG_ORGEFF_PVT" AUTHID CURRENT_USER AS
/* ARCS: $Header: itgeffs.pls 115.2 2002/12/24 00:27:00 ecoe noship $
 * CVS:  itgeffs.pls,v 1.8 2002/12/23 21:20:30 ecoe Exp
 */

  /* Check the effectivity.  This is not a BO API, it's just useful. */
  FUNCTION Check_Effective(
    p_organization_id  IN  NUMBER,
    p_cln_doc_type     IN  VARCHAR2,
    p_doc_direction    IN  VARCHAR2	/* 'P'ublish or 'S'ubscribe */
  ) RETURN BOOLEAN;

  /* This is a BO API.   */
  PROCEDURE Update_Effectivity(
    p_api_version      IN         NUMBER,
    p_init_msg_list    IN         VARCHAR2 := FND_API.G_FALSE,
    p_commit           IN         VARCHAR2 := FND_API.G_FALSE,
    p_validation_level IN         NUMBER   := FND_API.G_VALID_LEVEL_FULL,

    x_return_status    OUT NOCOPY VARCHAR2,           /* VARCHAR2(1) */
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2,           /* VARCHAR2(2000) */

    p_organization_id  IN         NUMBER,
    p_cln_doc_type     IN         VARCHAR2,
    p_doc_direction    IN         VARCHAR2,
    p_start_date       IN         DATE      := NULL,
    p_end_date         IN         DATE      := NULL,
    p_effective        IN         VARCHAR2  := NULL
  );

END;

 

/
