--------------------------------------------------------
--  DDL for Package Body INL_TCAMERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INL_TCAMERGE_GRP" AS
/* $Header: INLGMRGB.pls 120.1.12010000.2 2013/09/09 14:57:09 acferrei ship $ */
--
--========================================================================
-- PROCEDURE :Merge_Vendors
-- PARAMETERS:
--              p_from_id             Merge from vendor ID
--              p_to_id               Merge to vendor ID
--              p_from_party_id       Merge from party ID
--              p_to_party_id         Merge to party ID
--              p_from_site_id        Merge from vendor site ID
--              p_to_site_id          Merge to vendor site ID
--              p_from_party_site_id  Merge from party site ID
--              p_to_party_site_id    Merge to party site ID
--              p_calling_mode        Either 'INVOICE' or 'PO'
--              x_return_status       Return status
--
-- COMMENT :
--           This is the core INL Vendor merge routine that is called from
--           Merge_VendorParties() API.
--
--           Parameter p_calling_mode indicates what updates to perform.
--           'INVOICE' ==> Update only non-PO entities
--           'PO'      ==> Update PO related entities
--========================================================================
PROCEDURE Merge_Vendors (
                     p_from_id         IN   NUMBER,
                     p_to_id           IN   NUMBER,
                     p_from_party_id   IN   NUMBER,
                     p_to_party_id     IN   NUMBER,
                     p_from_site_id    IN   NUMBER,
                     p_to_site_id      IN   NUMBER,
                     p_from_party_site_id    IN   NUMBER,
                     p_to_party_site_id      IN   NUMBER,
                     p_calling_mode    IN   VARCHAR2,
                     x_return_status   OUT  NOCOPY VARCHAR2 ) IS
 --
 CURSOR c_simulations IS
 SELECT simulation_id
 FROM   inl_simulations
 WHERE  vendor_id = p_from_id
 AND    vendor_site_id = p_from_site_id;

 CURSOR c_line_groups IS
 SELECT ship_line_group_id
 FROM   inl_ship_line_groups
 WHERE  party_id = p_from_party_id
 AND    party_site_id = p_from_party_site_id
 AND    src_type_code = 'PO';

 CURSOR c_lines IS
 SELECT ship_line_id
 FROM   inl_ship_lines_all
 WHERE  ((poa_party_id = p_from_id AND poa_party_site_id = p_from_site_id)
      OR (ship_from_party_id = p_from_id AND ship_from_party_site_id = p_from_site_id)
      OR (bill_from_party_id = p_from_id AND bill_from_party_site_id = p_from_site_id))
 AND    ship_line_src_type_code = 'PO';

 CURSOR c_charge_lines IS
 SELECT charge_line_id
 FROM   inl_charge_lines cl
 WHERE  (cl.party_id = p_from_party_id or cl.party_site_id = p_from_party_site_id)
 AND    ((cl.ship_from_party_id = p_from_id AND cl.ship_from_party_site_id = p_from_site_id)
     OR  (cl.bill_from_party_id = p_from_id AND cl.bill_from_party_site_id = p_from_site_id)
     OR  (cl.poa_party_id = p_from_id AND cl.poa_party_site_id = p_from_site_id));

 CURSOR c_matches IS
 SELECT match_id
 FROM   INL_MATCHES
 WHERE  party_id = p_from_party_id
 AND    party_site_id = p_from_party_site_id;
 --
 TYPE id_tbl_type is TABLE of NUMBER INDEX BY BINARY_INTEGER;
 l_simulation_list         id_tbl_type;
 l_line_group_list         id_tbl_type;
 l_line_list               id_tbl_type;
 l_charge_line_list        id_tbl_type;
 l_match_list              id_tbl_type;
 l_proc_name               CONSTANT VARCHAR2 (30) := 'Merge_Vendors';
 l_debug_info              VARCHAR2(200);
 j                         NUMBER := 0;
