--------------------------------------------------------
--  DDL for Package Body IGI_VENDOR_MERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_VENDOR_MERGE_GRP" AS
   -- $Header: igismrgb.pls 120.8 2007/06/22 10:23:35 smannava ship $
   --
   -- Global Variables
      g_org_id   NUMBER := to_number(fnd_profile.value('ORG_ID'));
      g_pkg_name CONSTANT VARCHAR2(30) := 'IGI_VENDOR_MERGE_GRP';
   --
   -- PRIVATE ROUTINES
   --
   --
   -- *************************************************************************
   -- Procedure : Update_EXP_Tables
   -- Bug 3282938, EXP table IGI_EXP_DUS should be updated for
   -- Supplier merge.
   -- *************************************************************************
   PROCEDURE update_EXP_tables (p_paid_invoices_flag   IN          VARCHAR2,
                                p_old_vendor_id        IN          NUMBER,
                                p_old_vendor_site_id   IN          NUMBER,
                                p_new_vendor_id        IN          NUMBER,
                                p_new_vendor_site_id   IN          NUMBER,
                                x_return_status        OUT NOCOPY VARCHAR2 ,
                                x_msg_count            OUT NOCOPY NUMBER ,
                                x_msg_data             OUT NOCOPY VARCHAR2);

   --
   -- PUBLIC ROUTINES
   --
   --
   -- *************************************************************************
   -- Procedure : Merge_Vendor
   -- Off all the IGI tables containing VENDOR_ID, only the CIS table
   -- needs updating. If new tables are added which store vendor_id,
   -- this procedure should be updated to modify the new tables too.
   -- The AP supplier merge report APXINUPD.rdf which performs all the
   -- updates on the core table will call this API.
   -- Bug 3282938, EXP table IGI_EXP_DUS should be updated for
   -- Supplier merge.
   -- *************************************************************************

    PROCEDURE merge_vendor(p_api_version       IN  NUMBER
                           ,p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE
                           ,p_commit           IN  VARCHAR2 := FND_API.G_FALSE
                           ,p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
                           ,x_return_status    OUT NOCOPY VARCHAR2
                           ,x_msg_count        OUT NOCOPY NUMBER
                           ,x_msg_data         OUT NOCOPY VARCHAR2
                           ,p_new_vendor_id      IN  NUMBER
                           ,p_new_vendor_site_id IN  NUMBER
                           ,p_old_vendor_id      IN  NUMBER
                           ,p_old_vendor_site_id IN  NUMBER)
   IS

   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'VENDOR_MERGE';

   CURSOR c_chk_prms IS
   SELECT adv.paid_invoices_flag,
          adv.process
   FROM   ap_duplicate_vendors adv
   WHERE  adv.vendor_id = p_new_vendor_id
   AND    adv.duplicate_vendor_id = p_old_vendor_id
   AND    adv.duplicate_vendor_site_id = p_old_vendor_site_id
   AND    adv.process_flag IN ('S','D');

   l_paid_invoices_flag   ap_duplicate_vendors.paid_invoices_flag%TYPE;
   l_process              ap_duplicate_vendors.process%TYPE;

   BEGIN

     -- Standard call to check for call compatibility
     IF (NOT FND_API.Compatible_API_Call(l_api_version
                                       ,p_api_version
                                       ,l_api_name
                                       ,G_PKG_NAME))
     THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Check p_init_msg_list
     IF FND_API.to_Boolean(p_init_msg_list)
     THEN
        FND_MSG_PUB.initialize;
     END IF;

     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     OPEN c_chk_prms;
     FETCH c_chk_prms INTO l_paid_invoices_flag,
                           l_process;
     CLOSE c_chk_prms;

     -- If user has chosen to update paid invoices, and if CIS
     -- is enabled, then update the CIS table.
     IF l_paid_invoices_flag = 'Y'
     AND l_process <> 'P' -- not only purchase orders.
     AND igi_gen.is_req_installed('CIS')
     THEN
         UPDATE igi_cis_payment_vouchers
         SET    vendor_id         = p_new_vendor_id,
                vendor_site_id    = p_new_vendor_site_id,
                last_update_date  = SYSDATE,
                last_update_login = FND_GLOBAL.login_id,
                last_updated_by   = FND_GLOBAL.user_id
         WHERE  vendor_id         = p_old_vendor_id
         AND    vendor_site_id    = p_old_vendor_site_id;

     END IF;

     -- If user has chosen to update invoices
     -- And EXP is enabled, then update the EXP table.
     IF  l_process <> 'P' -- not only purchase orders.
     AND igi_gen.is_req_installed('EXP')
     THEN
         update_EXP_tables (p_paid_invoices_flag => l_paid_invoices_flag,
                            p_old_vendor_id      => p_old_vendor_id,
                            p_old_vendor_site_id => p_old_vendor_site_id,
                            p_new_vendor_id      => p_new_vendor_id,
                            p_new_vendor_site_id => p_new_vendor_site_id,
                            x_return_status      => x_return_status,
                            x_msg_count          => x_msg_count,
                            x_msg_data           => x_msg_data);
     END IF;


     -- If user has chosen to process PO's and if
     -- CC is enabled then call the CC API to update the CC table
     IF  l_process <> 'I' -- not only invoices
     AND igi_gen.is_req_installed('CC')
     THEN
         IGC_VENDOR_MERGE_PVT.MERGE_VENDOR
             (p_api_version         => 1.0
              ,p_init_msg_list      => FND_API.G_FALSE
              ,p_commit             => FND_API.G_FALSE
              ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
              ,x_return_status      => x_return_status
              ,x_msg_count          => x_msg_count
              ,x_msg_data           => x_msg_data
              ,p_new_vendor_id      => p_new_vendor_id
              ,p_new_vendor_site_id => p_new_vendor_site_id
              ,p_old_vendor_id      => p_old_vendor_id
              ,p_old_vendor_site_id => p_old_vendor_site_id);
     END IF;

     IF p_commit         = FND_API.G_TRUE
     AND x_return_status = FND_API.G_RET_STS_SUCCESS
     THEN
         COMMIT;
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                              p_data  => x_msg_data);

     EXCEPTION
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR
     THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                   p_data  => x_msg_data);

     WHEN OTHERS
     THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name);
          END IF;

          FND_MSG_PUB.Count_And_Get( p_count  => x_msg_count,
                                     p_data   => x_msg_data);
   END merge_vendor;

   -- *************************************************************************
   -- Procedure : Update_EXP_Tables
   -- Bug 3282938, EXP table IGI_EXP_DUS should be updated for
   -- Supplier merge.
   -- *************************************************************************
   PROCEDURE update_EXP_tables (p_paid_invoices_flag   IN          VARCHAR2,
                                p_old_vendor_id        IN          NUMBER,
                                p_old_vendor_site_id   IN          NUMBER,
                                p_new_vendor_id        IN          NUMBER,
                                p_new_vendor_site_id   IN          NUMBER,
                                x_return_status        OUT NOCOPY VARCHAR2 ,
                                x_msg_count            OUT NOCOPY NUMBER ,
                                x_msg_data             OUT NOCOPY VARCHAR2)
   IS
   l_api_name             VARCHAR2(30) := 'Update_EXP_Tables';
   BEGIN

     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- If user has chosen to update all invoices (paid + unpaid)
     -- then update all the dialog units irrespective of their status.
     IF p_paid_invoices_flag = 'Y'
     THEN
         -- Update all the Dialog Units associcated with payables.
         UPDATE igi_exp_dus du
         SET    du.du_stp_id         = p_new_vendor_id,
                du.du_stp_site_id    = p_new_vendor_site_id,
                du.last_update_date  = SYSDATE,
                du.last_update_login = FND_GLOBAL.login_id,
                du.last_updated_by   = FND_GLOBAL.user_id
         WHERE  du.du_stp_id         = p_old_vendor_id
         AND    du.du_stp_site_id    = p_old_vendor_site_id
         AND    du.du_type_header_id  IN
                     (SELECT  du_type_header_id
                      FROM    igi_exp_du_type_headers
                      WHERE   application_id = 200) ;
     ELSE
         -- User has chosen to update only unpaid invoices
         -- Update all dialog units which are not completed.
         UPDATE igi_exp_dus du
         SET    du.du_stp_id         = p_new_vendor_id,
                du.du_stp_site_id    = p_new_vendor_site_id,
                du.last_update_date  = SYSDATE,
                du.last_update_login = FND_GLOBAL.login_id,
                du.last_updated_by   = FND_GLOBAL.user_id
         WHERE  du.du_stp_id         = p_old_vendor_id
         AND    du.du_stp_site_id    = p_old_vendor_site_id
         AND    du.du_status         <> 'COM'
         AND    du.du_type_header_id  IN
                     (SELECT  du_type_header_id
                      FROM    igi_exp_du_type_headers
                      WHERE   application_id = 200) ;

         --
         -- Then update all the dialog units which are completed but
         -- none of the invoices have been paid.
         UPDATE igi_exp_dus du
         SET    du.du_stp_id         = p_new_vendor_id,
                du.du_stp_site_id    = p_new_vendor_site_id,
                du.last_update_date  = SYSDATE,
                du.last_update_login = FND_GLOBAL.login_id,
                du.last_updated_by   = FND_GLOBAL.user_id
         WHERE  du.du_stp_id         = p_old_vendor_id
         AND    du.du_stp_site_id    = p_old_vendor_site_id
         AND    du.du_status         = 'COM'
         AND    du.du_type_header_id  IN
                     (SELECT  du_type_header_id
                      FROM    igi_exp_du_type_headers
                      WHERE   application_id = 200)
         AND    NOT EXISTS
                     (SELECT 'X'
                      FROM   ap_invoices api,
                             igi_exp_ap_trans eapi
                      WHERE  eapi.du_id              = du.du_id
                      AND    eapi.invoice_id         = api.invoice_id
                      AND    Nvl(api.payment_status_flag,'N') = 'Y');

     END IF ; --  p_paid_invoices_flag = 'Y'

     EXCEPTION
     WHEN OTHERS
     THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name);
          END IF;

   END update_EXP_tables;

END IGI_VENDOR_MERGE_GRP;


/
