--------------------------------------------------------
--  DDL for Package Body CSD_REPAIR_ACTUAL_LINES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_REPAIR_ACTUAL_LINES_PVT" as
/* $Header: csdvalnb.pls 120.6 2008/05/20 22:44:19 swai ship $ */


--G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSD_REPAIR_ACTUAL_LINES_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csdvclnb.pls';

-- Global variable for storing the debug level
G_debug_level number   := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

/*--------------------------------------------------------------------*/
/* procedure name: CREATE_REPAIR_ACTUAL_LINES                         */
/* description : procedure used to Create Repair Actuals              */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/* Called from : Depot Repair Actuals UI                              */
/* Input Parm  :                                                      */
/*   p_api_version       NUMBER    Req Api Version number             */
/*   p_init_msg_list     VARCHAR2  Opt Initialize message stack       */
/*   p_commit            VARCHAR2  Opt Commits in API                 */
/*   p_validation_level  NUMBER    Opt validation steps               */
/*   px_CSD_ACTUAL_LINES_REC REC   Req Actuals lines Record           */
/*   px_Charges_Rec          REC   Req Charges line Record            */
/* Output Parm :                                                      */
/*   x_return_status     VARCHAR2      Return status after the call.  */
/*   x_msg_count         NUMBER        Number of messages in stack    */
/*   x_msg_data          VARCHAR2      Mesg. text if x_msg_count >= 1 */
/* Change Hist :                                                      */
/*   08/11/03  travikan  Initial Creation.                            */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
PROCEDURE CREATE_REPAIR_ACTUAL_LINES(
    P_Api_Version           IN            NUMBER,
    P_Commit                IN            VARCHAR2,
    P_Init_Msg_List         IN            VARCHAR2,
    p_validation_level      IN            NUMBER,
    px_CSD_ACTUAL_LINES_REC IN OUT NOCOPY CSD_ACTUAL_LINES_REC_TYPE,
    px_CHARGES_REC          IN OUT NOCOPY CS_CHARGE_DETAILS_PUB.CHARGES_REC_TYPE,
    X_Return_Status         OUT    NOCOPY VARCHAR2,
    X_Msg_Count             OUT    NOCOPY NUMBER,
    X_Msg_Data              OUT    NOCOPY VARCHAR2
    )

 IS
     -- Variables used in FND Log
     l_stat_level   number   := FND_LOG.LEVEL_STATEMENT;
     l_proc_level   number   := FND_LOG.LEVEL_PROCEDURE;
     l_event_level  number   := FND_LOG.LEVEL_EVENT;
     l_excep_level  number   := FND_LOG.LEVEL_EXCEPTION;
     l_error_level  number   := FND_LOG.LEVEL_ERROR;
     l_unexp_level  number   := FND_LOG.LEVEL_UNEXPECTED;
     l_mod_name     varchar2(2000) := 'csd.plsql.csd_repair_actual_lines_pvt.create_repair_actual_lines';

     l_api_name               CONSTANT VARCHAR2(30)   := 'CREATE_REPAIR_ACTUAL_LINES';
     l_api_version            CONSTANT NUMBER         := 1.0;
     l_msg_count              NUMBER;
     l_msg_data               VARCHAR2(100);
     l_msg_index              NUMBER;

     l_api_return_status      VARCHAR2(3);
     l_act_count              NUMBER;
     lx_csd_actuals_rec       CSD_REPAIR_ACTUALS_PVT.CSD_REPAIR_ACTUALS_REC_TYPE;
     lx_charges_rec           CS_CHARGE_DETAILS_PUB.CHARGES_REC_TYPE;

     x_actual_header_id       NUMBER := NULL;

     l_serial_flag            BOOLEAN := FALSE;
     l_dummy                  VARCHAR2(1);

     x_estimate_detail_id     NUMBER := NULL;
     l_act_hdr                NUMBER := NULL;
     l_reference_number       VARCHAR2(30) := '';
     l_contract_number        VARCHAR2(30) := '';
     l_bus_process_id         NUMBER := NULL;
     l_repair_type_ref        VARCHAR2(3) := '';
     l_line_type_id           NUMBER := NULL;
     l_txn_billing_type_id    NUMBER := NULL;
     l_party_id               NUMBER := NULL;
     l_account_id             NUMBER := NULL;
     l_order_header_id        NUMBER := NULL;
     l_release_status         VARCHAR2(10) := '';
     l_curr_code              VARCHAR2(10) := '';
     l_line_category_code     VARCHAR2(30) := '';
     l_ship_from_org_id       NUMBER := NULL;
     l_order_line_id          NUMBER := NULL;
     l_unit_selling_price     NUMBER := NULL;
     l_item_cost              NUMBER := NULL;

      -- swai: 12.1 service costing uptake bug 6960295
      l_cs_cost_flag   VARCHAR2(1) := 'Y';

     -- passing in from form
     -- l_coverage_id            NUMBER := NULL;
     -- l_coverage_name          VARCHAR2(30) := '';
     -- l_txn_group_id           NUMBER := NULL;
     --

     CURSOR order_rec(p_incident_id IN NUMBER) IS
     SELECT customer_id,
            account_id
       FROM cs_incidents_all_b
      WHERE incident_id  = p_incident_id;

    BEGIN

          -- Standard Start of API savepoint
          SAVEPOINT CREATE_REPAIR_ACTUAL_LINES;

          -- Standard call to check for call compatibility.
          IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                               p_api_version,
                                               l_api_name,
                                               G_PKG_NAME)
          THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

           -- Initialize message list if p_init_msg_list is set to TRUE.
           IF FND_API.to_Boolean( p_init_msg_list ) THEN
               FND_MSG_PUB.initialize;
           END IF;

           -- Initialize API return status to success
           x_return_status := FND_API.G_RET_STS_SUCCESS;

           -- Api body starts
           IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'At the Beginning of create_repair_actual_lines');
           END IF;

           -- Dump the in parameters in the log file
           -- if the debug level > 5
           -- If fnd_profile.value('CSD_DEBUG_LEVEL') > 5 then
