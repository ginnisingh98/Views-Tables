--------------------------------------------------------
--  DDL for Package Body CN_POSTING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_POSTING_PVT" AS
-- $Header: cnvpdetb.pls 120.2 2006/02/13 15:57:38 fmburu noship $
G_PKG_NAME      CONSTANT VARCHAR2(30) := 'CN_POSTING_PVT';

PROCEDURE post_worker
  (p_parent_proc_audit_id      number,
   p_posting_batch_id          number,
   p_physical_batch_id         number,
   p_start_date                date,
   p_end_date                  date)
IS
BEGIN
    -- NULLED OUT NOT USED
    NULL;
END post_worker;


PROCEDURE posting_details
  (p_api_version           IN    NUMBER,
   p_init_msg_list         IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit                IN    VARCHAR2 := FND_API.G_FALSE,
   x_return_status         OUT NOCOPY   VARCHAR2,
   x_msg_count             OUT NOCOPY   NUMBER,
   x_msg_data            OUT NOCOPY   VARCHAR2,
   p_start_date            IN    DATE,
   p_end_date              IN    DATE,
   p_parent_proc_audit_id  IN    NUMBER)
IS
BEGIN
   -- NO LONGER USED
   fnd_message.set_name ('CN', 'CN_CALLING_OBSELETE_PROCEDURE');
   fnd_msg_pub.ADD;
   RAISE fnd_api.G_EXC_UNEXPECTED_ERROR ;
END posting_details;

PROCEDURE posting_conc
(  errbuf               OUT NOCOPY   VARCHAR2,
   retcode              OUT NOCOPY   NUMBER,
   start_date           IN    VARCHAR2,
   end_date             IN    VARCHAR2
)
IS
BEGIN
    -- NULLED OUT NOT USED
    NULL ;
END posting_conc;


END cn_posting_pvt;

/