--
BEGIN
--{
       -- Standard Beginning of Procedure/Function Logging
       INL_LOGGING_PVT.Log_BeginProc ( p_module_name => g_module_name,
                                       p_procedure_name => l_proc_name) ;

       -- Standard Start of API savepoint
       SAVEPOINT Merge_Vendors_GRP;
       --

       --  Initialize API return status to success
       x_return_status :=  FND_API.G_RET_STS_SUCCESS;
       --

       -- Logging variables
       INL_LOGGING_PVT.Log_Variable ( p_module_name => g_module_name,
                                      p_procedure_name => l_proc_name,
                                      p_var_name => 'p_from_id',
                                      p_var_value => p_from_id);
       INL_LOGGING_PVT.Log_Variable ( p_module_name => g_module_name,
                                      p_procedure_name => l_proc_name,
                                      p_var_name => 'p_to_id',
                                      p_var_value => p_to_id) ;
       INL_LOGGING_PVT.Log_Variable ( p_module_name => g_module_name,
                                      p_procedure_name => l_proc_name,
                                      p_var_name => 'p_from_party_id',
                                      p_var_value => p_from_party_id) ;
       INL_LOGGING_PVT.Log_Variable ( p_module_name => g_module_name,
                                      p_procedure_name => l_proc_name,
                                      p_var_name => 'p_to_party_id',
                                      p_var_value => p_to_party_id) ;
       INL_LOGGING_PVT.Log_Variable ( p_module_name => g_module_name,
                                      p_procedure_name => l_proc_name,
                                      p_var_name => 'p_from_site_id',
                                      p_var_value => p_from_site_id) ;
       INL_LOGGING_PVT.Log_Variable ( p_module_name => g_module_name,
                                      p_procedure_name => l_proc_name,
                                      p_var_name => 'p_to_site_id',
                                      p_var_value => p_to_site_id) ;
       INL_LOGGING_PVT.Log_Variable ( p_module_name => g_module_name,
                                      p_procedure_name => l_proc_name,
                                      p_var_name => 'p_from_party_site_id',
                                      p_var_value => p_from_party_site_id) ;
       INL_LOGGING_PVT.Log_Variable ( p_module_name => g_module_name,
                                      p_procedure_name => l_proc_name,
                                      p_var_name => 'p_to_party_site_id',
                                      p_var_value => p_to_party_site_id) ;
       INL_LOGGING_PVT.Log_Variable ( p_module_name => g_module_name,
                                      p_procedure_name => l_proc_name,
                                      p_var_name => 'p_calling_mode',
                                      p_var_value => p_calling_mode) ;

       --
       -- Update PO related entities only when the mode is PO
       --
       IF (p_calling_mode = 'PO') THEN
        --{
                --{
                OPEN  c_simulations;
                FETCH c_simulations BULK COLLECT INTO l_simulation_list;
                CLOSE c_simulations;

                l_debug_info := 'Count of Rows fetched from Cursor C_SIMULATIONS  = '||l_simulation_list.count;
                INL_LOGGING_PVT.Log_Statement ( p_module_name => g_module_name,
                                                p_procedure_name => l_proc_name,
                                                p_debug_info => l_debug_info) ;

                IF l_simulation_list.COUNT > 0 THEN
                        --
                        FORALL j IN l_simulation_list.FIRST..l_simulation_list.LAST
                                UPDATE inl_simulations
                                SET vendor_id              = p_to_id,
                                    vendor_site_id         = p_to_site_id,
                                    request_id             = fnd_global.conc_request_id,
                                    program_id             = fnd_global.conc_program_id,
                                    program_application_id = fnd_global.prog_appl_id,
                                    last_update_date       = sysdate,
                                    last_updated_by        = fnd_global.user_id,
                                    last_update_login      = fnd_global.login_id
                                WHERE simulation_id        = l_simulation_list(j);

                         l_debug_info := 'Updated inl_simulations. Number of Rows updated is ' || sql%rowcount;
                         INL_LOGGING_PVT.Log_Statement ( p_module_name => g_module_name,
                                                         p_procedure_name => l_proc_name,
                                                         p_debug_info => l_debug_info) ;
                END IF;
                --}

                --{
                OPEN  c_line_groups;
                FETCH c_line_groups BULK COLLECT INTO l_line_group_list;
                CLOSE c_line_groups;

                l_debug_info := 'Count of Rows fetched from Cursor C_LINE_GROUPS  = '||l_line_group_list.count;
                INL_LOGGING_PVT.Log_Statement ( p_module_name => g_module_name,
                                                p_procedure_name => l_proc_name,
                                                p_debug_info => l_debug_info) ;

                IF l_line_group_list.COUNT > 0 THEN
                        --
                        FORALL j IN l_line_group_list.FIRST..l_line_group_list.LAST
                                UPDATE inl_ship_line_groups
                                SET party_id               = p_to_party_id,
                                    party_site_id          = p_to_party_site_id,
                                    request_id             = fnd_global.conc_request_id,
                                    program_id             = fnd_global.conc_program_id,
                                    program_application_id = fnd_global.prog_appl_id,
                                    last_update_date       = sysdate,
                                    last_updated_by        = fnd_global.user_id,
                                    last_update_login      = fnd_global.login_id
                                WHERE ship_line_group_id   = l_line_group_list(j);

                         l_debug_info := 'Updated inl_ship_line_groups. Number of Rows updated is ' || sql%rowcount;
                         INL_LOGGING_PVT.Log_Statement ( p_module_name => g_module_name,
                                                         p_procedure_name => l_proc_name,
                                                         p_debug_info => l_debug_info) ;
                END IF;
                --}

                --{
                OPEN  c_lines;
                FETCH c_lines BULK COLLECT INTO l_line_list;
                CLOSE c_lines;

                l_debug_info := 'Count of Rows fetched from Cursor C_LINES  = ' || l_line_list.count;
                INL_LOGGING_PVT.Log_Statement ( p_module_name => g_module_name,
                                                p_procedure_name => l_proc_name,
                                                p_debug_info => l_debug_info) ;

                IF l_line_list.COUNT > 0 THEN
                        --
                        FORALL j IN l_line_list.FIRST..l_line_list.LAST
                                UPDATE inl_ship_lines_all
                                SET poa_party_id            = decode(poa_party_id,p_from_id,p_to_id,poa_party_id),
                                    poa_party_site_id       = decode(poa_party_site_id,p_from_site_id,p_to_site_id,poa_party_site_id),
                                    ship_from_party_id      = decode(ship_from_party_id,p_from_id,p_to_id,ship_from_party_id),
                                    ship_from_party_site_id = decode(ship_from_party_site_id,p_from_site_id,p_to_site_id,ship_from_party_site_id),
                                    bill_from_party_id      = decode(bill_from_party_id,p_from_id,p_to_id,bill_from_party_id),
                                    bill_from_party_site_id = decode(bill_from_party_site_id,p_from_site_id,p_to_site_id,bill_from_party_site_id),
                                    request_id              = fnd_global.conc_request_id,
                                    program_id              = fnd_global.conc_program_id,
                                    program_application_id  = fnd_global.prog_appl_id,
                                    last_update_date        = sysdate,
                                    last_updated_by         = fnd_global.user_id,
                                    last_update_login       = fnd_global.login_id
                                WHERE ship_line_id          = l_line_list(j);

                         l_debug_info := 'Updated inl_ship_lines_all. Number of Rows updated is ' || sql%rowcount;
                         INL_LOGGING_PVT.Log_Statement ( p_module_name => g_module_name,
                                                         p_procedure_name => l_proc_name,
                                                         p_debug_info => l_debug_info) ;
                END IF;
                --}

                --{
                OPEN  c_charge_lines;
                FETCH c_charge_lines BULK COLLECT INTO l_charge_line_list;
                CLOSE c_charge_lines;

                l_debug_info := 'Count of Rows fetched from Cursor C_CHARGE_LINES  = ' || l_charge_line_list.count;
                INL_LOGGING_PVT.Log_Statement ( p_module_name => g_module_name,
                                                p_procedure_name => l_proc_name,
                                                p_debug_info => l_debug_info) ;

                IF l_charge_line_list.COUNT > 0 THEN
                        --
                        FORALL j IN l_charge_line_list.FIRST..l_charge_line_list.LAST
                                UPDATE inl_charge_lines
                                SET ship_from_party_id      = decode(ship_from_party_id,p_from_id,p_to_id,ship_from_party_id),
                                    ship_from_party_site_id = decode(nvl(ship_from_party_site_id,-1),-1,null,p_from_site_id,p_to_site_id,ship_from_party_site_id),
                                    bill_from_party_id      = decode(bill_from_party_id,p_from_id,p_to_id,bill_from_party_id),
                                    bill_from_party_site_id = decode(nvl(bill_from_party_site_id,-1),-1,null,p_from_site_id,p_to_site_id,bill_from_party_site_id),
                                    poa_party_id            = decode(poa_party_id,p_from_id,p_to_id,poa_party_id),
                                    poa_party_site_id       = decode(nvl(poa_party_site_id,-1),-1,null,p_from_site_id,p_to_site_id,poa_party_site_id),
                                    party_id                = p_to_party_id,
                                    party_site_id           = decode(nvl(party_site_id,-1),-1,null,p_from_party_site_id,p_to_party_site_id,party_site_id),
                                    last_update_date        = sysdate,
                                    last_updated_by         = fnd_global.user_id,
                                    last_update_login       = fnd_global.login_id
                                WHERE charge_line_id        = l_charge_line_list(j);

                         l_debug_info := 'Updated inl_charges. Number of Rows updated is ' || sql%rowcount;
                         INL_LOGGING_PVT.Log_Statement ( p_module_name => g_module_name,
                                                         p_procedure_name => l_proc_name,
                                                         p_debug_info => l_debug_info) ;
                END IF;
                --}

                -- {
                OPEN  c_matches;
                FETCH c_matches BULK COLLECT INTO l_match_list;
                CLOSE c_matches;

                l_debug_info := 'Count of Rows fetched from Cursor C_MATCHES  = '||l_match_list.count;
                INL_LOGGING_PVT.Log_Statement ( p_module_name => g_module_name,
                                                p_procedure_name => l_proc_name,
                                                p_debug_info => l_debug_info) ;

                IF l_match_list.COUNT > 0 THEN
                        --
                        FORALL j IN l_match_list.FIRST..l_match_list.LAST
                                UPDATE inl_matches
                                SET party_id               = p_to_party_id,
                                    party_site_id          = p_to_party_site_id,
                                    request_id             = fnd_global.conc_request_id,
                                    program_id             = fnd_global.conc_program_id,
                                    program_application_id = fnd_global.prog_appl_id,
                                    last_update_date       = sysdate,
                                    last_updated_by        = fnd_global.user_id,
                                    last_update_login      = fnd_global.login_id
                                WHERE match_id   = l_match_list(j);

                         l_debug_info := 'Updated inl_matches. Number of Rows updated is ' || sql%rowcount;
                         INL_LOGGING_PVT.Log_Statement ( p_module_name => g_module_name,
                                                         p_procedure_name => l_proc_name,
                                                         p_debug_info => l_debug_info) ;
                END IF;
                --}
        --}
       END IF;
       --
       l_debug_info := 'x_return_status '||x_return_status;
       INL_LOGGING_PVT.Log_Statement ( p_module_name => g_module_name,
                                       p_procedure_name => l_proc_name,
                                       p_debug_info => l_debug_info) ;

       -- Standard End of Procedure/Function Logging
       INL_LOGGING_PVT.Log_EndProc ( p_module_name => g_module_name,
                                     p_procedure_name => l_proc_name) ;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError (p_module_name    => g_module_name,
                                    p_procedure_name => l_proc_name);
    ROLLBACK TO Merge_Vendors_GRP;
    x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                      p_procedure_name => l_proc_name);
    ROLLBACK TO Merge_Vendors_GRP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                      p_procedure_name => l_proc_name);
    ROLLBACK TO Merge_Vendors_GRP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,l_proc_name);
    END IF;
