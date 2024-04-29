--------------------------------------------------------
--  DDL for Package M4R_7B5_OSFM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."M4R_7B5_OSFM_PKG" AUTHID CURRENT_USER AS
/* $Header: M4R7B5OS.pls 120.0 2005/05/24 16:22:44 appldev noship $ */


--  Package
--      M4R_7B5_OSFM_PKG
--
--  Purpose
--      Spec of package M4R_7B5_OSFM_PKG. This package
--      is called from the Workflow 'M4R 7B5 OSFM Notify WO'.
--
--  History
--      Feb-26-2005     Sangeetha         Created
--      May-02-2005     Sangeetha         Added 'COMPARE_HEADERS' procedure.

-- Name
--    SET_WF_ATTRIBUTES

-- Purpose
--    This procedure is called from the Workflow. It checks whether the approved PO has any Outside Processing Items.

-- Arguments


PROCEDURE SET_WF_ATTRIBUTES(p_itemtype               IN              VARCHAR2,
                            p_itemkey                IN              VARCHAR2,
                            p_actid                  IN              NUMBER,
                            p_funcmode               IN              VARCHAR2,
                            x_resultout              IN OUT NOCOPY   VARCHAR2);


-- Name
--    PROCESS_WO

-- Purpose
--    This procedure is called from the Workflow to process the Purchase Order to find whether it is a New/Change/Cancel request

-- Arguments

PROCEDURE PROCESS_WO(p_itemtype               IN              VARCHAR2,
                     p_itemkey                IN              VARCHAR2,
                     p_actid                  IN              NUMBER,
                     p_funcmode               IN              VARCHAR2,
                     x_resultout              IN OUT NOCOPY   VARCHAR2);

-- Name
--    COMPARE_HEADERS

-- Purpose
--    This procedure is called from the PROCESS_WO procedure. It compares the headers of the Standard PO/Release to the previous
--    respective ones.

-- Arguments

PROCEDURE COMPARE_HEADERS(p_header_id           IN          NUMBER,
	                  p_release_id          IN          NUMBER,
	                  p_revision_num        IN          NUMBER,
	                  x_header_change_flag  OUT NOCOPY VARCHAR2);

END M4R_7B5_OSFM_PKG;

 

/