--         if (g_debug > 5) then
--               csd_gen_utility_pvt.dump_actual_lines_rec
--                        ( p_CSD_ACTUAL_LINES_REC => px_CSD_ACTUAL_LINES_REC);
--         end if;

           IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Begin Check reqd parameter Repair Line ID : '||px_CSD_ACTUAL_LINES_REC.repair_line_id);
           END IF;

           -- Check the required parameter
           CSD_PROCESS_UTIL.Check_Reqd_Param
           ( p_param_value    => px_CSD_ACTUAL_LINES_REC.repair_line_id,
             p_param_name     => 'REPAIR_LINE_ID',
             p_api_name       => l_api_name);

           IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'End Check reqd parameter');
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Begin Validate Repair Line id');
           END IF;

           -- Validate the repair line ID
           IF NOT( CSD_PROCESS_UTIL.Validate_rep_line_id
                           ( p_repair_line_id  => px_CSD_ACTUAL_LINES_REC.repair_line_id )) THEN
               RAISE FND_API.G_EXC_ERROR;
           END IF;

           IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'End Validate Repair Line id');
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Check if there is only one Actual Header per Repair Order');
           END IF;

           -- Begin check Actuals Header is null
           IF (px_CSD_ACTUAL_LINES_REC.repair_actual_id is null) then

               Begin
                 -- initialize
                 l_act_count := -1;

                 select count(*)
                   into l_act_count
                   from csd_repair_actuals
                  where repair_line_id = px_CSD_ACTUAL_LINES_REC.repair_line_id;
               Exception
               when others then
                  IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                      FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'Others exception error :'||SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1,255));
                  END IF;

               End;

               -- Begin check Actuals Header call
               IF l_act_count = 0 then
                  IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                       FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Actuals do not exists for the repair line Id: '||px_CSD_ACTUAL_LINES_REC.repair_line_id);
                  END IF;

                  -- Create Actual Header
                  -- Assign values to actuals header record
                  lx_csd_actuals_rec.REPAIR_ACTUAL_ID      := NULL;
                  lx_csd_actuals_rec.OBJECT_VERSION_NUMBER := NULL;
                  lx_csd_actuals_rec.REPAIR_LINE_ID        := px_CSD_ACTUAL_LINES_REC.repair_line_id;
                  lx_csd_actuals_rec.CREATED_BY            := NULL;
                  lx_csd_actuals_rec.CREATION_DATE         := NULL;
                  lx_csd_actuals_rec.LAST_UPDATED_BY       := NULL;
                  lx_csd_actuals_rec.LAST_UPDATE_DATE      := NULL;
                  lx_csd_actuals_rec.LAST_UPDATE_LOGIN     := NULL;
                  lx_csd_actuals_rec.ATTRIBUTE_CATEGORY    := NULL;
                  lx_csd_actuals_rec.ATTRIBUTE1            := NULL;
                  lx_csd_actuals_rec.ATTRIBUTE2            := NULL;
                  lx_csd_actuals_rec.ATTRIBUTE3            := NULL;
                  lx_csd_actuals_rec.ATTRIBUTE4            := NULL;
                  lx_csd_actuals_rec.ATTRIBUTE5            := NULL;
                  lx_csd_actuals_rec.ATTRIBUTE6            := NULL;
                  lx_csd_actuals_rec.ATTRIBUTE7            := NULL;
                  lx_csd_actuals_rec.ATTRIBUTE8            := NULL;
                  lx_csd_actuals_rec.ATTRIBUTE9            := NULL;
                  lx_csd_actuals_rec.ATTRIBUTE10           := NULL;
                  lx_csd_actuals_rec.ATTRIBUTE11           := NULL;
                  lx_csd_actuals_rec.ATTRIBUTE12           := NULL;
                  lx_csd_actuals_rec.ATTRIBUTE13           := NULL;
                  lx_csd_actuals_rec.ATTRIBUTE14           := NULL;
                  lx_csd_actuals_rec.ATTRIBUTE15           := NULL;
                  lx_csd_actuals_rec.BILL_TO_ACCOUNT_ID     := NULL;
                  lx_csd_actuals_rec.BILL_TO_PARTY_ID       := NULL;
                  lx_csd_actuals_rec.BILL_TO_PARTY_SITE_ID  := NULL;


                  IF ( Fnd_Log.Level_Procedure >= G_debug_level) THEN
                       FND_LOG.STRING(Fnd_Log.Level_Procedure,l_mod_name,'Calling csd_repair_actuals_pvt.create_repair_actuals');
                  END IF;

                  -- call API to create Repair Actuals header
                  csd_repair_actuals_pvt.create_repair_actuals
                            ( P_Api_Version             => 1.0,
                              P_Commit                  => 'F',
                              P_Init_Msg_List           => 'T',
                              p_validation_level        => 10,
                              px_CSD_REPAIR_ACTUALS_REC => lx_csd_actuals_rec,
                              X_Return_Status           => x_return_status,
                              X_Msg_Count               => x_msg_count,
                              X_Msg_Data                => x_msg_data);

                  IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                      IF ( Fnd_Log.Level_Procedure >= G_debug_level) THEN
                           FND_LOG.STRING(Fnd_Log.Level_Procedure,l_mod_name,'csd_repair_actuals_pvt.create_repair_actuals failed');
                      END IF;
                      RAISE FND_API.G_EXC_ERROR;
                  END IF;

                  -- assign the created actuals header to actual lines record
                  px_CSD_ACTUAL_LINES_REC.repair_actual_id := lx_csd_actuals_rec.REPAIR_ACTUAL_ID;

                  IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                       FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Actuals do not exists for the repair line Id: '||lx_csd_actuals_rec.REPAIR_ACTUAL_ID);
                  END IF;

               ELSIF (l_act_count = 1) then
                    -- special cases
                    IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                       FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Actual Header was not passed in.  Retrieving it..');
                    END IF;
                    Begin
                     -- initialize
                     l_act_hdr := -1;

                     select repair_actual_id
                       into l_act_hdr
                       from csd_repair_actuals
                      where repair_line_id = px_CSD_ACTUAL_LINES_REC.repair_line_id;
                    Exception
                      when others then
                          IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                              FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'Others exception error :'||SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1,255));
                          END IF;
                    End;

                    -- assign the repair actual header id
                    px_CSD_ACTUAL_LINES_REC.REPAIR_ACTUAL_ID := l_act_hdr;

                    IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                        FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Actuals header: '||l_act_hdr||'already exists for the repair line Id: '||px_CSD_ACTUAL_LINES_REC.repair_line_id);
                    END IF;

               ELSIF l_act_count > 1 then
                  IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                       FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Multiple Actuals exists for the repair line Id: '||px_CSD_ACTUAL_LINES_REC.repair_line_id);
                  END IF;

                  FND_MESSAGE.SET_NAME('CSD','CSD_API_ACTUALS_EXISTS');
                  FND_MESSAGE.SET_TOKEN('REPAIR_LINE_ID',px_CSD_ACTUAL_LINES_REC.repair_line_id);
                  FND_MSG_PUB.ADD;
                  IF (Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level) THEN
                    FND_LOG.MESSAGE(Fnd_Log.Level_Error,l_mod_name, FALSE);
                  END IF;
                  RAISE FND_API.G_EXC_ERROR;
               End IF;
               -- End check Actuals Header call

           END IF;
           -- End check Actuals Header is null

           -- Assigning object version number
           px_CSD_ACTUAL_LINES_REC.OBJECT_VERSION_NUMBER := 1;

           -- --------------------------------------------------------------------
           -- Check if the Repair_Actual_Lines_Rec.actual_source_code = ESTIMATE
           -- --------------------------------------------------------------------
           IF (px_CSD_ACTUAL_LINES_REC.actual_source_code = 'ESTIMATE' ) THEN

               -- Copy from Estimate API will create a Charge line in the table by
               -- Calling charges API copy actual from estimate to create the record
               -- in CS_ESTIMATE_DETAILS and will send in estimate_detail_id
               -- which is the estimate_detail_id of the Actual line

               -- Raise FND_API.G_EXC_ERROR if the estimate_detail_id is null
               IF (px_CSD_ACTUAL_LINES_REC.ESTIMATE_DETAIL_ID is null) THEN
                   IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                        FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Missing estimate_detail_id for actual_source_code : '||px_CSD_ACTUAL_LINES_REC.actual_source_code);
                   END IF;

                   RAISE FND_API.G_EXC_ERROR;
               END IF;

               --
               -- API body
               --
               IF ( Fnd_Log.Level_Procedure >= G_debug_level) THEN
                    FND_LOG.STRING(Fnd_Log.Level_Procedure,l_mod_name,'Call to  CSD_REPAIR_ACTUAL_LINES_REC_PKG.Insert_Row');
               END IF;

               IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                    FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Required columns: ');
                    FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'REPAIR_ACTUAL_LINE_ID (must be null) = ' || px_CSD_ACTUAL_LINES_REC.REPAIR_ACTUAL_LINE_ID);
                    FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'OBJECT_VERSION_NUMBER = ' || px_CSD_ACTUAL_LINES_REC.OBJECT_VERSION_NUMBER);
                    FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'ESTIMATE_DETAIL_ID = ' || px_CSD_ACTUAL_LINES_REC.ESTIMATE_DETAIL_ID);
                    FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'REPAIR_ACTUAL_ID = ' || px_CSD_ACTUAL_LINES_REC.REPAIR_ACTUAL_ID);
                    FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'REPAIR_LINE_ID = ' || px_CSD_ACTUAL_LINES_REC.REPAIR_LINE_ID);
                    FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'CREATED_BY = ' || FND_GLOBAL.USER_ID);
                    FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'LAST_UPDATED_BY = '|| FND_GLOBAL.USER_ID);
               END IF;

               BEGIN
                    -- Call table handler CSD_REPAIR_ACTUALS_LINES_PKG.Insert_Row to
                    -- insert the record into CSD_REPAIR_ACTUAL_LINES
                    -- Invoke table handler(CSD_REPAIR_ACTUAL_LINES_PKG.Insert_Row)
                    CSD_REPAIR_ACTUAL_LINES_PKG.Insert_Row(
                           px_REPAIR_ACTUAL_LINE_ID  => px_CSD_ACTUAL_LINES_REC.REPAIR_ACTUAL_LINE_ID
                          ,p_OBJECT_VERSION_NUMBER   => px_CSD_ACTUAL_LINES_REC.OBJECT_VERSION_NUMBER
                          ,p_ESTIMATE_DETAIL_ID      => px_CSD_ACTUAL_LINES_REC.ESTIMATE_DETAIL_ID
                          ,p_REPAIR_ACTUAL_ID        => px_CSD_ACTUAL_LINES_REC.REPAIR_ACTUAL_ID
                          ,p_REPAIR_LINE_ID          => px_CSD_ACTUAL_LINES_REC.REPAIR_LINE_ID
                          ,p_CREATED_BY              => FND_GLOBAL.USER_ID
                          ,p_CREATION_DATE           => SYSDATE
                          ,p_LAST_UPDATED_BY         => FND_GLOBAL.USER_ID
                          ,p_LAST_UPDATE_DATE        => SYSDATE
                          ,p_LAST_UPDATE_LOGIN       => FND_GLOBAL.CONC_LOGIN_ID
                          ,p_ITEM_COST               => px_CSD_ACTUAL_LINES_REC.ITEM_COST
                          ,p_JUSTIFICATION_NOTES     => px_CSD_ACTUAL_LINES_REC.JUSTIFICATION_NOTES
                          ,p_RESOURCE_ID             => px_CSD_ACTUAL_LINES_REC.RESOURCE_ID
                          ,p_OVERRIDE_CHARGE_FLAG    => px_CSD_ACTUAL_LINES_REC.OVERRIDE_CHARGE_FLAG
                          ,p_ACTUAL_SOURCE_CODE      => px_CSD_ACTUAL_LINES_REC.ACTUAL_SOURCE_CODE
                          ,p_ACTUAL_SOURCE_ID        => px_CSD_ACTUAL_LINES_REC.ACTUAL_SOURCE_ID
                          ,p_WARRANTY_CLAIM_FLAG     => px_CSD_ACTUAL_LINES_REC.WARRANTY_CLAIM_FLAG
                          ,p_WARRANTY_NUMBER         => px_CSD_ACTUAL_LINES_REC.WARRANTY_NUMBER
                          ,p_WARRANTY_STATUS_CODE    => px_CSD_ACTUAL_LINES_REC.WARRANTY_STATUS_CODE
                          ,p_REPLACED_ITEM_ID        => px_CSD_ACTUAL_LINES_REC.REPLACED_ITEM_ID
                          ,p_ATTRIBUTE_CATEGORY      => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE_CATEGORY
                          ,p_ATTRIBUTE1              => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE1
                          ,p_ATTRIBUTE2              => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE2
                          ,p_ATTRIBUTE3              => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE3
                          ,p_ATTRIBUTE4              => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE4
                          ,p_ATTRIBUTE5              => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE5
                          ,p_ATTRIBUTE6              => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE6
                          ,p_ATTRIBUTE7              => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE7
                          ,p_ATTRIBUTE8              => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE8
                          ,p_ATTRIBUTE9              => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE9
                          ,p_ATTRIBUTE10             => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE10
                          ,p_ATTRIBUTE11             => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE11
                          ,p_ATTRIBUTE12             => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE12
                          ,p_ATTRIBUTE13             => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE13
                          ,p_ATTRIBUTE14             => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE14
                          ,p_ATTRIBUTE15             => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE15
                          ,p_LOCATOR_ID              => px_CSD_ACTUAL_LINES_REC.LOCATOR_ID
                          ,p_LOC_SEGMENT1            => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT1
                          ,p_LOC_SEGMENT2            => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT2
                          ,p_LOC_SEGMENT3            => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT3
                          ,p_LOC_SEGMENT4            => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT4
                          ,p_LOC_SEGMENT5            => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT5
                          ,p_LOC_SEGMENT6            => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT6
                          ,p_LOC_SEGMENT7            => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT7
                          ,p_LOC_SEGMENT8            => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT8
                          ,p_LOC_SEGMENT9            => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT9
                          ,p_LOC_SEGMENT10           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT10
                          ,p_LOC_SEGMENT11           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT11
                          ,p_LOC_SEGMENT12           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT12
                          ,p_LOC_SEGMENT13           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT13
                          ,p_LOC_SEGMENT14           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT14
                          ,p_LOC_SEGMENT15           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT15
                          ,p_LOC_SEGMENT16           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT16
                          ,p_LOC_SEGMENT17           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT17
                          ,p_LOC_SEGMENT18           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT18
                          ,p_LOC_SEGMENT19           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT19
                          ,p_LOC_SEGMENT20           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT20);

                   IF ( Fnd_Log.Level_Procedure >= G_debug_level) THEN
                        FND_LOG.STRING(Fnd_Log.Level_Procedure,l_mod_name,'Returned from CSD_REPAIR_ACTUAL_LINES_REC_PKG.Insert_Row');
                   END IF;

               EXCEPTION
                  WHEN OTHERS THEN
                     IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                         FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'Others exception in CSD_REPAIR_ACTUAL_LINES_PKG.Insert_Row Call :'||SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1,255));
                     END IF;
                     x_return_status := FND_API.G_RET_STS_ERROR;
               END;

               IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   RAISE FND_API.G_EXC_ERROR;
               END IF;

               --
               -- End of API body
               --
           -- --------------------------------------------------------------------
           -- Check if the Repair_Actual_Lines_Rec.actual_source_code = TASK
           -- --------------------------------------------------------------------
           ELSIF (px_CSD_ACTUAL_LINES_REC.actual_source_code = 'TASK' ) THEN

               -- Debrief would have created a Charge line in the cs_estimate_details table
               -- which is the estimate_detail_id of the Actual line
               -- we link the Debrief createsd charge line to our Actual Line

               -- Raise FND_API.G_EXC_ERROR if the estimate_detail_id is null
               IF (px_CSD_ACTUAL_LINES_REC.ESTIMATE_DETAIL_ID is null) THEN
                   IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                       FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Missing estimate_detail_id for actual_source_code : '||px_CSD_ACTUAL_LINES_REC.actual_source_code);
                   END IF;
                   RAISE FND_API.G_EXC_ERROR;
               END IF;

               --
               -- API body
               --
               IF ( Fnd_Log.Level_Procedure >= G_debug_level) THEN
                    FND_LOG.STRING(Fnd_Log.Level_Procedure,l_mod_name,'Call to  CSD_REPAIR_ACTUAL_LINES_REC_PKG.Insert_Row');
               END IF;

               IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                    FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Required columns: ');
                    FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,' ');
                    FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'OBJECT_VERSION_NUMBER = ' || px_CSD_ACTUAL_LINES_REC.OBJECT_VERSION_NUMBER);
                    FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'ESTIMATE_DETAIL_ID = ' || px_CSD_ACTUAL_LINES_REC.ESTIMATE_DETAIL_ID);
                    FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'REPAIR_ACTUAL_ID = ' || px_CSD_ACTUAL_LINES_REC.REPAIR_ACTUAL_ID);
                    FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'REPAIR_LINE_ID = ' || px_CSD_ACTUAL_LINES_REC.REPAIR_LINE_ID);
                    FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'CREATED_BY = ' || FND_GLOBAL.USER_ID);
                    FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'LAST_UPDATED_BY = '|| FND_GLOBAL.USER_ID);
               END IF;

               BEGIN
                    -- Call table handler CSD_REPAIR_ACTUALS_LINES_PKG.Insert_Row to
                    -- insert the record into CSD_REPAIR_ACTUAL_LINES
                    -- Invoke table handler(CSD_REPAIR_ACTUAL_LINES_PKG.Insert_Row)
                    CSD_REPAIR_ACTUAL_LINES_PKG.Insert_Row(
                          px_REPAIR_ACTUAL_LINE_ID  => px_CSD_ACTUAL_LINES_REC.REPAIR_ACTUAL_LINE_ID
                          ,p_OBJECT_VERSION_NUMBER   => px_CSD_ACTUAL_LINES_REC.OBJECT_VERSION_NUMBER
                          ,p_ESTIMATE_DETAIL_ID      => px_CSD_ACTUAL_LINES_REC.ESTIMATE_DETAIL_ID
                          ,p_REPAIR_ACTUAL_ID        => px_CSD_ACTUAL_LINES_REC.REPAIR_ACTUAL_ID
                          ,p_REPAIR_LINE_ID          => px_CSD_ACTUAL_LINES_REC.REPAIR_LINE_ID
                          ,p_CREATED_BY              => FND_GLOBAL.USER_ID
                          ,p_CREATION_DATE           => SYSDATE
                          ,p_LAST_UPDATED_BY         => FND_GLOBAL.USER_ID
                          ,p_LAST_UPDATE_DATE        => SYSDATE
                          ,p_LAST_UPDATE_LOGIN       => FND_GLOBAL.CONC_LOGIN_ID
                          ,p_ITEM_COST               => px_CSD_ACTUAL_LINES_REC.ITEM_COST
                          ,p_JUSTIFICATION_NOTES     => px_CSD_ACTUAL_LINES_REC.JUSTIFICATION_NOTES
                          ,p_RESOURCE_ID             => px_CSD_ACTUAL_LINES_REC.RESOURCE_ID
                          ,p_OVERRIDE_CHARGE_FLAG    => px_CSD_ACTUAL_LINES_REC.OVERRIDE_CHARGE_FLAG
                          ,p_ACTUAL_SOURCE_CODE      => px_CSD_ACTUAL_LINES_REC.ACTUAL_SOURCE_CODE
                          ,p_ACTUAL_SOURCE_ID        => px_CSD_ACTUAL_LINES_REC.ACTUAL_SOURCE_ID
                          ,p_WARRANTY_CLAIM_FLAG     => px_CSD_ACTUAL_LINES_REC.WARRANTY_CLAIM_FLAG
                          ,p_WARRANTY_NUMBER         => px_CSD_ACTUAL_LINES_REC.WARRANTY_NUMBER
                          ,p_WARRANTY_STATUS_CODE    => px_CSD_ACTUAL_LINES_REC.WARRANTY_STATUS_CODE
                          ,p_REPLACED_ITEM_ID        => px_CSD_ACTUAL_LINES_REC.REPLACED_ITEM_ID
                          ,p_ATTRIBUTE_CATEGORY      => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE_CATEGORY
                          ,p_ATTRIBUTE1              => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE1
                          ,p_ATTRIBUTE2              => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE2
                          ,p_ATTRIBUTE3              => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE3
                          ,p_ATTRIBUTE4              => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE4
                          ,p_ATTRIBUTE5              => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE5
                          ,p_ATTRIBUTE6              => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE6
                          ,p_ATTRIBUTE7              => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE7
                          ,p_ATTRIBUTE8              => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE8
                          ,p_ATTRIBUTE9              => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE9
                          ,p_ATTRIBUTE10             => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE10
                          ,p_ATTRIBUTE11             => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE11
                          ,p_ATTRIBUTE12             => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE12
                          ,p_ATTRIBUTE13             => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE13
                          ,p_ATTRIBUTE14             => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE14
                          ,p_ATTRIBUTE15             => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE15
                          ,p_LOCATOR_ID              => px_CSD_ACTUAL_LINES_REC.LOCATOR_ID
                          ,p_LOC_SEGMENT1            => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT1
                          ,p_LOC_SEGMENT2            => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT2
                          ,p_LOC_SEGMENT3            => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT3
                          ,p_LOC_SEGMENT4            => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT4
                          ,p_LOC_SEGMENT5            => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT5
                          ,p_LOC_SEGMENT6            => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT6
                          ,p_LOC_SEGMENT7            => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT7
                          ,p_LOC_SEGMENT8            => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT8
                          ,p_LOC_SEGMENT9            => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT9
                          ,p_LOC_SEGMENT10           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT10
                          ,p_LOC_SEGMENT11           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT11
                          ,p_LOC_SEGMENT12           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT12
                          ,p_LOC_SEGMENT13           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT13
                          ,p_LOC_SEGMENT14           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT14
                          ,p_LOC_SEGMENT15           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT15
                          ,p_LOC_SEGMENT16           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT16
                          ,p_LOC_SEGMENT17           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT17
                          ,p_LOC_SEGMENT18           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT18
                          ,p_LOC_SEGMENT19           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT19
                          ,p_LOC_SEGMENT20           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT20);


               EXCEPTION
                  WHEN OTHERS THEN
                     IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                         FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'Others exception in CSD_REPAIR_ACTUAL_LINES_PKG.Insert_Row Call :'||SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1,255));
                     END IF;
                     x_return_status := FND_API.G_RET_STS_ERROR;
               END;

               IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   RAISE FND_API.G_EXC_ERROR;
               END IF;

               --
               -- End of API body
               --
           -- ---------------------------------------------------------------------------
           -- Check if the Repair_Actual_Lines_Rec.actual_source_code are WIP or MANUAL
           -- ---------------------------------------------------------------------------
           ELSIF (px_CSD_ACTUAL_LINES_REC.actual_source_code in ('WIP','MANUAL') ) THEN
             -- swai: 12.1 service costing uptake bug 6960295
             -- If importing from wip, do not cost the line again when importing
             -- Otherwise, default to costing if the SAC is setup to cost
             IF (px_CSD_ACTUAL_LINES_REC.actual_source_code in ('WIP') ) THEN
                 l_cs_cost_flag := 'N';
             END IF;

             -- If the actual_source_code = MANUAL then do validation for the
             -- actual line record values passed from the Actuals UI
             -- Raise FND_API.G_EXC_ERROR if it fails
             --IF (px_CSD_ACTUAL_LINES_REC.actual_source_code in ('MANUAL') ) THEN

                IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                     FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Begin Check reqd parameter');
                     FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Repair Line ID ='||px_CSD_ACTUAL_LINES_REC.repair_line_id);
                     FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Transaction Billing Type ID ='||px_CHARGES_REC.txn_billing_type_id);
                END IF;

                -- Check the required parameter
                CSD_PROCESS_UTIL.Check_Reqd_Param
                ( p_param_value    => px_CHARGES_REC.incident_id,
                  p_param_name     => 'INCIDENT_ID',
                  p_api_name       => l_api_name);

                CSD_PROCESS_UTIL.Check_Reqd_Param
                ( p_param_value    => px_CHARGES_REC.txn_billing_type_id,
                  p_param_name     => 'TXN_BILLING_TYPE_ID',
                  p_api_name       => l_api_name);

                CSD_PROCESS_UTIL.Check_Reqd_Param
                ( p_param_value    => px_CHARGES_REC.inventory_item_id_in,
                  p_param_name     => 'INVENTORY_ITEM_ID',
                  p_api_name       => l_api_name);

                CSD_PROCESS_UTIL.Check_Reqd_Param
                ( p_param_value    => px_CHARGES_REC.unit_of_measure_code,
                  p_param_name     => 'UNIT_OF_MEASURE_CODE',
                  p_api_name       => l_api_name);

                CSD_PROCESS_UTIL.Check_Reqd_Param
                ( p_param_value    => px_CHARGES_REC.quantity_required,
                  p_param_name     => 'ESTIMATE_QUANTITY',
                  p_api_name       => l_api_name);

                CSD_PROCESS_UTIL.Check_Reqd_Param
                ( p_param_value    => px_CHARGES_REC.price_list_id,
                  p_param_name     => 'PRICE_LIST_ID',
                  p_api_name       => l_api_name);

                IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                     FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'End Check reqd parameter');
                END IF;

                -- begin check for incident id is not null
                IF (px_CHARGES_REC.incident_id is not null) THEN

                     IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                          FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Incident_id  ='||px_CHARGES_REC.incident_id);
                     END IF;

                     -- Get the business process id
                     l_bus_process_id := CSD_PROCESS_UTIL.GET_BUS_PROCESS(px_CSD_ACTUAL_LINES_REC.repair_line_id);

                     IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                          FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'l_bus_process_id ='||l_bus_process_id);
                     END IF;

                     IF l_bus_process_id < 0 THEN
                         IF NVL(px_CHARGES_REC.business_process_id,FND_API.G_MISS_NUM)
                                <> FND_API.G_MISS_NUM THEN
                             l_bus_process_id := px_CHARGES_REC.business_process_id;
                         ELSE
                            IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                                 FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Business process does not exist');
                            END IF;
                            RAISE FND_API.G_EXC_ERROR;
                         END IF;
                      END IF;

                      OPEN  order_rec(px_CHARGES_REC.incident_id);
                      FETCH order_rec
                       INTO l_party_id,
                            l_account_id;

                      IF order_rec%NOTFOUND OR l_party_id IS NULL THEN
                         FND_MESSAGE.SET_NAME('CSD','CSD_API_PARTY_MISSING');
                         FND_MESSAGE.SET_TOKEN('INCIDENT_ID',px_CHARGES_REC.incident_id);
                         FND_MSG_PUB.ADD;
                         IF (Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level) THEN
                           FND_LOG.MESSAGE(Fnd_Log.Level_Error,l_mod_name, FALSE);
                         END IF;
                         RAISE FND_API.G_EXC_ERROR;
                      END IF;

                      IF order_rec%ISOPEN THEN
                         CLOSE order_rec;
                      END IF;

                      IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                           FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'l_party_id   ='||l_party_id);
                           FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'l_account_id ='||l_account_id);
                           FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'px_CHARGES_REC.txn_billing_type_id ='||px_CHARGES_REC.txn_billing_type_id);
                      END IF;

                      -- Derive the txn_billing type and line category code
                      -- from the transaction type
                      CSD_PROCESS_UTIL.GET_LINE_TYPE
                          ( p_txn_billing_type_id => px_CHARGES_REC.txn_billing_type_id,
                            p_org_id              => CSD_PROCESS_UTIL.get_org_id(px_CHARGES_REC.incident_id),
                            x_line_type_id        => l_line_type_id,
                            x_line_category_code  => l_line_category_code,
                            x_return_status       => x_return_status );

                      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                         RAISE FND_API.G_EXC_ERROR;
                      END IF;

                      IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                           FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'line_type_id ='||l_line_type_id);
                           FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'line_category_code  ='||l_line_category_code);
                           FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'price_list_id ='||px_CHARGES_REC.price_list_id);
                      END IF;

                      -- If line_type_id Or line_category_code is null, then raise error
                      IF  l_line_type_id IS NULL OR
                         l_line_category_code IS NULL THEN
                         FND_MESSAGE.SET_NAME('CSD','CSD_API_LINE_TYPE_MISSING');
                         FND_MESSAGE.SET_TOKEN('TXN_BILLING_TYPE_ID',px_CHARGES_REC.txn_billing_type_id);
                         FND_MSG_PUB.ADD;
                         IF (Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level) THEN
                           FND_LOG.MESSAGE(Fnd_Log.Level_Error,l_mod_name, FALSE);
                         END IF;
                         RAISE FND_API.G_EXC_ERROR;
                      END IF;

                      -- Get the currency code
                      IF NVL(px_CHARGES_REC.price_list_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
                         BEGIN
                           SELECT currency_code
                             INTO l_curr_code
                             FROM oe_price_lists
                            WHERE price_list_id  =  px_CHARGES_REC.price_list_id;
                         EXCEPTION
                             WHEN NO_DATA_FOUND THEN
                                  FND_MESSAGE.SET_NAME('CSD','CSD_API_INV_PRICE_LIST_ID');
                                  FND_MESSAGE.SET_TOKEN('PRICE_LIST_ID',px_CHARGES_REC.price_list_id);
                                  FND_MSG_PUB.ADD;
                                  IF (Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level) THEN
                                    FND_LOG.MESSAGE(Fnd_Log.Level_Error,l_mod_name, FALSE);
                                  END IF;
                                  RAISE FND_API.G_EXC_ERROR;
                         END;
                      END IF;

                      IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                           FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'l_curr_code ='||l_curr_code);
                      END IF;

                      -- If l_curr_code is null then raise error
                      IF l_curr_code IS NULL THEN
                         FND_MESSAGE.SET_NAME('CSD','CSD_API_INV_CURR_CODE');
                         FND_MESSAGE.SET_TOKEN('PRICE_LIST_ID',px_CHARGES_REC.price_list_id);
                         FND_MSG_PUB.ADD;
                         IF (Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level) THEN
                           FND_LOG.MESSAGE(Fnd_Log.Level_Error,l_mod_name, FALSE);
                         END IF;
                         RAISE FND_API.G_EXC_ERROR;
                      END IF;

                      -- assigning values for the charge record
                      px_CHARGES_REC.business_process_id     := l_bus_process_id;
                      px_CHARGES_REC.line_type_id            := l_line_type_id;
                      px_CHARGES_REC.currency_code           := l_curr_code;
                      px_CHARGES_REC.line_category_code      := l_line_category_code;

                      -- travi new code
        	          --px_CHARGES_REC.charge_line_type        := ;
        	          --px_CHARGES_REC.apply_contract_discount := ;

                      IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                           FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Assign Derived values for the charge rec');
                      END IF;

                      -- always create estimate lines with interface to OE flag as 'N'
        	          px_CHARGES_REC.interface_to_oe_flag    := 'N'    ;

                      -- Convert the estimate record to charge record
                      --CSD_PROCESS_UTIL.CONVERT_EST_TO_CHG_REC
                      --    ( p_estimate_line_rec  => px_CSD_ACTUAL_LINES_REC,
                      --      x_charges_rec        => lx_charges_rec,
                      --      x_return_status      => x_return_status );

                      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                         RAISE FND_API.G_EXC_ERROR;
                      END IF;

                END IF;
                -- end check for incident id is not null

             --ELSIF (px_CSD_ACTUAL_LINES_REC.actual_source_code in ('WIP') ) THEN
             --   null;
             --END IF;
             IF ( Fnd_Log.Level_Procedure >= G_debug_level) THEN
                  FND_LOG.STRING(Fnd_Log.Level_Procedure,l_mod_name,'Call process_estimate_lines to create charge lines');
             END IF;

             -- For WIP we will have charge record as input but we create charge record for MANUAL
             -- Call table handler CSD_REPAIR_ESTIMATE_PVT.Process_Estimate_Lines in create mode
             -- which calls charges API to update the record in CS_ESTIMATE_DETAILS
             CSD_REPAIR_ESTIMATE_PVT.PROCESS_ESTIMATE_LINES
                ( p_api_version           =>  1.0 ,
                  p_commit                =>  fnd_api.g_false,
                  p_init_msg_list         =>  fnd_api.g_true,
                  p_validation_level      =>  fnd_api.g_valid_level_full,
                  p_action                =>  'CREATE',
                  p_cs_cost_flag          =>  l_cs_cost_flag, -- swai: 12.1 service costing uptake bug 6960295
                  x_Charges_Rec           =>  px_charges_rec,
                  x_return_status         =>  x_return_status,
                  x_msg_count             =>  x_msg_count,
                  x_msg_data              =>  x_msg_data  );

             -- Raise FND_API.G_EXC_ERROR if it fails
             IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                RAISE FND_API.G_EXC_ERROR;
                IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                     FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Creating Charge line failed for actual_source_code : '||px_CSD_ACTUAL_LINES_REC.actual_source_code);
                END IF;
             END IF;

             -- Assign estimate_detail_id to Actual lines record
             px_CSD_ACTUAL_LINES_REC.ESTIMATE_DETAIL_ID := px_charges_rec.estimate_detail_id;
             IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                  FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Created estimate_detail_id : '||px_CSD_ACTUAL_LINES_REC.ESTIMATE_DETAIL_ID);
             END IF;

             --
             -- API body
             --
             IF ( Fnd_Log.Level_Procedure >= G_debug_level) THEN
                  FND_LOG.STRING(Fnd_Log.Level_Procedure,l_mod_name,'Call to CSD_REPAIR_ACTUAL_LINES_REC_PKG.Insert_Row');
             END IF;

             BEGIN
                  -- Call table handler CSD_REPAIR_ACTUALS_LINES_PKG.Insert_Row to
                  -- insert the record into CSD_REPAIR_ACTUAL_LINES
                  -- Invoke table handler(CSD_REPAIR_ACTUAL_LINES_PKG.Insert_Row)
                  CSD_REPAIR_ACTUAL_LINES_PKG.Insert_Row(
                           px_REPAIR_ACTUAL_LINE_ID  => px_CSD_ACTUAL_LINES_REC.REPAIR_ACTUAL_LINE_ID
                          ,p_OBJECT_VERSION_NUMBER   => px_CSD_ACTUAL_LINES_REC.OBJECT_VERSION_NUMBER
                          ,p_ESTIMATE_DETAIL_ID      => px_CSD_ACTUAL_LINES_REC.ESTIMATE_DETAIL_ID
                          ,p_REPAIR_ACTUAL_ID        => px_CSD_ACTUAL_LINES_REC.REPAIR_ACTUAL_ID
                          ,p_REPAIR_LINE_ID          => px_CSD_ACTUAL_LINES_REC.REPAIR_LINE_ID
                          ,p_CREATED_BY              => FND_GLOBAL.USER_ID
                          ,p_CREATION_DATE           => SYSDATE
                          ,p_LAST_UPDATED_BY         => FND_GLOBAL.USER_ID
                          ,p_LAST_UPDATE_DATE        => SYSDATE
                          ,p_LAST_UPDATE_LOGIN       => FND_GLOBAL.CONC_LOGIN_ID
                          ,p_ITEM_COST               => px_CSD_ACTUAL_LINES_REC.ITEM_COST
                          ,p_JUSTIFICATION_NOTES     => px_CSD_ACTUAL_LINES_REC.JUSTIFICATION_NOTES
                          ,p_RESOURCE_ID             => px_CSD_ACTUAL_LINES_REC.RESOURCE_ID
                          ,p_OVERRIDE_CHARGE_FLAG    => px_CSD_ACTUAL_LINES_REC.OVERRIDE_CHARGE_FLAG
                          ,p_ACTUAL_SOURCE_CODE      => px_CSD_ACTUAL_LINES_REC.ACTUAL_SOURCE_CODE
                          ,p_ACTUAL_SOURCE_ID        => px_CSD_ACTUAL_LINES_REC.ACTUAL_SOURCE_ID
                          ,p_WARRANTY_CLAIM_FLAG     => px_CSD_ACTUAL_LINES_REC.WARRANTY_CLAIM_FLAG
                          ,p_WARRANTY_NUMBER         => px_CSD_ACTUAL_LINES_REC.WARRANTY_NUMBER
                          ,p_WARRANTY_STATUS_CODE    => px_CSD_ACTUAL_LINES_REC.WARRANTY_STATUS_CODE
                          ,p_REPLACED_ITEM_ID        => px_CSD_ACTUAL_LINES_REC.REPLACED_ITEM_ID
                          ,p_ATTRIBUTE_CATEGORY      => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE_CATEGORY
                          ,p_ATTRIBUTE1              => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE1
                          ,p_ATTRIBUTE2              => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE2
                          ,p_ATTRIBUTE3              => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE3
                          ,p_ATTRIBUTE4              => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE4
                          ,p_ATTRIBUTE5              => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE5
                          ,p_ATTRIBUTE6              => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE6
                          ,p_ATTRIBUTE7              => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE7
                          ,p_ATTRIBUTE8              => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE8
                          ,p_ATTRIBUTE9              => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE9
                          ,p_ATTRIBUTE10             => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE10
                          ,p_ATTRIBUTE11             => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE11
                          ,p_ATTRIBUTE12             => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE12
                          ,p_ATTRIBUTE13             => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE13
                          ,p_ATTRIBUTE14             => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE14
                          ,p_ATTRIBUTE15             => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE15
                          ,p_LOCATOR_ID              => px_CSD_ACTUAL_LINES_REC.LOCATOR_ID
                          ,p_LOC_SEGMENT1            => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT1
                          ,p_LOC_SEGMENT2            => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT2
                          ,p_LOC_SEGMENT3            => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT3
                          ,p_LOC_SEGMENT4            => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT4
                          ,p_LOC_SEGMENT5            => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT5
                          ,p_LOC_SEGMENT6            => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT6
                          ,p_LOC_SEGMENT7            => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT7
                          ,p_LOC_SEGMENT8            => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT8
                          ,p_LOC_SEGMENT9            => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT9
                          ,p_LOC_SEGMENT10           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT10
                          ,p_LOC_SEGMENT11           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT11
                          ,p_LOC_SEGMENT12           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT12
                          ,p_LOC_SEGMENT13           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT13
                          ,p_LOC_SEGMENT14           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT14
                          ,p_LOC_SEGMENT15           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT15
                          ,p_LOC_SEGMENT16           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT16
                          ,p_LOC_SEGMENT17           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT17
                          ,p_LOC_SEGMENT18           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT18
                          ,p_LOC_SEGMENT19           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT19
                          ,p_LOC_SEGMENT20           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT20);


             EXCEPTION
                  WHEN OTHERS THEN
                     IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                           FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'Others exception in CSD_REPAIR_ACTUAL_LINES_PKG.Insert_Row Call :'||SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1,255));
                     END IF;
                     x_return_status := FND_API.G_RET_STS_ERROR;
             END;

             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 RAISE FND_API.G_EXC_ERROR;
             END IF;

             --
             -- End of API body
             --

           END IF;


          -- Standard check of p_commit.
          IF FND_API.To_Boolean( p_commit ) THEN
               COMMIT WORK;
          END IF;

          -- Standard call to get message count and IF count is  get message info.
          FND_MSG_PUB.Count_And_Get
               (p_count  =>  x_msg_count,
                p_data   =>  x_msg_data );

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
              IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                  FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'In FND_API.G_EXC_ERROR exception');
              END IF;
              x_return_status := FND_API.G_RET_STS_ERROR ;
              ROLLBACK TO CREATE_REPAIR_ACTUAL_LINES;
              FND_MSG_PUB.Count_And_Get
                  (p_count  =>  x_msg_count,
                   p_data   =>  x_msg_data );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                  FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'In FND_API.G_EXC_UNEXPECTED_ERROR exception ');
              END IF;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              ROLLBACK TO CREATE_REPAIR_ACTUAL_LINES;
              FND_MSG_PUB.Count_And_Get
                    ( p_count  =>  x_msg_count,
                      p_data   =>  x_msg_data );
        WHEN OTHERS THEN
              IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                  FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'In OTHERS exception');
                  FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'Sql Err Msg :'||SQLERRM );
              END IF;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              ROLLBACK TO CREATE_REPAIR_ACTUAL_LINES;
                  IF  FND_MSG_PUB.Check_Msg_Level
                      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                  THEN
                      FND_MSG_PUB.Add_Exc_Msg
                      (G_PKG_NAME ,
                       l_api_name  );
                  END IF;
                      FND_MSG_PUB.Count_And_Get
                      (p_count  =>  x_msg_count,
                       p_data   =>  x_msg_data );