--}
END Merge_Vendors;

--========================================================================
-- PROCEDURE :Merge_VendorParties
-- PARAMETERS:
--              p_from_vendor_id               Merge from vendor ID
--              p_to_vendor_id                 Merge to vendor ID
--              p_from_party_id                Merge from party ID
--              p_to_party_id                  Merge to party ID
--              p_from_vendor_site_id          Merge from vendor site ID
--              p_to_vendor_site_id            Merge to vendor site ID
--              p_from_party_site_id           Merge from party site ID
--              p_to_party_site_id             Merge to party site ID
--              p_calling_mode                 Mode in which AP calls us
--                                             'INVOICE' or 'PO'
--              x_return_status                Return status
--              x_msg_count                    Return count message
--              x_msg_data                     Return message data
--
-- COMMENTS
--         This is the API that is called by APXINUPD.rdf.  This in turn
--         will call the core Merge_Vendors() procedure to
--         perform all the necessary updates to LCM data.
--
--========================================================================

PROCEDURE Merge_VendorParties
             ( p_from_vendor_id          IN         NUMBER,
               p_to_vendor_id            IN         NUMBER,
               p_from_party_id           IN         NUMBER,
               p_to_party_id             IN         NUMBER,
               p_from_vendor_site_id     IN         NUMBER,
               p_to_vendor_site_id       IN         NUMBER,
               p_from_party_site_id      IN         NUMBER,
               p_to_party_site_id        IN         NUMBER,
               p_calling_mode            IN         VARCHAR2,
               x_return_status           OUT NOCOPY VARCHAR2,
               x_msg_count               OUT NOCOPY NUMBER,
               x_msg_data                OUT NOCOPY VARCHAR2
             )
