--------------------------------------------------------
--  DDL for Package Body FA_VENDORMERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_VENDORMERGE_GRP" AS
/* $Header: FAPVDMGB.pls 120.1.12010000.2 2009/07/19 12:53:22 glchen ship $   */

--
-- Global Constant Variables
--
G_PKG_NAME      CONSTANT   varchar2(30) := 'FA_VendorMerge_GRP';
G_API_NAME      CONSTANT   varchar2(30) := 'Vendor_Merge';
G_API_VERSION   CONSTANT   number       := 1.0;

g_log_level_rec            fa_api_types.log_level_rec_type;

PROCEDURE Merge_Vendor(
              p_api_version        IN            NUMBER
            , p_init_msg_list      IN            VARCHAR2 default FND_API.G_FALSE
            , p_commit             IN            VARCHAR2 default FND_API.G_FALSE
            , p_validation_level   IN            NUMBER   default FND_API.G_VALID_LEVEL_FULL
            , x_return_status         OUT NOCOPY VARCHAR2
            , x_msg_count             OUT NOCOPY NUMBER
            , x_msg_data              OUT NOCOPY VARCHAR2
            , p_vendor_id          IN            NUMBER
            , p_dup_vendor_id      IN            NUMBER
            , p_vendor_site_id     IN            NUMBER
            , p_dup_vendor_site_id IN            NUMBER
            , p_party_id           IN            NUMBER
            , p_dup_party_id       IN            NUMBER
            , p_party_site_id      IN            NUMBER
            , p_dup_party_site_id  IN            NUMBER
            , p_segment1           IN            VARCHAR2 -- Vendor Number
            , p_dup_segment1       IN            VARCHAR2
            , p_vendor_name        IN            VARCHAR2 default NULL
) IS


   l_calling_fn     varchar2(50) := 'FA_VendorMerge_GRP.Merge_Vendor';
   l_location       varchar2(50);
   l_row_count      binary_integer;
   --
   -- This can be removed if parameters for vendor name are added
   --
   l_vendor_name     varchar2(240);

   CURSOR c_get_vendor_name IS
      select vendor_name
      from   po_vendors
      where  vendor_id = p_vendor_id;
   --
   --
   --

   mrg_err          exception;


