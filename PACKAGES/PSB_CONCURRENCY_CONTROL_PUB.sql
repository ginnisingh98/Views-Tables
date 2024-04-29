--------------------------------------------------------
--  DDL for Package PSB_CONCURRENCY_CONTROL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_CONCURRENCY_CONTROL_PUB" AUTHID CURRENT_USER AS
/* $Header: PSBPCCLS.pls 120.2 2005/07/13 11:22:41 shtripat ship $ */

/* ----------------------------------------------------------------------- */

  --    API name        : Enforce_Concurrency_Control
  --    Type            : Public <Interface>
  --    Pre-reqs        : FND_API, FND_MESSAGE, PSB_CONCURRENCY_CONTROL_PVT
  --    Parameters      :
  --    IN              : p_api_version             IN   NUMBER    Required
  --                      p_validation_level        IN   NUMBER    Optional
  --                             Default = FND_API.G_VALID_LEVEL_NONE
  --                      p_concurrency_class       IN   VARCHAR2  Optional
  --                             Default = 'MAINTENANCE'
  --                      p_concurrency_entity_name IN   VARCHAR2  Required
  --                      p_concurrency_entity_id   IN   NUMBER    Required
  --                    .
  --    OUT  NOCOPY      : p_return_status           OUT  NOCOPY  VARCHAR2(1)
  --                    p_msg_count                 OUT  NOCOPY  NUMBER
  --                    p_msg_data                  OUT  NOCOPY  VARCHAR2(2000)
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 06/15/1997 by Supriyo Ghosh
  --                            Modified 07/07/1997 by Supriyo Ghosh
  --
  --    Notes           : Enforce Concurrency Control
  --
  --    Concurrency Control, for Mutual Exclusion, needs to be enforced from
  --    the following Modules :
  --
  --    Worksheet Creation, Worksheet Modification, Define Parameter Set,
  --    Define Constraint Set, Define Allocation Rule, Define Budget Group,
  --    Define Budget Calendar, Define Data Extract, Elements, View Elements,
  --    Position Assignments and Position Pay Distributions. Concurrency Control
  --    must be enforced from these Modules during changes (Inserts, Updates and Deletes).
  --    Check the Return Status from the Procedure Call;
  --    if p_return_status = FND_API.G_RET_STS_SUCCESS, allow modifications to the Modules;
  --    otherwise raise an Exception and disallow modifications.
  --
  --    Parameter Values :
  --
  --    p_concurrency_class has values of 'WORKSHEET_CREATION' for Worksheet
  --    Creation, 'DATAEXTRACT_CREATION' for Data Extract Creation and 'MAINTENANCE'
  --    for the other Modules; this is defined by the Lookup Type 'PSB_CONCURRENCY_CLASS'.
  --
  --    p_concurrency_entity_name has values of 'WORKSHEET' for the Worksheet
  --    Modules, 'PARAMETER_SET' for Define Parameter Set, 'CONSTRAINT_SET' for
  --    Define Constraint Set, 'ALLOCRULE_SET' for Define Allocation Rule,
  --    'BUDGET_GROUP' for Define Budget Group, 'BUDGET_CALENDAR' for Define
  --    Budget Calendar Modules, 'DATA_EXTRACT' for Define Data Extract, Elements,
  --    View Elements, Position Assignments and Position Pay Distributions;
  --    this is defined by the Lookup Type 'PSB_CONCURRENCY_ENTITY_NAME'.
  --
  --    p_concurrency_entity_id has the corresponding IDs for each of the Modules:
  --    Worksheet ID for the Worksheet Modules, Parameter Set ID for Define Parameter
  --    Set, Constraint Set ID for Define Constraint Set, AllocRule Set ID for Define
  --    Allocation Rule, Budget Group ID for Define Budget Group, Budget Calendar ID
  --    for Define Budget Calendar, Data Extract ID for Define Data Extract, Elements,
  --    View Elements, Position Assignments and Position Pay Distributions.
  --
  --    Return Status :
  --
  --    p_return_status is set to FND_API.G_RET_STS_SUCCESS if Concurrency Control is
  --    successfully enforced. p_msg_count containts the Message Count and p_msg_data
  --    contains the Message Data if there's exactly 1 Message on the Stack.
  --
  --
  --    HISTORY
  --
  --      21-SEP-1998   Elvirtuc    moved call to concurrent manager here
  --                                Update balances and Create rollup
  --                                Release 11 work
  --
  --      16-NOV-1998   Elvirtuc    Moved _CP to PSBWCAB
  --      20-NOV-1998   Shjain      Added Release_Concurrency_Control Procedure



PROCEDURE Enforce_Concurrency_Control
( p_api_version              IN   NUMBER,
  p_init_msg_list            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level         IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status            OUT  NOCOPY  VARCHAR2,
  p_msg_count                OUT  NOCOPY  NUMBER,
  p_msg_data                 OUT  NOCOPY  VARCHAR2,
  p_concurrency_class        IN   VARCHAR2 := 'MAINTENANCE',
  p_concurrency_entity_name  IN   VARCHAR2,
  p_concurrency_entity_id    IN   NUMBER
);

PROCEDURE Release_Concurrency_Control
( p_api_version              IN   NUMBER,
  p_init_msg_list            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level         IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status            OUT  NOCOPY  VARCHAR2,
  p_msg_count                OUT  NOCOPY  NUMBER,
  p_msg_data                 OUT  NOCOPY  VARCHAR2,
  p_concurrency_class        IN   VARCHAR2 := 'MAINTENANCE',
  p_concurrency_entity_name  IN   VARCHAR2,
  p_concurrency_entity_id    IN   NUMBER
);

/* ----------------------------------------------------------------------- */


END PSB_CONCURRENCY_CONTROL_PUB;

 

/