IS
  --
  CURSOR c_getParty(p_vendorId IN NUMBER) IS
  SELECT party_id
  FROM po_vendors
  WHERE vendor_id = p_vendorId;

  CURSOR c_getPartySite(p_vendorSiteId IN NUMBER) IS
  SELECT party_site_id
  FROM po_vendor_sites_all
  WHERE vendor_site_id = p_vendorSiteId;
  --
  l_proc_name            CONSTANT VARCHAR2 (30) := 'Merge_VendorParties';
  l_debug_info           VARCHAR2(200);
  l_return_status        VARCHAR2(1);
  l_fromPartyId          NUMBER;
  l_toPartyId            NUMBER;
  l_fromPartySiteId      NUMBER;
  l_toPartySiteId        NUMBER;
  --
BEGIN
  --{
  -- Standard Beginning of Procedure/Function Logging
  INL_LOGGING_PVT.Log_BeginProc ( p_module_name => g_module_name,
                                  p_procedure_name => l_proc_name);

  -- Standard Start of API savepoint
  SAVEPOINT Merge_VendorParties_GRP;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --

  -- Logging variables
  INL_LOGGING_PVT.Log_Variable ( p_module_name => g_module_name,
                                 p_procedure_name => l_proc_name,
                                 p_var_name => 'p_from_vendor_id',
                                 p_var_value => p_from_vendor_id);
  INL_LOGGING_PVT.Log_Variable ( p_module_name => g_module_name,
                                 p_procedure_name => l_proc_name,
                                 p_var_name => 'p_to_vendor_id',
                                 p_var_value => p_to_vendor_id) ;
  INL_LOGGING_PVT.Log_Variable ( p_module_name => g_module_name,
                                 p_procedure_name => l_proc_name,
                                 p_var_name => 'p_from_party_id',
                                 p_var_value => p_from_party_id) ;
  INL_LOGGING_PVT.Log_Variable ( p_module_name => g_module_name,
                                 p_procedure_name => l_proc_name,
                                 p_var_name => 'p_to_party_id',
                                 p_var_value => p_to_party_id) ;
  INL_LOGGING_PVT.Log_Variable ( p_module_name => g_module_name,
                                 p_procedure_name => l_proc_name,
                                 p_var_name => 'p_from_vendor_site_id',
                                 p_var_value => p_from_vendor_site_id) ;
  INL_LOGGING_PVT.Log_Variable ( p_module_name => g_module_name,
                                 p_procedure_name => l_proc_name,
                                 p_var_name => 'p_to_vendor_site_id',
                                 p_var_value => p_to_vendor_site_id) ;
  INL_LOGGING_PVT.Log_Variable ( p_module_name => g_module_name,
                                 p_procedure_name => l_proc_name,
                                 p_var_name => 'p_from_party_site_id',
                                 p_var_value => p_from_party_site_id) ;
  INL_LOGGING_PVT.Log_Variable ( p_module_name => g_module_name,
                                 p_procedure_name => l_proc_name,
                                 p_var_name => 'p_to_party_site_id',
                                 p_var_value => p_to_party_site_id) ;
  INL_LOGGING_PVT.Log_Variable ( p_module_name => g_module_name,
                                 p_procedure_name => l_proc_name,
                                 p_var_name => 'p_calling_mode',
                                 p_var_value => p_calling_mode) ;


  --
  IF p_from_party_id IS NULL THEN
    --
    OPEN c_getParty(p_from_vendor_id);
    FETCH c_getParty INTO l_fromPartyId;
    IF (c_getParty%NOTFOUND) THEN
     Null;
    END IF;
    CLOSE c_getParty;
    --
  END IF;

  IF p_from_party_site_id IS NULL THEN
    --
    OPEN c_getPartySite(p_from_vendor_site_id);
    FETCH c_getPartySite INTO l_fromPartySiteId;
    IF (c_getPartySite%NOTFOUND) THEN
     Null;
    END IF;
    CLOSE c_getPartySite;
    --
  END IF;

  IF p_to_party_id IS NULL THEN
    --
    OPEN c_getParty(p_to_vendor_id);
    FETCH c_getParty INTO l_toPartyId;
    IF (c_getParty%NOTFOUND) THEN
      Null;
    END IF;
    CLOSE c_getParty;
    --
  END IF;

  IF p_to_party_site_id IS NULL THEN
    --
    OPEN c_getPartySite(p_to_vendor_site_id);
    FETCH c_getPartySite INTO l_toPartySiteId;
    IF (c_getPartySite%NOTFOUND) THEN
      Null;
    END IF;
    CLOSE c_getPartySite;
    --
  END IF;
  --
  l_debug_info := 'l_fromPartyId '||l_fromPartyId||' l_toPartyId '||l_toPartyId||' l_fromPartySiteId '||l_fromPartySiteId||' l_toPartySiteId '||l_toPartySiteId;
  INL_LOGGING_PVT.Log_Statement ( p_module_name => g_module_name,
                                  p_procedure_name => l_proc_name,
                                  p_debug_info => l_debug_info) ;

  --
  -- Now call the core Vendor Merge routine to update INL data
  --
  INL_TCAMERGE_GRP.Merge_Vendors
    (
      p_from_id       => p_from_vendor_id,
      p_to_id         => P_to_vendor_id,
      p_from_party_id => NVL(p_from_party_id, l_fromPartyId),
      p_to_party_id   => NVL(p_to_party_id, l_toPartyId),
      p_from_site_id  => p_from_vendor_site_id,
      p_to_site_id    => p_to_vendor_site_id,
      p_from_party_site_id  => NVL(p_from_party_site_id, l_fromPartySiteId),
      p_to_party_site_id    => NVL(p_to_party_site_id, l_toPartySiteId),
      p_calling_mode  => p_calling_mode,
      x_return_status => l_return_status
    );
  --
  l_debug_info := 'After calling core Merge_Vendors API l_return_status '||l_return_status;
  INL_LOGGING_PVT.Log_Statement ( p_module_name => g_module_name,
                                  p_procedure_name => l_proc_name,
                                  p_debug_info => l_debug_info);

  -- If any errors happen abort API.
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  --
  l_debug_info := 'x_return_status '||x_return_status;
  INL_LOGGING_PVT.Log_Statement ( p_module_name => g_module_name,
                                  p_procedure_name => l_proc_name,
                                  p_debug_info => l_debug_info) ;

  -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                              p_count => x_msg_count,
                              p_data => x_msg_data);

  -- Standard End of Procedure/Function Logging
  INL_LOGGING_PVT.Log_EndProc ( p_module_name => g_module_name,
                                p_procedure_name => l_proc_name) ;

  --}
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError (p_module_name    => g_module_name,
                                    p_procedure_name => l_proc_name);
    ROLLBACK TO Merge_VendorParties_GRP;
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                      p_procedure_name => l_proc_name);
    ROLLBACK TO Merge_VendorParties_GRP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                      p_procedure_name => l_proc_name);
    ROLLBACK TO Merge_VendorParties_GRP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,l_proc_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                              p_count => x_msg_count,
                              p_data => x_msg_data);