End CREATE_REPAIR_ACTUAL_LINES;


/*--------------------------------------------------------------------*/
/* procedure name: UPDATE_REPAIR_ACTUAL_LINES                         */
/* description : procedure used to Update Repair Actuals              */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/* Called from : Depot Repair Actuals UI                              */
/* Input Parm  :                                                      */
/*   p_api_version       NUMBER    Req Api Version number             */
/*   p_init_msg_list     VARCHAR2  Opt Initialize message stack       */
/*   p_commit            VARCHAR2  Opt Commits in API                 */
/*   p_validation_level  NUMBER    Opt validation steps               */
/*   px_CSD_ACTUAL_LINES_REC REC   Req Actuals lines Record           */
/*   px_Charges_Rec          REC   Req Charges line Record            */
/* Output Parm :                                                      */
/*   x_return_status     VARCHAR2      Return status after the call.  */
/*   x_msg_count         NUMBER        Number of messages in stack    */
/*   x_msg_data          VARCHAR2      Mesg. text if x_msg_count >= 1 */
/* Change Hist :                                                      */
/*   08/11/03  travikan  Initial Creation.                            */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
PROCEDURE UPDATE_REPAIR_ACTUAL_LINES(
    P_Api_Version           IN            NUMBER,
    P_Commit                IN            VARCHAR2,
    P_Init_Msg_List         IN            VARCHAR2,
    p_validation_level      IN            NUMBER,
    px_CSD_ACTUAL_LINES_REC IN OUT NOCOPY CSD_ACTUAL_LINES_REC_TYPE,
    px_Charges_Rec          IN OUT NOCOPY CS_CHARGE_DETAILS_PUB.CHARGES_REC_TYPE,
    X_Return_Status         OUT    NOCOPY VARCHAR2,
    X_Msg_Count             OUT    NOCOPY NUMBER,
    X_Msg_Data              OUT    NOCOPY VARCHAR2
    )

 IS
      -- Variables used in FND Log
      l_stat_level   number   := FND_LOG.LEVEL_STATEMENT;
      l_proc_level   number   := FND_LOG.LEVEL_PROCEDURE;
      l_event_level  number   := FND_LOG.LEVEL_EVENT;
      l_excep_level  number   := FND_LOG.LEVEL_EXCEPTION;
      l_error_level  number   := FND_LOG.LEVEL_ERROR;
      l_unexp_level  number   := FND_LOG.LEVEL_UNEXPECTED;
      l_mod_name     varchar2(2000) := 'csd.plsql.csd_repair_actual_lines_pvt.update_repair_actual_lines';

      l_api_name               CONSTANT VARCHAR2(30)   := 'UPDATE_REPAIR_ACTUAL_LINES';
      l_api_version            CONSTANT NUMBER         := 1.0;
      l_msg_count              NUMBER;
      l_msg_data               VARCHAR2(100);
      l_msg_index              NUMBER;
      l_api_return_status      VARCHAR2(3);

      l_act_obj_ver_num        NUMBER;
      l_est_obj_ver_num        NUMBER;

     /*FP Fixed for bug#5117652
       Following variables added
     */
      l_sr_add_to_order_flag         varchar2(1);
      l_ro_add_to_order_flag         varchar2(1);
      l_line_order_category_code     varchar2(30);
      l_add_actual_to_id             number;
    /*FP Fixed for bug#5117652 end*/

      -- swai: 12.1 service costing uptake bug 6960295
      l_cs_cost_flag   VARCHAR2(1) := 'Y';

      CURSOR charge_lines(p_est_det_id IN NUMBER) IS
      SELECT object_version_number
       FROM  cs_estimate_details
      WHERE  estimate_detail_id  = p_est_det_id;

      CURSOR repair_actual_lines(p_actual_line_id IN NUMBER) IS
      SELECT a.object_version_number
       FROM  csd_repair_actual_lines a,
             csd_repairs b
      WHERE  a.repair_line_id = b.repair_line_id
        and  a.repair_actual_line_id  = p_actual_line_id;



    BEGIN
          -- Standard Start of API savepoint
          SAVEPOINT UPDATE_REPAIR_ACTUAL_LINES;

          -- Standard call to check for call compatibility.
          IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                               p_api_version,
                                               l_api_name,
                                               G_PKG_NAME)
          THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

           -- Initialize message list if p_init_msg_list is set to TRUE.
           IF FND_API.to_Boolean( p_init_msg_list ) THEN
               FND_MSG_PUB.initialize;
           END IF;

           -- Initialize API return status to success
           x_return_status := FND_API.G_RET_STS_SUCCESS;

           -- Api body starts
           IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'At the Beginning of update_repair_actual_lines');
           END IF;

           -- Dump the in parameters in the log file
           -- if the debug level > 5
           -- If fnd_profile.value('CSD_DEBUG_LEVEL') > 5 then
