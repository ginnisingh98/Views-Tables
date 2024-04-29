--------------------------------------------------------
--  DDL for Package AMW_COMPONENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_COMPONENTS_PKG" AUTHID CURRENT_USER as
/* $Header: amwvascs.pls 115.4 2004/04/02 01:08:10 npanandi noship $ */
FUNCTION COMPONENTS_PRESENT (
    P_OBJECT_ID IN NUMBER,
    P_OBJECT_TYPE IN VARCHAR2,
    P_COMPONENT_CODE IN VARCHAR2
) RETURN VARCHAR2;

FUNCTION new_COMPONENTS_PRESENT (
    P_OBJECT_ID IN NUMBER,
    P_OBJECT_TYPE IN VARCHAR2,
    P_COMPONENT_CODE IN VARCHAR2
) RETURN VARCHAR2;


PROCEDURE PROCESS_COMPONENTS (
                   p_init_msg_list       IN         VARCHAR2   := FND_API.G_FALSE,
                   p_commit              IN         VARCHAR2   := FND_API.G_FALSE,
                   p_validate_only       IN         VARCHAR2   := FND_API.G_FALSE,
                   p_select_flag         IN         VARCHAR2,
                   -- p_assessment_id       IN            NUMBER, -- 11.25.2003 tsho: obseleted, use object_id, object_type instead
                   p_object_id           IN         NUMBER,       -- 11.25.2003 tsho: combined with object_type will replace assessment_id
                   p_object_type         IN         VARCHAR2,     -- 11.25.2003 tsho: combined with obejct_id will replace assessment_id
                   p_component_code      IN         VARCHAR2,
                   x_return_status       OUT NOCOPY VARCHAR2,
                   x_msg_count           OUT NOCOPY NUMBER,
                   x_msg_data            OUT NOCOPY VARCHAR2,
                   p_other_component_value IN       VARCHAR2   := NULL
                   );
END  AMW_COMPONENTS_PKG;

 

/