END Merge_VendorParties;

--========================================================================
-- PROCEDURE :Merge_Parties
-- PARAMETERS:
--            p_entity_name                   Name of Entity Being Merged
--            p_from_id                       Primary Key Id of the entity that is being merged
--            p_to_id                         The record under the 'To Parent' that is being merged
--            p_from_fk_id                    Foreign Key id of the Old Parent Record
--            p_to_fk_id                      Foreign  Key id of the New Parent Record
--            p_parent_entity_name            Name of Parent Entity
--            p_batch_id                      Id of the Batch
--            p_batch_party_id                Id uniquely identifies the batch and party record that is being merged
--            x_return_status                 Returns the status of call
--
-- COMMENT   :
--
--========================================================================

PROCEDURE Merge_Parties
             ( p_entity_name         IN             VARCHAR2,
               p_from_id             IN             NUMBER,
               p_to_id               IN  OUT NOCOPY NUMBER,
               p_from_fk_id          IN             NUMBER,
               p_to_fk_id            IN             NUMBER,
               p_parent_entity_name  IN             VARCHAR2,
               p_batch_id            IN             NUMBER,
               p_batch_party_id      IN             NUMBER,
               x_return_status       IN  OUT NOCOPY VARCHAR2
             ) IS

   CURSOR c_charge_lines IS
   SELECT charge_line_id
   FROM   inl_charge_lines cl
   WHERE  cl.party_id = p_from_fk_id
   AND    cl.ship_from_party_id is null
   AND    cl.bill_from_party_id is null
   AND    cl.poa_party_id is null;

  TYPE id_tbl_type is TABLE of NUMBER INDEX BY BINARY_INTEGER;
  l_charge_line_list     id_tbl_type;
  l_proc_name            CONSTANT VARCHAR2 (30) := 'Merge_Parties';
  l_debug_info           VARCHAR2(200);
  l_return_status        VARCHAR2(1);

