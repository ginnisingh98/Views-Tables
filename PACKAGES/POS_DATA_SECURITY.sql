--------------------------------------------------------
--  DDL for Package POS_DATA_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_DATA_SECURITY" AUTHID CURRENT_USER AS
/* $Header: POSSECPS.pls 120.0.12010000.2 2013/12/14 00:10:17 dalu noship $ */

  PROCEDURE get_privileges_prosp
  (
   p_supp_reg_id           IN  NUMBER,
   p_user_id               IN  NUMBER,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_privileges_string     OUT NOCOPY VARCHAR2
   );

  ----------------------------------------------------------------
  -- PROCEDURE get_privileges_supp:
  -- Added for Bug 17336075
  -- This procedure is called under Supplier user's view
  -- to get privileges assigned with 'Company' type grant under supplier's profile access control
  -- Parameters
  -- IN:
  -- p_party_id: Current supplier's party id
  -- p_user_id: Current supplier user's user id
  -- OUT:
  -- x_return_status: Return status. Success = FND_API.G_RET_STS_SUCCESS; Fail = FND_API.G_RET_STS_UNEXP_ERROR
  ----------------------------------------------------------------
  PROCEDURE get_privileges_supp
  (
   p_party_id              IN  NUMBER,
   p_user_id               IN  NUMBER,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_privileges_string     OUT NOCOPY VARCHAR2
   );

END POS_DATA_SECURITY;

/
