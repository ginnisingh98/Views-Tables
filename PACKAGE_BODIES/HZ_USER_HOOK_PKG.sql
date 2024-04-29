--------------------------------------------------------
--  DDL for Package Body HZ_USER_HOOK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_USER_HOOK_PKG" AS
/*$Header: ARHPMUKB.pls 120.0 2004/12/10 18:34:55 awu noship $ */



--------------------------------------
-- declaration of public procedures and functions
--------------------------------------

procedure default_master_user_hook(
  p_dup_set_id            IN NUMBER,
  x_master_party_id        OUT NOCOPY NUMBER,
  x_master_party_name        OUT NOCOPY VARCHAR2,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2 ) is

begin

  /* put your custom logic here for default master party id and name */
  null;

end;



END HZ_USER_HOOK_PKG;

/