BEGIN
  --{
  -- Standard Beginning of Procedure/Function Logging
  INL_LOGGING_PVT.Log_BeginProc ( p_module_name => g_module_name,
                                  p_procedure_name => l_proc_name);

  -- Standard Start of API savepoint
  SAVEPOINT Merge_Parties_GRP;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --

  -- Logging variables
  INL_LOGGING_PVT.Log_Variable ( p_module_name => g_module_name,
                                 p_procedure_name => l_proc_name,
                                 p_var_name => 'p_entity_name',
                                 p_var_value => p_entity_name);
  INL_LOGGING_PVT.Log_Variable ( p_module_name => g_module_name,
                                 p_procedure_name => l_proc_name,
                                 p_var_name => 'p_from_id',
                                 p_var_value => p_from_id);
  INL_LOGGING_PVT.Log_Variable ( p_module_name => g_module_name,
                                 p_procedure_name => l_proc_name,
                                 p_var_name => 'p_to_id',
                                 p_var_value => p_to_id);
  INL_LOGGING_PVT.Log_Variable ( p_module_name => g_module_name,
                                 p_procedure_name => l_proc_name,
                                 p_var_name => 'p_from_fk_id',
                                 p_var_value => p_from_fk_id);
  INL_LOGGING_PVT.Log_Variable ( p_module_name => g_module_name,
                                 p_procedure_name => l_proc_name,
                                 p_var_name => 'p_to_fk_id',
                                 p_var_value => p_to_fk_id);
  INL_LOGGING_PVT.Log_Variable ( p_module_name => g_module_name,
                                 p_procedure_name => l_proc_name,
                                 p_var_name => 'p_parent_entity_name',
                                 p_var_value => p_parent_entity_name);
  INL_LOGGING_PVT.Log_Variable ( p_module_name => g_module_name,
                                 p_procedure_name => l_proc_name,
                                 p_var_name => 'p_batch_id',
                                 p_var_value => p_batch_id);
  INL_LOGGING_PVT.Log_Variable ( p_module_name => g_module_name,
                                 p_procedure_name => l_proc_name,
                                 p_var_name => 'p_batch_party_id',
                                 p_var_value => p_batch_party_id);

  --{
  OPEN  c_charge_lines;
  FETCH c_charge_lines BULK COLLECT INTO l_charge_line_list;
  CLOSE c_charge_lines;

  l_debug_info := 'Count of Rows fetched from Cursor C_CHARGE_LINES  = ' || l_charge_line_list.count;
  INL_LOGGING_PVT.Log_Statement ( p_module_name => g_module_name,
                                  p_procedure_name => l_proc_name,
                                  p_debug_info => l_debug_info) ;

  IF l_charge_line_list.COUNT > 0 THEN
          --
          FORALL j IN l_charge_line_list.FIRST..l_charge_line_list.LAST
                  UPDATE inl_charge_lines
                  SET party_id                = p_to_fk_id,
                      last_update_date        = sysdate,
                      last_updated_by         = fnd_global.user_id,
                      last_update_login       = fnd_global.login_id
                  WHERE charge_line_id        = l_charge_line_list(j);

           l_debug_info := 'Updated inl_charges. Number of Rows updated is ' || sql%rowcount;
           INL_LOGGING_PVT.Log_Statement ( p_module_name => g_module_name,
                                           p_procedure_name => l_proc_name,
                                           p_debug_info => l_debug_info) ;
  END IF;
  --}

  l_debug_info := 'x_return_status '||x_return_status;
  INL_LOGGING_PVT.Log_Statement ( p_module_name => g_module_name,
                                  p_procedure_name => l_proc_name,
                                  p_debug_info => l_debug_info) ;

  -- Standard End of Procedure/Function Logging
  INL_LOGGING_PVT.Log_EndProc ( p_module_name => g_module_name,
                                p_procedure_name => l_proc_name) ;

  --}
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError (p_module_name    => g_module_name,
                                    p_procedure_name => l_proc_name);
    ROLLBACK TO Merge_Parties_GRP;
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                      p_procedure_name => l_proc_name);
    ROLLBACK TO Merge_Parties_GRP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                      p_procedure_name => l_proc_name);
    ROLLBACK TO Merge_Parties_GRP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,l_proc_name);
    END IF;