--            if (g_debug > 5) then
--               csd_gen_utility_pvt.dump_actuals_rec
--                        ( p_CSD_ACTUAL_LINES_REC => px_CSD_ACTUAL_LINES_REC);
--            end if;

           IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Begin Check reqd parameter');
           END IF;

           -- Check the required parameter
           CSD_PROCESS_UTIL.Check_Reqd_Param
           ( p_param_value    => px_CSD_ACTUAL_LINES_REC.repair_line_id,
             p_param_name     => 'REPAIR_LINE_ID',
             p_api_name       => l_api_name);

           CSD_PROCESS_UTIL.Check_Reqd_Param
           ( p_param_value    => px_CSD_ACTUAL_LINES_REC.repair_actual_id,
             p_param_name     => 'REPAIR_ACTUAL_ID',
             p_api_name       => l_api_name);

           CSD_PROCESS_UTIL.Check_Reqd_Param
           ( p_param_value    => px_CSD_ACTUAL_LINES_REC.repair_actual_line_id,
             p_param_name     => 'REPAIR_ACTUAL_LINE_ID',
             p_api_name       => l_api_name);

           CSD_PROCESS_UTIL.Check_Reqd_Param
           ( p_param_value    => px_Charges_Rec.estimate_detail_id,
             p_param_name     => 'ESTIMATE_DETAIL_ID',
             p_api_name       => l_api_name);

           IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'End Check reqd parameter');
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Begin Validate Repair Line id');
           END IF;

           -- Validate the repair line ID
           IF NOT( CSD_PROCESS_UTIL.Validate_rep_line_id
                           ( p_repair_line_id  => px_CSD_ACTUAL_LINES_REC.repair_line_id )) THEN
               RAISE FND_API.G_EXC_ERROR;
           END IF;

           IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'End  Validate Repair Line id');
           END IF;

           -- Validate the repair actual line id against csd_repair_actual_lines
           -- If it is invalid then raise FND_API.G_EXC_ERROR
           IF NVL(px_CSD_ACTUAL_LINES_REC.repair_actual_line_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN

            OPEN  repair_actual_lines(px_CSD_ACTUAL_LINES_REC.repair_actual_line_id);
            FETCH repair_actual_lines
             INTO l_act_obj_ver_num;

             IF repair_actual_lines%NOTFOUND THEN
              FND_MESSAGE.SET_NAME('CSD','CSD_API_ACTUAL_LINE_MISSING');
              FND_MESSAGE.SET_TOKEN('REPAIR_ACTUAL_LINE_ID',px_CSD_ACTUAL_LINES_REC.repair_actual_line_id);
              FND_MSG_PUB.ADD;
              IF (Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level) THEN
                FND_LOG.MESSAGE(Fnd_Log.Level_Error,l_mod_name, FALSE);
              END IF;
              RAISE FND_API.G_EXC_ERROR;
             END IF;

             IF repair_actual_lines%ISOPEN THEN
              CLOSE repair_actual_lines;
             END IF;

           -- Validate the estimate detail id against cs_estimate_details
           -- If it is invalid then raise FND_API.G_EXC_ERROR
            OPEN  charge_lines(px_Charges_Rec.estimate_detail_id);
            FETCH charge_lines
             INTO l_est_obj_ver_num;

             IF charge_lines%NOTFOUND THEN
              FND_MESSAGE.SET_NAME('CSD','CSD_API_CHARGE_LINE_MISSING');
              FND_MESSAGE.SET_TOKEN('ESTIMATE_DETAIL_ID',px_Charges_Rec.estimate_detail_id);
              FND_MSG_PUB.ADD;
              IF (Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level) THEN
                FND_LOG.MESSAGE(Fnd_Log.Level_Error,l_mod_name, FALSE);
              END IF;
              RAISE FND_API.G_EXC_ERROR;
             END IF;

             IF charge_lines%ISOPEN THEN
              CLOSE charge_lines;
             END IF;

           END IF;

           IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Validate Object Version Number for Charge and Actual Line');
           END IF;

           IF NVL(px_CSD_ACTUAL_LINES_REC.object_version_number,FND_API.G_MISS_NUM) <> l_act_obj_ver_num  THEN
              IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                   FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Actual Line Object Version Number does not match'
			    || ' for the Repair Actual Line ID = ' || px_CSD_ACTUAL_LINES_REC.repair_actual_line_id);
              END IF;

              -- Modified the message name for bugfix 3281321. vkjain.
              -- FND_MESSAGE.SET_NAME('CSD','CSD_OBJ_VER_MISMATCH');
              FND_MESSAGE.SET_NAME('CSD','CSD_ACT_LIN_OBJ_VER_MISMATCH');
              -- FND_MESSAGE.SET_TOKEN('REPAIR_ACTUAL_LINE_ID',px_CSD_ACTUAL_LINES_REC.repair_actual_line_id);
              FND_MSG_PUB.ADD;
              IF (Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level) THEN
                FND_LOG.MESSAGE(Fnd_Log.Level_Error,l_mod_name, FALSE);
              END IF;
              RAISE FND_API.G_EXC_ERROR;
           ELSE
                 -- Assigning object version number
                 px_CSD_ACTUAL_LINES_REC.object_version_number := l_act_obj_ver_num+1;
           END IF;

          /*FP Fixed for bug#5117652
            Below code is added. This code ensure that actual line is added to
            existing OM line based on profile setup.
          */

          IF px_Charges_Rec.INTERFACE_TO_OE_FLAG ='Y'then /*if interfacing the line then get the order header based on profile */
             select line_order_category_code
             into  l_line_order_category_code
             from cs_transaction_types_b
             where transaction_type_id = px_Charges_Rec.TRANSACTION_TYPE_ID;

            l_sr_add_to_order_flag := fnd_profile.value('CSD_ADD_TO_SO_WITHIN_SR');
            l_sr_add_to_order_flag := nvl(l_sr_Add_to_order_flag, 'N');
            l_ro_add_to_order_flag := fnd_profile.value('CSD_ADD_TO_SO_WITHIN_RO');
            l_ro_add_to_order_flag := nvl(l_ro_Add_to_order_flag, 'N');

            IF (l_sr_add_to_order_flag='Y') OR (l_ro_add_to_order_flag='Y') then
               IF l_line_order_category_code ='ORDER' then
                  begin
                    Select max(ced.order_header_id)
                    into  l_add_actual_to_id
                    from  cs_estimate_details ced,
                          oe_order_headers_all ooh,
                          oe_order_types_v oot
                    where
                      ced.estimate_detail_id in
                      (select estimate_detail_id
                       from  csd_product_transactions
                       where repair_line_id = px_CSD_ACTUAL_LINES_REC.REPAIR_LINE_ID
                       union
                       select estimate_detail_id
                       from csd_repair_actual_lines
                       where repair_actual_id=px_CSD_ACTUAL_LINES_REC.REPAIR_ACTUAL_ID)
                    and  ced.order_header_id is not null
                    and  ooh.open_flag = 'Y'
                    and  nvl(ooh.cancelled_flag,'N') = 'N'
                    and  ooh.header_id = ced.order_header_id
                    and  (ooh.cust_po_number = nvl(px_Charges_Rec.PURCHASE_ORDER_NUM,ooh.cust_po_number)
                             or ooh.cust_po_number is null)
                    and  ooh.sold_to_org_id  = px_Charges_Rec.bill_to_account_id  -- swai: bug 6962424
                    and  oot.order_type_id = ooh.order_type_id
                    and  oot.order_category_code in ('MIXED','ORDER')
                    and  ced.interface_to_oe_flag = 'Y';
                  exception
                  when no_data_found then
                    l_add_actual_to_id := null;
                  end;
               ELSIF l_line_order_category_code ='RETURN' then
                  begin
                    Select max(ced.order_header_id)
                    into  l_add_actual_to_id
                    from  cs_estimate_details ced,
                          oe_order_headers_all ooh,
                          oe_order_types_v oot
                    where
                    ced.estimate_detail_id in
                     (select estimate_detail_id
                      from  csd_product_transactions
                      where repair_line_id = px_CSD_ACTUAL_LINES_REC.REPAIR_LINE_ID
                      union
                      select estimate_detail_id
                      from csd_repair_actual_lines
                      where repair_actual_id=px_CSD_ACTUAL_LINES_REC.REPAIR_ACTUAL_ID)
                   and  ced.order_header_id is not null
                   and  ooh.open_flag = 'Y'
                   and  nvl(ooh.cancelled_flag,'N') = 'N'
                   and  ooh.header_id = ced.order_header_id
                   and  (ooh.cust_po_number = nvl(px_Charges_Rec.PURCHASE_ORDER_NUM,ooh.cust_po_number)
                        or ooh.cust_po_number is null)
                   and  ooh.sold_to_org_id  = px_Charges_Rec.bill_to_account_id  -- swai: bug 6962424
                   and  oot.order_type_id = ooh.order_type_id
                   and  oot.order_category_code in ('MIXED','RETURN')
                   and  ced.interface_to_oe_flag = 'Y';
                 exception
                 when no_data_found then
                   l_add_actual_to_id := null;
                 end;
               END IF; /*line order category*/

               If l_add_actual_to_id is not null then /*add actual line */
                 px_Charges_Rec.ADD_TO_ORDER_FLAG := 'Y';
                 px_Charges_Rec.ORDER_HEADER_ID := l_add_actual_to_id;
               elsif (l_sr_add_to_order_flag='N') then
                   /*RO profile is yes and SR profile is NO and we do not find SO under RO
                     in this case new SR should be created */
                  px_Charges_Rec.ADD_TO_ORDER_FLAG := 'F';
                  px_Charges_Rec.ORDER_HEADER_ID := NULL;
               end if;

            ELSE /*when both profile are N then create new order */
                 px_Charges_Rec.ADD_TO_ORDER_FLAG := 'F';
                 px_Charges_Rec.ORDER_HEADER_ID := NULL;
            END IF;
          end if; /*end if interface to oe flag */
          /*FP Fixed for bug#5117652 end*/


          -- Initialize API return status to SUCCESS
          x_return_status := FND_API.G_RET_STS_SUCCESS;

          -- --------------------------------------------------------------------
          -- Check the Repair_Actual_Lines_Rec.actual_source_code for validations

          -- Following validations will be done in the form itself
          -- Validate the repair actual line record for
          -- if the line is not interfaced to Order Management

          -- Validate the repair actual line record for
          -- if the line passes the security validations

          -- Validate the repair actual line record for
          -- if the line can have a override in charge value
          -- --------------------------------------------------------------------
           IF (px_CSD_ACTUAL_LINES_REC.actual_source_code in ('MANUAL', 'ESTIMATE') ) THEN
               -- no validations planned as of now
               null;
           ELSIF (px_CSD_ACTUAL_LINES_REC.actual_source_code in ('TASK', 'WIP') ) THEN
               null;
               -- -------------------------------------------------------------
               -- These Validations are enforced in the form itself
               -- Allow Pricing related updates but not product related updates
               -- product, quantity
               -- price list, uom, contract, unit price, after warranty cost
               -- -------------------------------------------------------------

               -- swai: 12.1 service costing uptake bug 6960295
               IF (px_CSD_ACTUAL_LINES_REC.actual_source_code = 'WIP' ) THEN
                   l_cs_cost_flag := 'N';
               END IF;
           END IF;

           --
           -- Api body
           --
           BEGIN
              -- Call table handler CSD_REPAIR_ESTIMATE_PVT.Process_Estimate_Lines in update mode
              -- which calls charges API to update the record in CS_ESTIMATE_DETAILS
              CSD_REPAIR_ESTIMATE_PVT.PROCESS_ESTIMATE_LINES
                 ( p_api_version           =>  1.0 ,
                   p_commit                =>  fnd_api.g_false,
                   p_init_msg_list         =>  fnd_api.g_true,
                   p_validation_level      =>  fnd_api.g_valid_level_full,
                   p_action                =>  'UPDATE',
                   -- swai: 12.1 service costing uptake bug 6960295
                   p_cs_cost_flag          =>  l_cs_cost_flag,
                   x_Charges_Rec           =>  px_charges_rec,
                   x_return_status         =>  x_return_status,
                   x_msg_count             =>  x_msg_count,
                   x_msg_data              =>  x_msg_data);

              -- The following check was added as a fix for bug 3378602. vkjain
              -- We do not want to continue with updating the Actual line if Charges
              -- API returned error.
              IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                 RAISE FND_API.G_EXC_ERROR;
              END IF;

           EXCEPTION
              -- The following exception was added as a fix for bug 3378602. vkjain
              WHEN FND_API.G_EXC_ERROR THEN
                   IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                      FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'Charges API returned error while calling UPDATE.');
                   END IF;
                   RAISE FND_API.G_EXC_ERROR;
              WHEN OTHERS THEN
                   IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                      FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'Others exception error :'||SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1,255));
                   END IF;
                   RAISE FND_API.G_EXC_ERROR;
           END;

           IF ( Fnd_Log.Level_Procedure >= G_debug_level) THEN
                FND_LOG.STRING(Fnd_Log.Level_Procedure,l_mod_name,'Call to  CSD_REPAIR_ACTUAL_LINES_REC_PKG.Update_Row');
           END IF;

           BEGIN
              -- Invoke table handler(CSD_REPAIR_ACTUAL_LINES_PKG.Update_Row)
              CSD_REPAIR_ACTUAL_LINES_PKG.Update_Row(
                  p_REPAIR_ACTUAL_LINE_ID  => px_CSD_ACTUAL_LINES_REC.REPAIR_ACTUAL_LINE_ID
                 ,p_OBJECT_VERSION_NUMBER  => px_CSD_ACTUAL_LINES_REC.OBJECT_VERSION_NUMBER
                 ,p_ESTIMATE_DETAIL_ID     => px_CSD_ACTUAL_LINES_REC.ESTIMATE_DETAIL_ID
                 ,p_REPAIR_ACTUAL_ID       => px_CSD_ACTUAL_LINES_REC.REPAIR_ACTUAL_ID
                 ,p_REPAIR_LINE_ID         => px_CSD_ACTUAL_LINES_REC.REPAIR_LINE_ID
                 ,p_CREATED_BY             => FND_API.G_MISS_NUM
                 ,p_CREATION_DATE          => FND_API.G_MISS_DATE
                 ,p_LAST_UPDATED_BY        => FND_GLOBAL.USER_ID
                 ,p_LAST_UPDATE_DATE       => SYSDATE
                 ,p_LAST_UPDATE_LOGIN      => FND_GLOBAL.CONC_LOGIN_ID
                 ,p_ITEM_COST              => px_CSD_ACTUAL_LINES_REC.ITEM_COST
                 ,p_JUSTIFICATION_NOTES    => px_CSD_ACTUAL_LINES_REC.JUSTIFICATION_NOTES
                 ,p_RESOURCE_ID            => px_CSD_ACTUAL_LINES_REC.RESOURCE_ID
                 ,p_OVERRIDE_CHARGE_FLAG   => px_CSD_ACTUAL_LINES_REC.OVERRIDE_CHARGE_FLAG
                 ,p_ACTUAL_SOURCE_CODE     => px_CSD_ACTUAL_LINES_REC.ACTUAL_SOURCE_CODE
                 ,p_ACTUAL_SOURCE_ID       => px_CSD_ACTUAL_LINES_REC.ACTUAL_SOURCE_ID
                 ,p_WARRANTY_CLAIM_FLAG     => px_CSD_ACTUAL_LINES_REC.WARRANTY_CLAIM_FLAG
                 ,p_WARRANTY_NUMBER         => px_CSD_ACTUAL_LINES_REC.WARRANTY_NUMBER
                 ,p_WARRANTY_STATUS_CODE    => px_CSD_ACTUAL_LINES_REC.WARRANTY_STATUS_CODE
                 ,p_REPLACED_ITEM_ID        => px_CSD_ACTUAL_LINES_REC.REPLACED_ITEM_ID
                 ,p_ATTRIBUTE_CATEGORY     => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE_CATEGORY
                 ,p_ATTRIBUTE1             => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE1
                 ,p_ATTRIBUTE2             => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE2
                 ,p_ATTRIBUTE3             => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE3
                 ,p_ATTRIBUTE4             => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE4
                 ,p_ATTRIBUTE5             => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE5
                 ,p_ATTRIBUTE6             => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE6
                 ,p_ATTRIBUTE7             => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE7
                 ,p_ATTRIBUTE8             => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE8
                 ,p_ATTRIBUTE9             => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE9
                 ,p_ATTRIBUTE10            => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE10
                 ,p_ATTRIBUTE11            => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE11
                 ,p_ATTRIBUTE12            => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE12
                 ,p_ATTRIBUTE13            => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE13
                 ,p_ATTRIBUTE14            => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE14
                 ,p_ATTRIBUTE15            => px_CSD_ACTUAL_LINES_REC.ATTRIBUTE15
                 ,p_LOCATOR_ID             => px_CSD_ACTUAL_LINES_REC.LOCATOR_ID
                 ,p_LOC_SEGMENT1           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT1
                 ,p_LOC_SEGMENT2           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT2
                 ,p_LOC_SEGMENT3           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT3
                 ,p_LOC_SEGMENT4           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT4
                 ,p_LOC_SEGMENT5           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT5
                 ,p_LOC_SEGMENT6           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT6
                 ,p_LOC_SEGMENT7           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT7
                 ,p_LOC_SEGMENT8           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT8
                 ,p_LOC_SEGMENT9           => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT9
                 ,p_LOC_SEGMENT10          => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT10
                 ,p_LOC_SEGMENT11          => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT11
                 ,p_LOC_SEGMENT12          => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT12
                 ,p_LOC_SEGMENT13          => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT13
                 ,p_LOC_SEGMENT14          => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT14
                 ,p_LOC_SEGMENT15          => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT15
                 ,p_LOC_SEGMENT16          => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT16
                 ,p_LOC_SEGMENT17          => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT17
                 ,p_LOC_SEGMENT18          => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT18
                 ,p_LOC_SEGMENT19          => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT19
                 ,p_LOC_SEGMENT20          => px_CSD_ACTUAL_LINES_REC.LOC_SEGMENT20);


           EXCEPTION
              WHEN OTHERS THEN
                   IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                        FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'Others exception in CSD_REPAIR_ACTUAL_LINES_PKG.Update_Row Cal:'||SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1,255));
                   END IF;
                   RAISE FND_API.G_EXC_ERROR;
           END;
           --
           -- End of API body
           --

           -- Standard check of p_commit.
           IF FND_API.To_Boolean( p_commit ) THEN
               COMMIT WORK;
           END IF;

           -- Standard call to get message count and IF count is  get message info.
           FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data );

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
              IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                  FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'In FND_API.G_EXC_ERROR exception');
              END IF;
              x_return_status := FND_API.G_RET_STS_ERROR ;
              ROLLBACK TO UPDATE_REPAIR_ACTUAL_LINES;
              FND_MSG_PUB.Count_And_Get
                  (p_count  =>  x_msg_count,
                   p_data   =>  x_msg_data );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                  FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'In FND_API.G_EXC_UNEXPECTED_ERROR exception ');
              END IF;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              ROLLBACK TO UPDATE_REPAIR_ACTUAL_LINES;
              FND_MSG_PUB.Count_And_Get
                    ( p_count  =>  x_msg_count,
                      p_data   =>  x_msg_data );
        WHEN OTHERS THEN
              IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                  FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'In OTHERS exception');
                  FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'Sql Err Msg :'||SQLERRM );
              END IF;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              ROLLBACK TO UPDATE_REPAIR_ACTUAL_LINES;
                  IF  FND_MSG_PUB.Check_Msg_Level
                      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                  THEN
                      FND_MSG_PUB.Add_Exc_Msg
                      (G_PKG_NAME ,
                       l_api_name  );
                  END IF;
                      FND_MSG_PUB.Count_And_Get
                      (p_count  =>  x_msg_count,
                       p_data   =>  x_msg_data );

    End UPDATE_REPAIR_ACTUAL_LINES;