BEGIN
   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'BEGIN', to_char(p_vendor_id)||':'||to_char(p_dup_vendor_id)||':'||
                                              to_char(p_vendor_site_id)||':'||to_char(p_dup_vendor_site_id),
                       p_log_level_rec => g_log_level_rec);
   end if;

   SAVEPOINT sp_vendor_merge;

   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec)) then

         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Failed calling', 'fa_util_pub.get_log_level_rec',
                             p_log_level_rec => g_log_level_rec);
         end if;

         raise mrg_err;
      end if;
   end if;

   l_row_count := 0;

   l_location := 'Calling fnd_api.compatible_api_call';
   -- Check version of the API
   -- Standard call to check for API call compatibility.
   if NOT fnd_api.compatible_api_call (
          G_API_VERSION,
          p_api_version,
          G_API_NAME,
          G_PKG_NAME) then
      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Failed calling', 'fnd_api.compatible_api_call',
                          p_log_level_rec => g_log_level_rec);
      end if;

      raise mrg_err;
   end if;


   --
   -- This can be removed if parameters for vendor name are added
   --
   if (p_vendor_name is null) then
      l_location := 'Getting vendor info';
      open c_get_vendor_name;
      fetch c_get_vendor_name INTO l_vendor_name;

      if c_get_vendor_name%notfound then
         close c_get_vendor_name;

         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Failed getting', 'vendor informatioin',
                             p_log_level_rec => g_log_level_rec);
         end if;

         raise mrg_err;
      end if;

      close c_get_vendor_name;
   else
      l_vendor_name := p_vendor_name;
   end if;
   --
   --
   --

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Start Updating', 'processing...',
                       p_log_level_rec => g_log_level_rec);
   end if;

   -- **********************************************************
   -- Updating FA_INS_LINES          : VENDOR_ID
   -- **********************************************************
   l_location := 'FA_INS_LINES';
   update FA_INS_LINES
   set    VENDOR_ID = p_vendor_id
   where  VENDOR_ID = p_dup_vendor_id;

   -- **********************************************************
   -- Updating FA_INS_MST_POLS       : VENDOR_ID, VENDOR_SITE_ID
   -- **********************************************************
   l_location := 'FA_INS_MST_POLS';
   update FA_INS_MST_POLS
   set    VENDOR_ID      = p_vendor_id
        , VENDOR_SITE_ID = decode(VENDOR_SITE_ID, p_dup_vendor_site_id, p_vendor_site_id, VENDOR_SITE_ID)
   where  VENDOR_ID      = p_dup_vendor_id
   and    nvl(VENDOR_SITE_ID, 0)  = decode(VENDOR_SITE_ID, NULL, 0, p_dup_vendor_site_id);

   -- **********************************************************
   -- Updating FA_INS_POLICIES       : VENDOR_ID, VENDOR_SITE_ID
   -- **********************************************************
   l_location := 'FA_INS_POLICIES';
   update FA_INS_POLICIES
   set    VENDOR_ID      = p_vendor_id
        , VENDOR_SITE_ID = decode(VENDOR_SITE_ID, p_dup_vendor_site_id, p_vendor_site_id, VENDOR_SITE_ID)
   where  VENDOR_ID      = p_dup_vendor_id
   and    nvl(VENDOR_SITE_ID, 0)  = decode(VENDOR_SITE_ID, NULL, 0, p_dup_vendor_site_id);

   -- **********************************************************
   -- Updating FA_INS_VALUES         : VENDOR_ID
   -- **********************************************************
   l_location := 'FA_INS_VALUES';
   update FA_INS_VALUES
   set    VENDOR_ID = p_vendor_id
   where  VENDOR_ID = p_dup_vendor_id;

   -- **********************************************************
   -- Updating FA_MAINT_EVENTS       : VENDOR_ID
   -- **********************************************************
   l_location := 'FA_MAINT_EVENTS';
   update FA_MAINT_EVENTS
   set    VENDOR_ID = p_vendor_id
   where  VENDOR_ID = p_dup_vendor_id;

   -- **********************************************************
   -- Updating FA_MAINT_SCHEDULE_DTL : VENDOR_ID, VENDOR_NAME
   -- **********************************************************
   l_location := 'FA_MAINT_SCHEDULE_DTL';
   update FA_MAINT_SCHEDULE_DTL
   set    VENDOR_ID     = p_vendor_id
        , VENDOR_NAME   = decode(VENDOR_NAME, NULL, NULL, l_vendor_name)
        , VENDOR_NUMBER = decode(VENDOR_NUMBER, NULL, NULL, p_segment1)
   where  VENDOR_ID     = p_dup_vendor_id;

   -- **********************************************************
   -- Updating FA_WARRANTIES         : PO_VENDOR_ID
   -- **********************************************************
   l_location := 'FA_WARRANTIES';
   update FA_WARRANTIES
   set    PO_VENDOR_ID = p_vendor_id
   where  PO_VENDOR_ID = p_dup_vendor_id;

   -- **********************************************************
   -- Updating FA_LEASES             : LESSOR_ID, LESSOR_SITE_ID
   -- **********************************************************
   l_location := 'FA_LEASES';
   update FA_LEASES
   set    LESSOR_ID      = p_vendor_id
        , LESSOR_SITE_ID = decode(LESSOR_SITE_ID, p_dup_vendor_site_id, p_vendor_site_id, LESSOR_SITE_ID)
   where  LESSOR_ID      = p_dup_vendor_id
   and    nvl(LESSOR_SITE_ID, 0) = decode(LESSOR_SITE_ID, NULL, 0, p_dup_vendor_site_id);

   -- **********************************************************
   -- Updating FA_LEASE_PAYMENT_ITEMS: LESSOR_ID, LESSOR_SITE_ID
   -- **********************************************************
   l_location := 'FA_LEASE_PAYMENT_ITEMS';
   update FA_LEASE_PAYMENT_ITEMS
   set    LESSOR_ID      = p_vendor_id
        , LESSOR_SITE_ID = p_vendor_site_id
   where  LESSOR_ID      = p_dup_vendor_id
   and    LESSOR_SITE_ID = p_dup_vendor_site_id;

   -- **********************************************************
   -- Updating FA_ASSET_INVOICES     : PO_VENDOR_ID
   -- **********************************************************
   l_location := 'FA_ASSET_INVOICES';
   update FA_ASSET_INVOICES
   set    PO_VENDOR_ID = p_vendor_id
   where  PO_VENDOR_ID = p_dup_vendor_id;

   -- **********************************************************
   -- Updating FA_MC_ASSET_INVOICES  : PO_VENDOR_ID
   -- **********************************************************
   l_location := 'FA_MC_ASSET_INVOICES';
   update FA_MC_ASSET_INVOICES
   set    PO_VENDOR_ID =  p_vendor_id
   where  PO_VENDOR_ID = p_dup_vendor_id;

   -- **********************************************************
   -- Updating FA_MASS_ADDITIONS     : PO_VENDOR_ID, LESSOR_ID, VENDOR_NUMBER
   -- **********************************************************
   l_location := 'FA_MASS_ADDITIONS';
   update FA_MASS_ADDITIONS
   set    PO_VENDOR_ID  = decode(PO_VENDOR_ID, p_dup_vendor_id, p_vendor_id, PO_VENDOR_ID)
        , LESSOR_ID     = decode(LESSOR_ID, p_dup_vendor_id, p_vendor_id, LESSOR_ID)
        , VENDOR_NUMBER = decode(PO_VENDOR_ID, p_dup_vendor_id,
                                               decode(VENDOR_NUMBER, NULL, NULL, p_segment1),
                                               VENDOR_NUMBER)
   where  (PO_VENDOR_ID  =  p_dup_vendor_id
        or LESSOR_ID     =  p_dup_vendor_id);


   -- **********************************************************
   --
   --                     ITF(RXi) tables
   --
   -- **********************************************************

   --
   -- Updating FA_ADDITION_REP_ITF   : VENDOR_NUMBER
   --
   l_location := 'FA_ADDITION_REP_ITF';
   update FA_ADDITION_REP_ITF
   set    VENDOR_NUMBER   = p_segment1
   where  VENDOR_NUMBER   = p_dup_segment1;

   --
   -- Updating FA_MAINT_REP_ITF      : VENDOR_NAME, VENDOR_NUMBER
   --
   l_location := 'FA_MAINT_REP_ITF';
   update FA_MAINT_REP_ITF
   set    VENDOR_NAME     = l_vendor_name
        , VENDOR_NUMBER   = p_segment1
   where  VENDOR_NUMBER   = p_dup_segment1;

   --
   -- Updating FA_MASSADD_REP_ITF    : VENDOR_NAME, VENDOR_NUMBER
   --
   l_location := 'FA_MASSADD_REP_ITF';
   update FA_MASSADD_REP_ITF
   set    VENDOR_NAME     = l_vendor_name
        , VENDOR_NUMBER   = p_segment1
   where  VENDOR_NUMBER   = p_dup_segment1;


   -- Commenting out as this is not necessary
   -- if FND_API.to_boolean(p_commit) then
   --    COMMIT;
   -- end if;

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'End', 'SUCCESS',
                       p_log_level_rec => g_log_level_rec);
   end if;

EXCEPTION
  WHEN mrg_err THEN
     ROLLBACK TO sp_vendor_merge;

     fa_srvr_msg.add_message(calling_fn      => l_calling_fn,
                             p_log_level_rec => g_log_level_rec);
     FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                               p_data  => x_msg_data);
     x_return_status :=  FND_API.G_RET_STS_ERROR;

  WHEN OTHERS THEN
     ROLLBACK TO sp_vendor_merge;

     if (g_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn, 'EXCEPTION(OTHERS)', l_location,
                         p_log_level_rec => g_log_level_rec);
     end if;

     fa_srvr_msg.add_message(calling_fn => l_calling_fn,
                             name       => 'FA_SHARED_ACTION_TABLE',
                             token1     => 'ACTION',
                             value1     => 'Update',
                             token2     => 'TABLE',
                             value2     => l_location,
                             p_log_level_rec => g_log_level_rec);

     fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn,
                               p_log_level_rec => g_log_level_rec);

     FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                               p_data  => x_msg_data);
     x_return_status :=  FND_API.G_RET_STS_ERROR;

END Merge_Vendor;

END FA_VENDORMERGE_GRP;

/