END Merge_Parties;

--========================================================================
-- PROCEDURE :Merge_PartySites
-- PARAMETERS:
--            p_entity_name                   Name of Entity Being Merged
--            p_from_id                       Primary Key Id of the entity that is being merged
--            p_to_id                         The record under the 'To Parent' that is being merged
--            p_from_fk_id                    Foreign Key id of the Old Parent Record
--            p_to_fk_id                      Foreign  Key id of the New Parent Record
--            p_parent_entity_name            Name of Parent Entity
--            p_batch_id                      Id of the Batch
--            p_batch_party_id                Id uniquely identifies the batch and party record that is being merged
--            x_return_status                 Returns the status of call
--
-- COMMENT   :
--
--
--========================================================================

PROCEDURE Merge_PartySites
             ( p_entity_name         IN             VARCHAR2,
               p_from_id             IN             NUMBER,
               p_to_id               IN  OUT NOCOPY NUMBER,
               p_from_fk_id          IN             NUMBER,
               p_to_fk_id            IN             NUMBER,
               p_parent_entity_name  IN             VARCHAR2,
               p_batch_id            IN             NUMBER,
               p_batch_party_id      IN             NUMBER,
               x_return_status       IN  OUT NOCOPY VARCHAR2
             ) IS

   CURSOR c_charge_lines IS
   SELECT charge_line_id
   FROM   inl_charge_lines cl
   WHERE  cl.party_site_id = p_from_fk_id
   AND    cl.ship_from_party_site_id is null
   AND    cl.bill_from_party_site_id is null
   AND    cl.poa_party_site_id is null;

  TYPE id_tbl_type is TABLE of NUMBER INDEX BY BINARY_INTEGER;
  l_charge_line_list     id_tbl_type;
  l_proc_name            CONSTANT VARCHAR2 (30) := 'Merge_PartySites';
  l_debug_info           VARCHAR2(200);
  l_return_status        VARCHAR2(1);