/*--------------------------------------------------------------------*/
/* procedure name: DELETE_REPAIR_ACTUAL_LINES                         */
/* description : procedure used to Delete Repair Actuals              */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/* Called from : Depot Repair Actuals UI                              */
/* Input Parm  :                                                      */
/*   p_api_version       NUMBER    Req Api Version number             */
/*   p_init_msg_list     VARCHAR2  Opt Initialize message stack       */
/*   p_commit            VARCHAR2  Opt Commits in API                 */
/*   p_validation_level  NUMBER    Opt validation steps               */
/*   px_CSD_ACTUAL_LINES_REC REC   Req Actuals lines Record           */
/*   px_Charges_Rec          REC   Req Charges line Record            */
/* Output Parm :                                                      */
/*   x_return_status     VARCHAR2      Return status after the call.  */
/*   x_msg_count         NUMBER        Number of messages in stack    */
/*   x_msg_data          VARCHAR2      Mesg. text if x_msg_count >= 1 */
/* Change Hist :                                                      */
/*   08/11/03  travikan  Initial Creation.                            */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
PROCEDURE DELETE_REPAIR_ACTUAL_LINES(
    P_Api_Version           IN            NUMBER,
    P_Commit                IN            VARCHAR2,
    P_Init_Msg_List         IN            VARCHAR2,
    p_validation_level      IN            NUMBER,
    px_CSD_ACTUAL_LINES_REC IN OUT NOCOPY CSD_ACTUAL_LINES_REC_TYPE,
    px_Charges_Rec          IN OUT NOCOPY CS_CHARGE_DETAILS_PUB.CHARGES_REC_TYPE,
    X_Return_Status         OUT    NOCOPY VARCHAR2,
    X_Msg_Count             OUT    NOCOPY NUMBER,
    X_Msg_Data              OUT    NOCOPY VARCHAR2
    )

 IS
       -- Variables used in FND Log
       l_stat_level   number   := FND_LOG.LEVEL_STATEMENT;
       l_proc_level   number   := FND_LOG.LEVEL_PROCEDURE;
       l_event_level  number   := FND_LOG.LEVEL_EVENT;
       l_excep_level  number   := FND_LOG.LEVEL_EXCEPTION;
       l_error_level  number   := FND_LOG.LEVEL_ERROR;
       l_unexp_level  number   := FND_LOG.LEVEL_UNEXPECTED;
       l_mod_name     varchar2(2000) := 'csd.plsql.csd_repair_actual_lines_pvt.delete_repair_actual_lines';


       l_api_name               CONSTANT VARCHAR2(30)   := 'DELETE_REPAIR_ACTUAL_LINES';
       l_api_version            CONSTANT NUMBER         := 1.0;
       l_msg_count              NUMBER;
       l_msg_data               VARCHAR2(100);
       l_msg_index              NUMBER;

       l_actual_line_id         NUMBER;
       l_obj_ver_num            NUMBER;
       l_act_line_count         NUMBER;

       -- swai: 12.1 service costing uptake bug 6960295
       -- Since actual lines imported from WIP cannot be deleted, it is not
       -- necessary to pass the cost flag.  But we will do it to be consistent
       -- with CREATE and UPDATE.  If we allow deletion of actual lines from
       -- WIP in the future, then cost flag should be set to 'N' for those
       -- lines.
       l_cs_cost_flag   VARCHAR2(1) := 'Y';

      CURSOR repair_actual_lines(p_actual_line_id IN NUMBER) IS
      SELECT
         a.repair_actual_line_id,
         a.object_version_number
      FROM csd_repair_actual_lines a,
           csd_repairs b
      WHERE a.repair_line_id = b.repair_line_id
        and a.repair_actual_line_id  = p_actual_line_id;

    BEGIN

          -- Standard Start of API savepoint
          SAVEPOINT DELETE_REPAIR_ACTUAL_LINES;

          -- Standard call to check for call compatibility.
          IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                               p_api_version,
                                               l_api_name,
                                               G_PKG_NAME)
          THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

           -- Initialize message list if p_init_msg_list is set to TRUE.
           IF FND_API.to_Boolean( p_init_msg_list ) THEN
               FND_MSG_PUB.initialize;
           END IF;

           -- Initialize API return status to success
           x_return_status := FND_API.G_RET_STS_SUCCESS;

           -- Api body starts
           IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'At the Beginning of delete_repair_actual_lines');
           END IF;

           -- Dump the in parameters in the log file
           -- if the debug level > 5
           -- If fnd_profile.value('CSD_DEBUG_LEVEL') > 5 then
           /* TBD
    	   if (g_debug > 5) then
              csd_gen_utility_pvt.dump_actuals_rec
                       ( p_CSD_ACTUAL_LINES_REC => px_CSD_ACTUAL_LINES_REC);
           end if;
           */

           IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Begin Check reqd parametes');
           END IF;

           -- Check the required parameter
           CSD_PROCESS_UTIL.Check_Reqd_Param
           ( p_param_value    => px_CSD_ACTUAL_LINES_REC.repair_actual_line_id,
             p_param_name     => 'REPAIR_ACTUAL_LINE_ID',
             p_api_name       => l_api_name);

           IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'End Check reqd parametes');
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Begin Validate Repair Line id');
           END IF;

           -- Validate the repair line ID
           IF NOT( CSD_PROCESS_UTIL.Validate_rep_line_id
                           ( p_repair_line_id  => px_CSD_ACTUAL_LINES_REC.repair_line_id )) THEN
               RAISE FND_API.G_EXC_ERROR;
           END IF;

           IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'End Validate Repair Line id');
           END IF;

          --
          -- API body
          --

          -- Actual deletes allowed only for Actual lines created manually
          -- or for the ones copied from the estimates
          -- Check the actual_source_code in Repair_Actual_Lines_Rec

          IF (px_CSD_ACTUAL_LINES_REC.actual_source_code in ('MANUAL', 'ESTIMATE')) then

              -- Validate the repair actual line id against csd_repair_actual_lines
              -- If it is interfaced then raise FND_API.G_EXC_ERROR
              IF NVL(px_CSD_ACTUAL_LINES_REC.repair_actual_line_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN

                 OPEN  repair_actual_lines(px_CSD_ACTUAL_LINES_REC.repair_actual_line_id);
                 FETCH repair_actual_lines
                  INTO l_actual_line_id,
                       l_obj_ver_num;

                 IF repair_actual_lines%NOTFOUND THEN
                    FND_MESSAGE.SET_NAME('CSD','CSD_API_ACTUAL_LINES_MISSING');
                    FND_MESSAGE.SET_TOKEN('REPAIR_ACTUAL_LINE_ID',l_actual_line_id);
                    FND_MSG_PUB.ADD;
                    IF (Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level) THEN
                      FND_LOG.MESSAGE(Fnd_Log.Level_Error,l_mod_name, FALSE);
                    END IF;
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;

                IF repair_actual_lines%ISOPEN THEN
                   CLOSE repair_actual_lines;
                END IF;

              END IF;

              IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                   FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Validate Object Version Number');
              END IF;

              IF NVL(px_CSD_ACTUAL_LINES_REC.object_version_number,FND_API.G_MISS_NUM) <>l_obj_ver_num  THEN
                 IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                      FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Object Version Number does not match'
			       || ' for the Repair Actual Line ID = ' || l_actual_line_id);
                 END IF;

                 -- Modified the message name for bugfix 3281321. vkjain.
                 -- FND_MESSAGE.SET_NAME('CSD','CSD_OBJ_VER_MISMATCH');
                 FND_MESSAGE.SET_NAME('CSD','CSD_ACT_LIN_OBJ_VER_MISMATCH');
                 -- FND_MESSAGE.SET_TOKEN('REPAIR_ACTUAL_LINE_ID',l_actual_line_id);
                 FND_MSG_PUB.ADD;
                 IF (Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level) THEN
                   FND_LOG.MESSAGE(Fnd_Log.Level_Error,l_mod_name, FALSE);
                 END IF;
                 RAISE FND_API.G_EXC_ERROR;
              END IF;

              IF (px_Charges_Rec.order_header_id is not null) THEN
                 IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                      FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Repair Actual Line is Interfaced to Order Management');
                 END IF;

                 FND_MESSAGE.SET_NAME('CSD','CSD_ACT_LIN_OM_IFACE');
                 FND_MESSAGE.SET_TOKEN('REPAIR_ACTUAL_LINE_ID',l_actual_line_id);
                 FND_MSG_PUB.ADD;
                 IF (Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level) THEN
                   FND_LOG.MESSAGE(Fnd_Log.Level_Error,l_mod_name, FALSE);
                 END IF;
                 RAISE FND_API.G_EXC_ERROR;
              END IF;

              -- Call table handler CSD_REPAIR_ESTIMATE_PVT.Process_Estimate_Lines to
              -- delete the record in CS_ESTIMATE_DETAILS
              IF ( Fnd_Log.Level_Procedure >= G_debug_level) THEN
                   FND_LOG.STRING(Fnd_Log.Level_Procedure,l_mod_name,'Call process_estimate_lines to delete charge line');
              END IF;

              CSD_REPAIR_ESTIMATE_PVT.PROCESS_ESTIMATE_LINES
                 ( p_api_version           =>  1.0 ,
                   p_commit                =>  fnd_api.g_false,
                   p_init_msg_list         =>  fnd_api.g_true,
                   p_validation_level      =>  fnd_api.g_valid_level_full,
                   p_action                =>  'DELETE',
                   -- swai: 12.1 service costing uptake bug 6960295
                   p_cs_cost_flag          =>  l_cs_cost_flag,
                   x_Charges_Rec           =>  px_charges_rec,
                   x_return_status         =>  x_return_status,
                   x_msg_count             =>  x_msg_count,
                   x_msg_data              =>  x_msg_data);

            IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
              RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF ( Fnd_Log.Level_Procedure >= G_debug_level) THEN
                 FND_LOG.STRING(Fnd_Log.Level_Procedure,l_mod_name,'Call to  CSD_REPAIR_ACTUAL_LINES_PKG.Delete_Row');
            END IF;

            BEGIN

            -- Invoke table handler(CSD_REPAIR_ACTUAL_LINES_PKG.Delete_Row)
            CSD_REPAIR_ACTUAL_LINES_PKG.Delete_Row(
                p_REPAIR_ACTUAL_LINE_ID  => px_CSD_ACTUAL_LINES_REC.REPAIR_ACTUAL_LINE_ID
               ,p_OBJECT_VERSION_NUMBER  => px_CSD_ACTUAL_LINES_REC.OBJECT_VERSION_NUMBER);

            EXCEPTION
                WHEN OTHERS THEN
                   IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                       FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'Others exception in CSD_REPAIR_ACTUAL_LINES_PKG.Delete_Row Call :'||SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1,255));
                   END IF;
                   x_return_status := FND_API.G_RET_STS_ERROR;
            END;

              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_ERROR;
              END IF;

          END IF;
          --
          -- End of API body
          --

          -- Standard check of p_commit.
          IF FND_API.To_Boolean( p_commit ) THEN
               COMMIT WORK;
          END IF;

          -- Standard call to get message count and IF count is  get message info.
          FND_MSG_PUB.Count_And_Get
               (p_count  =>  x_msg_count,
                p_data   =>  x_msg_data );
    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
              IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                  FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'In FND_API.G_EXC_ERROR exception');
              END IF;
              x_return_status := FND_API.G_RET_STS_ERROR ;
              ROLLBACK TO DELETE_REPAIR_ACTUAL_LINES;
              FND_MSG_PUB.Count_And_Get
                  (p_count  =>  x_msg_count,
                   p_data   =>  x_msg_data );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                  FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'In FND_API.G_EXC_UNEXPECTED_ERROR exception ');
              END IF;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              ROLLBACK TO DELETE_REPAIR_ACTUAL_LINES;
              FND_MSG_PUB.Count_And_Get
                    ( p_count  =>  x_msg_count,
                      p_data   =>  x_msg_data );
        WHEN OTHERS THEN
              IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                  FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'In OTHERS exception');
                  FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'Sql Err Msg :'||SQLERRM );
              END IF;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              ROLLBACK TO DELETE_REPAIR_ACTUAL_LINES;
                  IF  FND_MSG_PUB.Check_Msg_Level
                      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                  THEN
                      FND_MSG_PUB.Add_Exc_Msg
                      (G_PKG_NAME ,
                       l_api_name  );
                  END IF;
                      FND_MSG_PUB.Count_And_Get
                      (p_count  =>  x_msg_count,
                       p_data   =>  x_msg_data );