BEGIN
  --{

  -- Standard Beginning of Procedure/Function Logging
  INL_LOGGING_PVT.Log_BeginProc ( p_module_name => g_module_name,
                                  p_procedure_name => l_proc_name);

  -- Standard Start of API savepoint
  SAVEPOINT Merge_PartySites_GRP;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Logging variables
  INL_LOGGING_PVT.Log_Variable ( p_module_name => g_module_name,
                                 p_procedure_name => l_proc_name,
                                 p_var_name => 'p_entity_name',
                                 p_var_value => p_entity_name);
  INL_LOGGING_PVT.Log_Variable ( p_module_name => g_module_name,
                                 p_procedure_name => l_proc_name,
                                 p_var_name => 'p_from_id',
                                 p_var_value => p_from_id);
  INL_LOGGING_PVT.Log_Variable ( p_module_name => g_module_name,
                                 p_procedure_name => l_proc_name,
                                 p_var_name => 'p_to_id',
                                 p_var_value => p_to_id);
  INL_LOGGING_PVT.Log_Variable ( p_module_name => g_module_name,
                                 p_procedure_name => l_proc_name,
                                 p_var_name => 'p_from_fk_id',
                                 p_var_value => p_from_fk_id);
  INL_LOGGING_PVT.Log_Variable ( p_module_name => g_module_name,
                                 p_procedure_name => l_proc_name,
                                 p_var_name => 'p_to_fk_id',
                                 p_var_value => p_to_fk_id);
  INL_LOGGING_PVT.Log_Variable ( p_module_name => g_module_name,
                                 p_procedure_name => l_proc_name,
                                 p_var_name => 'p_parent_entity_name',
                                 p_var_value => p_parent_entity_name);
  INL_LOGGING_PVT.Log_Variable ( p_module_name => g_module_name,
                                 p_procedure_name => l_proc_name,
                                 p_var_name => 'p_batch_id',
                                 p_var_value => p_batch_id);
  INL_LOGGING_PVT.Log_Variable ( p_module_name => g_module_name,
                                 p_procedure_name => l_proc_name,
                                 p_var_name => 'p_batch_party_id',
                                 p_var_value => p_batch_party_id);

  --{
  OPEN  c_charge_lines;
  FETCH c_charge_lines BULK COLLECT INTO l_charge_line_list;
  CLOSE c_charge_lines;

  l_debug_info := 'Count of Rows fetched from Cursor C_CHARGE_LINES  = ' || l_charge_line_list.count;
  INL_LOGGING_PVT.Log_Statement ( p_module_name => g_module_name,
                                  p_procedure_name => l_proc_name,
                                  p_debug_info => l_debug_info) ;

  IF l_charge_line_list.COUNT > 0 THEN
          --
          FORALL j IN l_charge_line_list.FIRST..l_charge_line_list.LAST
                  UPDATE inl_charge_lines
                  SET party_site_id           = p_to_fk_id,
                      last_update_date        = sysdate,
                      last_updated_by         = fnd_global.user_id,
                      last_update_login       = fnd_global.login_id
                  WHERE charge_line_id        = l_charge_line_list(j);

           l_debug_info := 'Updated inl_charges. Number of Rows updated is ' || sql%rowcount;
           INL_LOGGING_PVT.Log_Statement ( p_module_name => g_module_name,
                                           p_procedure_name => l_proc_name,
                                           p_debug_info => l_debug_info) ;
  END IF;
  --}

  l_debug_info := 'x_return_status '||x_return_status;
  INL_LOGGING_PVT.Log_Statement ( p_module_name => g_module_name,
                                  p_procedure_name => l_proc_name,
                                  p_debug_info => l_debug_info) ;

  -- Standard End of Procedure/Function Logging
  INL_LOGGING_PVT.Log_EndProc ( p_module_name => g_module_name,
                                p_procedure_name => l_proc_name) ;

  --}
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    -- Standard Expected Error Logging
    INL_LOGGING_PVT.Log_ExpecError (p_module_name    => g_module_name,
                                    p_procedure_name => l_proc_name);
    ROLLBACK TO Merge_PartySites_GRP;
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                      p_procedure_name => l_proc_name);
    ROLLBACK TO Merge_PartySites_GRP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError (p_module_name    => g_module_name,
                                      p_procedure_name => l_proc_name);
    ROLLBACK TO Merge_PartySites_GRP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,l_proc_name);
    END IF;

END Merge_PartySites;

END INL_TCAMERGE_GRP;

/