End DELETE_REPAIR_ACTUAL_LINES;


/*--------------------------------------------------------------------*/
/* procedure name: LOCK_REPAIR_ACTUAL_LINES                           */
/* description : procedure used to Delete Repair Actuals              */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/* Called from : Depot Repair Actuals UI                              */
/* Input Parm  :                                                      */
/*   p_api_version       NUMBER    Req Api Version number             */
/*   p_init_msg_list     VARCHAR2  Opt Initialize message stack       */
/*   p_commit            VARCHAR2  Opt Commits in API                 */
/*   p_validation_level  NUMBER    Opt validation steps               */
/*   px_CSD_ACTUAL_LINES_REC REC   Req Actuals lines Record           */
/* Output Parm :                                                      */
/*   x_return_status     VARCHAR2      Return status after the call.  */
/*   x_msg_count         NUMBER        Number of messages in stack    */
/*   x_msg_data          VARCHAR2      Mesg. text if x_msg_count >= 1 */
/* Change Hist :                                                      */
/*   08/11/03  travikan  Initial Creation.                            */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
PROCEDURE LOCK_REPAIR_ACTUAL_LINES(
    P_Api_Version           IN            NUMBER,
    P_Commit                IN            VARCHAR2,
    P_Init_Msg_List         IN            VARCHAR2,
    p_validation_level      IN            NUMBER,
    px_CSD_ACTUAL_LINES_REC IN OUT NOCOPY CSD_ACTUAL_LINES_REC_TYPE,
    X_Return_Status         OUT    NOCOPY VARCHAR2,
    X_Msg_Count             OUT    NOCOPY NUMBER,
    X_Msg_Data              OUT    NOCOPY VARCHAR2
    )

 IS
     -- Variables used in FND Log
     l_stat_level   number   := FND_LOG.LEVEL_STATEMENT;
     l_proc_level   number   := FND_LOG.LEVEL_PROCEDURE;
     l_event_level  number   := FND_LOG.LEVEL_EVENT;
     l_excep_level  number   := FND_LOG.LEVEL_EXCEPTION;
     l_error_level  number   := FND_LOG.LEVEL_ERROR;
     l_unexp_level  number   := FND_LOG.LEVEL_UNEXPECTED;
     l_mod_name     varchar2(2000) := 'csd.plsql.csd_repair_actual_lines_pvt.lock_repair_actual_lines';

     l_api_name               CONSTANT VARCHAR2(30)   := 'LOCK_REPAIR_ACTUAL_LINES';
     l_api_version            CONSTANT NUMBER         := 1.0;
     l_msg_count              NUMBER;
     l_msg_data               VARCHAR2(100);
     l_msg_index              NUMBER;

    BEGIN
          -- Standard Start of API savepoint
          SAVEPOINT LOCK_REPAIR_ACTUAL_LINES;

          -- Standard call to check for call compatibility.
          IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                               p_api_version,
                                               l_api_name,
                                               G_PKG_NAME)
          THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

           -- Initialize message list if p_init_msg_list is set to TRUE.
           IF FND_API.to_Boolean( p_init_msg_list ) THEN
               FND_MSG_PUB.initialize;
           END IF;

           -- Initialize API return status to success
           x_return_status := FND_API.G_RET_STS_SUCCESS;

           -- Api body starts
           IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'At the Beginning of lock_repair_actual_lines');
           END IF;
           -- Dump the in parameters in the log file
           -- if the debug level > 5
           -- If fnd_profile.value('CSD_DEBUG_LEVEL') > 5 then
--            if (g_debug > 5) then
--               csd_gen_utility_pvt.dump_actuals_rec
--                        ( p_CSD_ACTUAL_LINES_REC => px_CSD_ACTUAL_LINES_REC);
--            end if;

           IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'Begin Check reqd parameter');
           END IF;

           -- Check the required parameter
           CSD_PROCESS_UTIL.Check_Reqd_Param
           ( p_param_value    => px_CSD_ACTUAL_LINES_REC.repair_actual_id,
             p_param_name     => 'REPAIR_ACTUAL_LINE_ID',
             p_api_name       => l_api_name);

           IF ( Fnd_Log.Level_Statement >= G_debug_level) THEN
                FND_LOG.STRING(Fnd_Log.Level_Statement,l_mod_name,'End Check reqd parameter');
           END IF;

          --
          -- API body
          --
          IF ( Fnd_Log.Level_Procedure >= G_debug_level) THEN
                FND_LOG.STRING(Fnd_Log.Level_Procedure,l_mod_name,'Call to CSD_REPAIR_ACTUAL_LINES_PKG.Lock_Row');
          END IF;

          BEGIN

          -- Invoke table handler(CSD_REPAIR_ACTUAL_LINES_PKG.Lock_Row)
          CSD_REPAIR_ACTUAL_LINES_PKG.Lock_Row(
              p_REPAIR_ACTUAL_LINE_ID  => px_CSD_ACTUAL_LINES_REC.REPAIR_ACTUAL_LINE_ID
             ,p_OBJECT_VERSION_NUMBER  => px_CSD_ACTUAL_LINES_REC.OBJECT_VERSION_NUMBER);

          EXCEPTION
              WHEN OTHERS THEN
                  IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                      FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'Others exception in CSD_REPAIR_ACTUAL_LINES_PKG.Lock_Row Call :'||SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1,255));
                  END IF;
                   x_return_status := FND_API.G_RET_STS_ERROR;
          END;

              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_ERROR;
              END IF;

          --
          -- End of API body
          --

          -- Standard check of p_commit.
          IF FND_API.To_Boolean( p_commit ) THEN
               COMMIT WORK;
          END IF;

          -- Standard call to get message count and IF count is  get message info.
          FND_MSG_PUB.Count_And_Get
               (p_count  =>  x_msg_count,
                p_data   =>  x_msg_data );
    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
              IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                  FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'In FND_API.G_EXC_ERROR exception');
              END IF;
              x_return_status := FND_API.G_RET_STS_ERROR ;
              ROLLBACK TO LOCK_REPAIR_ACTUAL_LINES;
              FND_MSG_PUB.Count_And_Get
                  (p_count  =>  x_msg_count,
                   p_data   =>  x_msg_data );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                  FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'In FND_API.G_EXC_UNEXPECTED_ERROR exception ');
              END IF;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              ROLLBACK TO LOCK_REPAIR_ACTUAL_LINES;
              FND_MSG_PUB.Count_And_Get
                    ( p_count  =>  x_msg_count,
                      p_data   =>  x_msg_data );
        WHEN OTHERS THEN
              IF ( Fnd_Log.Level_Exception >= G_debug_level) THEN
                  FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'In OTHERS exception');
                  FND_LOG.STRING(Fnd_Log.Level_Exception,l_mod_name,'Sql Err Msg :'||SQLERRM );
              END IF;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              ROLLBACK TO LOCK_REPAIR_ACTUAL_LINES;
                  IF  FND_MSG_PUB.Check_Msg_Level
                      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                  THEN
                      FND_MSG_PUB.Add_Exc_Msg
                      (G_PKG_NAME ,
                       l_api_name  );
                  END IF;
                      FND_MSG_PUB.Count_And_Get
                      (p_count  =>  x_msg_count,
                       p_data   =>  x_msg_data );

    End LOCK_REPAIR_ACTUAL_LINES;

End CSD_REPAIR_ACTUAL_LINES_PVT;

/
