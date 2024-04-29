--------------------------------------------------------
--  DDL for Package Body INV_MAINTAIN_RESERVATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MAINTAIN_RESERVATION_PUB" AS
/* $Header: INVPMRVB.pls 120.26.12010000.9 2009/08/05 09:08:40 mporecha ship $*/

g_dummy_sn_tbl       inv_reservation_global.serial_number_tbl_type;

-- CodeReview.SU.03 Define a global variable for l_Debug
g_debug       Number := Nvl(Fnd_Profile.Value('INV_DEBUG_TRACE'),0);


g_pkg_name CONSTANT VARCHAR2(30) := 'INV_MAINTAIN_RESERVATION_PUB';
g_version_printed   BOOLEAN      := FALSE;
-- Global Constants for variables  used in FND Log
-- CodeReview.SU.01  : Commenting following constants
-- G_statement_level   constant number   := FND_LOG.LEVEL_STATEMENT;
-- G_procedure_level   constant number   := FND_LOG.LEVEL_PROCEDURE;
-- G_event_level       constant number   := FND_LOG.LEVEL_EVENT;
-- G_exception_level   constant number   := FND_LOG.LEVEL_EXCEPTION;
-- G_error_level       constant number   := FND_LOG.LEVEL_ERROR;
-- G_unexp_level       constant number   := FND_LOG.LEVEL_UNEXPECTED;
-- G_Current_Debug_Level Constant Number := Fnd_Log.G_CURRENT_RUNTIME_LEVEL;

-- Define a cursor ref variable
TYPE query_cur_ref_type IS REF CURSOR;


PROCEDURE mydebug (p_message IN VARCHAR2
                  ,p_module_name IN VARCHAR2
                  ,p_level IN NUMBER)
 IS
BEGIN
      IF g_version_printed THEN
        inv_log_util.TRACE ('$Header: INVPMRVB.pls 120.26.12010000.9 2009/08/05 09:08:40 mporecha ship $',g_pkg_name||'.'||p_module_name, p_level);
      END IF;
      inv_log_util.TRACE (p_message,g_pkg_name||'.'||p_module_name, p_level);

END mydebug;


/*-------------------------------------------------------------------------------------*/
/* Procedure Name: FND_LOG_DEBUG                                                       */
/* Description   : Logs the debug message using fnd_log API's                          */
/* Called from   : Called from API                                                     */
/*                                                                                     */
/* STANDARD PARAMETERS                                                                 */
/*   In Parameters :                                                                   */
/*      p_severity_level Required    Severity level                                    */
/*      p_module_name    Required    Module name                                       */
/*      p_message        Required    Debug message that needs to be logged             */
/*   Output Parameters:                                                                */
/* NON-STANDARD PARAMETERS                                                             */
/*   In Parameters                                                                     */
/*   Out parameters                                                                    */
/* Change Hist :                                                                       */
/*-------------------------------------------------------------------------------------*/


/*Procedure Fnd_Log_Debug
    ( p_severity_level IN NUMBER,
      p_module_name    IN VARCHAR2,
      p_message        IN VARCHAR2) IS
BEGIN
-- CodeReview.SU.02 Replaced global variables with fnd_log constants
IF p_severity_level = Fnd_Log.Level_Statement THEN
   IF ( Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level) THEN
      Fnd_Log.String(p_severity_level,p_module_name,p_message);
   END IF;
ELSIF p_severity_level = Fnd_Log.Level_Procedure THEN
  IF ( Fnd_Log.Level_procedure >= Fnd_Log.G_Current_Runtime_level) THEN
      FND_LOG.STRING(p_severity_level,p_module_name,p_message);
  END IF;
ELSIF p_severity_level = Fnd_Log.Level_Event THEN
  IF ( Fnd_Log.Level_Event >= Fnd_Log.G_Current_Runtime_Level) THEN
      FND_LOG.STRING(p_severity_level,p_module_name,p_message);
  END IF;
ELSIF p_severity_level = Fnd_Log.Level_Exception THEN
  IF ( Fnd_Log.Level_Exception >= Fnd_Log.G_current_Runtime_Level) Then
      FND_LOG.STRING(p_severity_level,p_module_name,p_message);
  END IF;
ELSIF p_severity_level = Fnd_Log.Level_Error THEN
  IF ( Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_level) THEN
      FND_LOG.STRING(p_severity_level,p_module_name,p_message);
  END IF;
ELSIF p_severity_level = Fnd_Log.Level_UnExpected THEN
  IF ( Fnd_Log.Level_Unexpected >= Fnd_Log.G_Current_Runtime_level) THEN
      FND_LOG.STRING(p_severity_level,p_module_name,p_message);
  END IF;
END IF;

END Fnd_Log_Debug;*/

-- Local procedures to check missing parameters
-- Check_Reqd_Param is overloaded procedures, one for each type of scalar variabls
-- like date, varchar2, number
PROCEDURE Check_Reqd_Param (
 p_param_value IN NUMBER,
 p_param_name  IN VARCHAR2,
 p_api_name    IN VARCHAR2
 )
IS
  l_debug    NUMBER;
  c_api_name CONSTANT VARCHAR2(30) := 'Check_Reqd_Param';
BEGIN
  IF (g_debug IS NULL) THEN
      g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  END IF;

  l_debug := g_debug;

  IF (l_debug = 1) THEN
     mydebug('Checking API ' || p_api_name || ' , ' || p_param_name || ': ' || p_param_value, c_api_name, 9);
  END IF;

  IF (NVL(p_param_value,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM) THEN
     IF (l_debug = 1) THEN
        mydebug('In ' || p_api_name ||', '|| p_param_name ||' is required parameter, value is g_miss_num', c_api_name, 9);
     END IF;
     FND_MESSAGE.SET_NAME('INV','INV_API_MISSING_PARAM');
     FND_MESSAGE.SET_TOKEN('API_NAME',p_api_name);
     FND_MESSAGE.SET_TOKEN('MISSING_PARAM',p_param_name);
     FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR;
  END IF;
END Check_Reqd_Param;

PROCEDURE Check_Reqd_Param (
p_param_value     IN VARCHAR2,
p_param_name  IN VARCHAR2,
p_api_name  IN VARCHAR2
)
IS
  l_debug    NUMBER;
  c_api_name CONSTANT VARCHAR2(30) := 'Check_Reqd_Param';
BEGIN
  IF (g_debug IS NULL) THEN
      g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  END IF;

  l_debug := g_debug;

  IF (l_debug = 1) THEN
     mydebug('Checking API ' || p_api_name || ' , ' || p_param_name || ': ' || p_param_value, c_api_name, 9);
  END IF;

  IF (NVL(p_param_value,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR) THEN
     IF (l_debug = 1) THEN
        mydebug('In ' || p_api_name || ', ' || p_param_name || ' is required parameter, value is g_miss_char', c_api_name, 9);
     END IF;

     -- New Message - 001
     -- $MISSING_PARAM is a required parameter.
     FND_MESSAGE.SET_NAME('INV','INV_API_MISSING_PARAM');
     FND_MESSAGE.SET_TOKEN('API_NAME',p_api_name);
     FND_MESSAGE.SET_TOKEN('MISSING_PARAM',p_param_name);
     FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR;
  END IF;
END Check_Reqd_Param;

PROCEDURE Check_Reqd_Param (
p_param_value     IN DATE,
p_param_name  IN VARCHAR2,
p_api_name  IN VARCHAR2
)
IS
  l_debug    NUMBER;
  c_api_name CONSTANT VARCHAR2(30) := 'CHECK_REQD_PARAM';
BEGIN
  IF (g_debug IS NULL) THEN
      g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  END IF;

  l_debug := g_debug;

  IF (l_debug = 1) THEN
     mydebug('Checking API ' || p_api_name || ' , ' || p_param_name || ': ' ||
         TO_CHAR(p_param_value, 'YYYY-MM-DD:DD:SS'), c_api_name, 9);
  END IF;

  IF (NVL(p_param_value,FND_API.G_MISS_DATE) = FND_API.G_MISS_DATE) THEN
     IF (l_debug = 1) THEN
        mydebug('In ' || p_api_name || ', ' || p_param_name || ' is required parameter, value is g_miss_date',
            c_api_name, 9);
     END IF;

     FND_MESSAGE.SET_NAME('INV','INV_API_MISSING_PARAM');
     FND_MESSAGE.SET_TOKEN('API_NAME',p_api_name);
     FND_MESSAGE.SET_TOKEN('MISSING_PARAM',p_param_name);
     FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR;
  END IF;
END Check_Reqd_Param;


   -- procedure
   --   reduce_reservation
   --
   -- description
   --   api will handle changes to the resevationl record based on the changes to the supply or
   --   demand record changes.
   --
   -- Input Paramters
   --   p_api_version_number   Number    API version number (current version is 1.0 Standard in parameter)
   --   p_Init_Msg_lst         Varcahar2(1) (Flag for initialize message stack, standard input parameter)
   --   p_Mtl_Maintain_Rsv_Tbl    Inv_Reservations_Global.mtl_Maintain_rsv_tbl_type
   --   p_Delete_Flag          Varchar2(1)  Accepted values 'Y', 'N' and Null. Null value is equivalent to 'N'
   --   p_Sort_By_Criteria     Number
   --Out Parameters
   --   x_Return_Status        Varchar2(1) (Return Status of API, Standard out parameter)
   --   x_Msg_Count            Number (Message count from the stack, standard out parameter)
   --   x_Msg_Data             Varchar2(255) (Message from message stack, standard out parameter)
   --   x_Quantity_Modified    Number (Quantity that has been reduced or deleted by API)


   Procedure reduce_reservation (
        p_api_version_number   in   number,
        p_init_msg_lst         in   varchar2,
        x_return_status        out  nocopy varchar2,
        x_msg_count            out  nocopy number,
        x_msg_data             out  nocopy varchar2,
        p_mtl_maintain_rsv_rec in   inv_reservation_global.mtl_maintain_rsv_rec_type,
        p_delete_flag          in   varchar2,
        p_sort_by_criteria     in   number,
        x_quantity_modified    out  nocopy number ) is

       -- define constants for api version and api name
       c_api_version_number constant number       := 1.0;
       c_api_name           constant varchar2(30) := 'reduce_reservation';
       c_module_name        constant varchar2(2000) := 'inv.plsql.inv_maintain_reservations.reduce_reservation';
       c_debug_enabled      constant number := 1 ;
       c_action_supply      constant number := 0;
       c_action_demand      constant number := 1;
       c_cancel_order_no    constant number := inv_reservation_global.g_cancel_order_no ;

       -- l_debug                         number      := nvl(fnd_profile.value('inv_debug_trace'), 0);
       l_fnd_log_message               varchar2(2000);
       l_rsv_rec                       inv_reservation_global.mtl_reservation_rec_type;
       l_query_input                   inv_reservation_global.mtl_reservation_rec_type;
       l_mtl_reservation_tbl           inv_reservation_global.mtl_reservation_tbl_type ;
       l_mtl_reservation_tbl_count     number ;
       l_sort_by_criteria              number ;
       l_error_code                    number ;

       -- following variables for calling transfer reservation api
       l_is_transfer_supply            varchar2(1);
       l_original_rsv_rec              inv_reservation_global.mtl_reservation_rec_type;
       -- convert_rsv_rec is used to convert expected_qty to primary_expected_uom_code
       l_convert_rsv_rec               inv_reservation_global.mtl_reservation_rec_type;
       l_to_rsv_rec                    inv_reservation_global.mtl_reservation_rec_type;
       l_original_serial_number        inv_reservation_global.serial_number_tbl_type;
       l_to_serial_number              inv_reservation_global.serial_number_tbl_type;
       l_reservation_id                number ;
       l_primary_uom_code              varchar2(10);
       l_primary_expected_qty          number ;
       l_to_primary_transaction_qty    number;
       l_sum_primary_reservation_qty   number;
       l_primary_need_reduced_qty      number ;
       l_from_primary_transaction_qty  number;
       l_msg_index_out                 number;
       l_staged_rec_exists             varchar2(1) ;

       l_return_status     varchar2(1) := fnd_api.g_ret_sts_success;
       l_msg_count         number;
       l_msg_data          varchar2(1000);
       l_wip_entity_type_id   number;
       l_wip_job_type      varchar2(15);
       l_source_header_id  number;

   begin
      -- call fnd_log api in the begining of the api
      l_fnd_log_message := 'begining of procedure :';
      -- fnd_log_debug(fnd_log.level_procedure,c_module_name, l_fnd_log_message );

      -- log message in trace file
      if g_debug= c_debug_enabled then
         --codereview.su.04 : print package name once at the begning of api
         g_version_printed := true ;
         mydebug(l_fnd_log_message,c_api_name,9);
         g_version_printed := false ;

      end if;

      -- initialize x_return_status variable to success in the begning of api
      x_return_status := fnd_api.g_ret_sts_success;
      --  standard call to check for call compatibility
      if not fnd_api.compatible_api_call(c_api_version_number
           , p_api_version_number
           , c_api_name
           , g_pkg_name
           ) then
          raise fnd_api.g_exc_unexpected_error;
       end if;

       --  initialize message list. null value for p_init_msg_lst variable will be treated as 'n'
       -- codereview.su.05  remove nvl function
       if fnd_api.to_boolean(p_init_msg_lst) then
          fnd_msg_pub.initialize;
       end if;

       if (g_debug= c_debug_enabled) then
          mydebug ('before checking for required parameters' ,c_api_name,1);
       end if;

       -- check for required parameters
       -- action column is a required column
       check_reqd_param (
          p_param_value =>  p_mtl_maintain_rsv_rec.action,
          p_param_name =>  'p_mtl_maintain_rsv_rec.action',
          p_api_name    =>  c_api_name );

       -- organization id is a required column
       check_reqd_param (
          p_param_value =>  p_mtl_maintain_rsv_rec.organization_id,
          p_param_name =>  'p_mtl_maintain_rsv_rec.organization_id',
          p_api_name    =>  c_api_name );

       -- inventory item id is a required column
       check_reqd_param (
          p_param_value =>  p_mtl_maintain_rsv_rec.inventory_item_id,
          p_param_name =>  'p_mtl_maintain_rsv_rec.inventory_item_id',
          p_api_name    =>  c_api_name );


       -- get wip entity type if the supply is wip
       if (p_mtl_maintain_rsv_rec.action = c_action_supply) then
          l_source_header_id := p_mtl_maintain_rsv_rec.supply_source_header_id;
       elsif (p_mtl_maintain_rsv_rec.action = c_action_demand) then
          l_source_header_id := p_mtl_maintain_rsv_rec.demand_source_header_id;
       end if;

       if (p_mtl_maintain_rsv_rec.supply_source_type_id = inv_reservation_global.g_source_type_wip) then
           if (g_debug= c_debug_enabled) then
              mydebug ('before calling get_wip_entity_type' , c_api_name, 9);
           end if;
           inv_reservation_pvt.get_wip_entity_type
          (  p_api_version_number           => 1.0
           , p_init_msg_lst                 => fnd_api.g_false
           , x_return_status                => l_return_status
           , x_msg_count                    => l_msg_count
           , x_msg_data                     => l_msg_data
           , p_organization_id              => p_mtl_maintain_rsv_rec.organization_id
           , p_item_id                      => p_mtl_maintain_rsv_rec.inventory_item_id
           , p_source_type_id               => null
           , p_source_header_id             => l_source_header_id
           , p_source_line_id               => null
           , p_source_line_detail           => null
           , x_wip_entity_type              => l_wip_entity_type_id
           , x_wip_job_type                 => l_wip_job_type
          );

           if (g_debug =  c_debug_enabled) then
               mydebug('status return from get_wip_entity = ' || l_return_status, c_api_name, 9);
               mydebug('l_wip_entity_type = ' || l_wip_entity_type_id, c_api_name, 9);
           end if;
           if (l_return_status = fnd_api.g_ret_sts_error) then
               raise fnd_api.g_exc_error;
           elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
               raise fnd_api.g_exc_unexpected_error;
           end if;
       end if;

       if (g_debug = c_debug_enabled) then
          mydebug('p_delete_flag = '|| p_delete_flag ,c_api_name,1);
          mydebug('action = ' || p_mtl_maintain_rsv_rec.action, c_api_name,1);
       end if;

       if upper(nvl(p_delete_flag,'N')) = 'N' then
          -- codereview.su.06. swap action types for sorting criteria
          if p_mtl_maintain_rsv_rec.action = c_action_demand then
            if p_sort_by_criteria is null then
               l_sort_by_criteria := inv_reservation_global.g_query_supply_rcpt_date_asc;
            else
               l_sort_by_criteria := p_sort_by_criteria ;
            end if;
          elsif p_mtl_maintain_rsv_rec.action = c_action_supply then
             if p_sort_by_criteria is null then
                l_sort_by_criteria := inv_reservation_global.g_query_demand_ship_date_desc;
            else
               l_sort_by_criteria := p_sort_by_criteria ;
            end if;
          end if;
       elsif upper(nvl(p_delete_flag,'N')) = 'Y' then
          -- if delete flag is 'y' sort by criteria will be same as what user has passed.
          l_sort_by_criteria := p_sort_by_criteria;
       end if;

       -- assign values to l_query_input record.
       l_query_input.organization_id := p_mtl_maintain_rsv_rec.organization_id;
       l_query_input.inventory_item_id := p_mtl_maintain_rsv_rec.inventory_item_id ;

       if (g_debug = c_debug_enabled) then
          mydebug('checking action ' ,c_api_name,1);
       end if;

       -- check if action to be performed on supply or demand
       if p_mtl_maintain_rsv_rec.action = c_action_supply then
          if (g_debug = c_debug_enabled) then
             mydebug('action is supply' ,c_api_name,1);
             mydebug('supply source type id = ' || p_mtl_maintain_rsv_rec.supply_source_type_id ,c_api_name,1);
          end if;

          -- if action is supply then supply attributes should be passed
          -- confirm with vishy that this logic is correct
          -- supply source type is required column
          check_reqd_param (
             p_param_value =>  p_mtl_maintain_rsv_rec.supply_source_type_id,
             p_param_name =>  'p_mtl_maintain_rsv_rec.supply_source_type_id',
             p_api_name    =>  c_api_name);

          -- supply source header is required column
          -- codereview.su.07. source_header_id is required for following source types
          -- po, wip, int req, ext req, asn, intrasit
          -- not required for inventory source type
          if (p_mtl_maintain_rsv_rec.supply_source_type_id <> inv_reservation_global.g_source_type_inv) then
             check_reqd_param (
                p_param_value =>  p_mtl_maintain_rsv_rec.supply_source_header_id,
                p_param_name =>  'p_mtl_maintain_rsv_rec.supply_source_header',
                p_api_name    =>  c_api_name );
          end if; -- check for supply source header id

          -- suppply source line is required column
          -- codereview.su.07. source_line_id is required for following source types
          -- po, int req, ext req, asn, intrasit
          -- not required for inventory,wip
          if (p_mtl_maintain_rsv_rec.supply_source_type_id = inv_reservation_global.g_source_type_wip
             and l_wip_entity_type_id in (inv_reservation_global.g_wip_source_type_batch
                                         ,inv_reservation_global.g_wip_source_type_cmro)) then
             check_reqd_param (
                p_param_value =>  p_mtl_maintain_rsv_rec.supply_source_line_id,
                p_param_name =>  'p_mtl_maintain_rsv_rec.supply_source_line_id',
                p_api_name    =>  c_api_name );
          elsif (p_mtl_maintain_rsv_rec.supply_source_type_id
          not in
          (inv_reservation_global.g_source_type_inv,
           inv_reservation_global.g_source_type_wip,
           inv_reservation_global.g_source_type_account,
           inv_reservation_global.g_source_type_account_alias)) then
             check_reqd_param (
                p_param_value =>  p_mtl_maintain_rsv_rec.supply_source_line_id,
                p_param_name =>  'p_mtl_maintain_rsv_rec.supply_source_line_id',
                p_api_name    =>  c_api_name );

          end if; -- check for supply source line id

          -- suppply source line detail required column
          -- codereview.su.07. source_line_detail is required for following source types
          -- asn
          if p_mtl_maintain_rsv_rec.supply_source_type_id = inv_reservation_global.g_source_type_asn then
             check_reqd_param (
                p_param_value =>  p_mtl_maintain_rsv_rec.supply_source_line_detail,
                p_param_name =>  'p_mtl_maintain_rsv_rec.supply_source_line_detail',
                p_api_name    =>  c_api_name );
          end if; -- check for supply source line id

          -- now assign values to l_query_input record
          l_query_input.supply_source_type_id   := p_mtl_maintain_rsv_rec.supply_source_type_id ;
          l_query_input.supply_source_header_id := p_mtl_maintain_rsv_rec.supply_source_header_id ;
          l_query_input.supply_source_line_id   := p_mtl_maintain_rsv_rec.supply_source_line_id ;
          -- codereview.su.08 : should pass supply source line detail value
          l_query_input.supply_source_line_detail := p_mtl_maintain_rsv_rec.supply_source_line_detail ;

       elsif p_mtl_maintain_rsv_rec.action = c_action_demand then
          -- if action is demand then demand attributes should be passed
          -- demand source type is required column
          -- dbms_output.put_line('action is demand');
          if (g_debug = c_debug_enabled) then
             mydebug('action is demand' ,c_api_name,1);
          end if;

          check_reqd_param (
             p_param_value =>  p_mtl_maintain_rsv_rec.demand_source_type_id,
             p_param_name =>  'p_mtl_maintain_rsv_rec.demand_source_type_id',
             p_api_name    =>  c_api_name );

          -- demand source header is required column
          -- codereview.su.07. source_header_id is not required for inv source types
          if p_mtl_maintain_rsv_rec.demand_source_type_id <> inv_reservation_global.g_source_type_inv then
             check_reqd_param (
                p_param_value =>  p_mtl_maintain_rsv_rec.demand_source_header_id,
                p_param_name =>  'p_mtl_maintain_rsv_rec.demand_source_header',
                p_api_name    =>  c_api_name );
          end if; -- check source header id

          -- demandy source line is required column
          -- codereview.su.07. demand_source_line_id is not required for inv source types
          if (p_mtl_maintain_rsv_rec.demand_source_type_id = inv_reservation_global.g_source_type_wip
              and l_wip_entity_type_id in (inv_reservation_global.g_wip_source_type_cmro,
                  inv_reservation_global.g_wip_source_type_batch)) then
             check_reqd_param (
                p_param_value =>  p_mtl_maintain_rsv_rec.demand_source_line_id,
                p_param_name =>  'p_mtl_maintain_rsv_rec.demand_source_line_id',
                p_api_name    =>  c_api_name );
          elsif (p_mtl_maintain_rsv_rec.demand_source_type_id not in
               (inv_reservation_global.g_source_type_inv,inv_reservation_global.g_source_type_account,
                inv_reservation_global.g_source_type_account_alias)) then
             check_reqd_param (
                p_param_value =>  p_mtl_maintain_rsv_rec.demand_source_line_id,
                p_param_name =>  'p_mtl_maintain_rsv_rec.demand_source_line_id',
                p_api_name    =>  c_api_name );
          end if; -- check demand source line id

          -- now assign values to l_query_input record
          l_query_input.demand_source_type_id   := p_mtl_maintain_rsv_rec.demand_source_type_id ;
          l_query_input.demand_source_header_id := p_mtl_maintain_rsv_rec.demand_source_header_id ;
          l_query_input.demand_source_line_id   := p_mtl_maintain_rsv_rec.demand_source_line_id ;
          -- codereview.su.09 : should pass demand source line detail value
          l_query_input.demand_source_line_detail := p_mtl_maintain_rsv_rec.demand_source_line_detail ;

       else
          if (g_debug = c_debug_enabled) then
             mydebug('invalid param value' ,c_api_name,1);
          end if;
          -- new message 002
          -- "invalid value for parameter $param_name : $param_value
          fnd_message.set_name('inv','inv_api_invalid_param_value');
          fnd_message.set_token('param_name','action');
          fnd_message.set_token('param_value',p_mtl_maintain_rsv_rec.action);
          fnd_msg_pub.add;
          raise fnd_api.g_exc_error;

       end if;
       -- query the reservation records for supply based on sort by criteria passed by user.

       if (g_debug= c_debug_enabled) then
          mydebug ('calling query reservation' ,c_api_name,1);
       end if;

       IF (p_mtl_maintain_rsv_rec.project_id IS NOT NULL AND
           p_mtl_maintain_rsv_rec.project_id <> fnd_api.g_miss_num) THEN
            l_query_input.project_id := p_mtl_maintain_rsv_rec.project_id;
       END IF;

       IF (p_mtl_maintain_rsv_rec.task_id IS NOT NULL AND
           p_mtl_maintain_rsv_rec.task_id<> fnd_api.g_miss_num) THEN
            l_query_input.task_id := p_mtl_maintain_rsv_rec.task_id;
       END IF;

       inv_reservation_pvt.query_reservation(
          p_api_version_number        => 1.0,
          p_init_msg_lst              => p_init_msg_lst,
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data,
          p_query_input               => l_query_input,
          p_sort_by_req_date          => p_sort_by_criteria,
          p_cancel_order_mode         => c_cancel_order_no,
          x_mtl_reservation_tbl       => l_mtl_reservation_tbl,
          x_mtl_reservation_tbl_count => l_mtl_reservation_tbl_count,
          x_error_code                => l_error_code) ;

       if (g_debug = c_debug_enabled) then
          mydebug('return status after calling query reservations'||x_return_status,c_api_name,1);
          mydebug('totol number of records returned' || l_mtl_reservation_tbl_count, c_api_name,1);
       end if;

       -- check if query reservation has raised any errors, if so raise exception
       if x_return_status = fnd_api.g_ret_sts_error then
          l_fnd_log_message := 'error while calling query_reservation api :';
          -- fnd_log_debug(fnd_log.level_error,c_module_name, l_fnd_log_message );

          if g_debug= c_debug_enabled then
            mydebug(l_fnd_log_message, c_api_name,9);
          end if;

          raise fnd_api.g_exc_error;
       elsif x_return_status = fnd_api.g_ret_sts_unexp_error then
          l_fnd_log_message := 'error while calling query_reservation api :';
          -- fnd_log_debug(fnd_log.level_error,c_module_name, l_fnd_log_message );

          if g_debug = c_debug_enabled then
            mydebug(l_fnd_log_message, c_api_name,9);
          end if;
          raise fnd_api.g_exc_unexpected_error;
       end if;

       -- check if there are any records returned by query_reservation
       if l_mtl_reservation_tbl_count <= 0 then
          l_fnd_log_message := 'there are no records returned by query_reservation api' ;
          -- fnd_log_debug(fnd_log.level_procedure,c_module_name, l_fnd_log_message );
          if g_debug = c_debug_enabled then
            mydebug(l_fnd_log_message, c_api_name,9);
          end if;
          if p_mtl_maintain_rsv_rec.action = c_action_supply then
             l_fnd_log_message := 'reservation action type is supply' ;
             -- fnd_log_debug(fnd_log.level_procedure,c_module_name, l_fnd_log_message );
             if g_debug = c_debug_enabled then
               mydebug(l_fnd_log_message, c_api_name,9);
             end if;
             l_fnd_log_message := 'supply source type id is :' || p_mtl_maintain_rsv_rec.supply_source_type_id ;
             -- fnd_log_debug(fnd_log.level_procedure,c_module_name, l_fnd_log_message );
             if g_debug= c_debug_enabled then
               mydebug(l_fnd_log_message, c_api_name,9);
             end if;
             l_fnd_log_message := 'supply source header id is:'||p_mtl_maintain_rsv_rec.supply_source_header_id;
             -- fnd_log_debug(fnd_log.level_procedure,c_module_name, l_fnd_log_message );
             if g_debug= c_debug_enabled then
               mydebug(l_fnd_log_message, c_api_name,9);
             end if;
             l_fnd_log_message := 'supply source line id is:'||p_mtl_maintain_rsv_rec.supply_source_line_id;
             -- fnd_log_debug(fnd_log.level_procedure,c_module_name, l_fnd_log_message );
             if g_debug= c_debug_enabled then
               mydebug(l_fnd_log_message, c_api_name,9);
             end if;
          else
             l_fnd_log_message := 'reservation action type is demand' ;
             -- fnd_log_debug(fnd_log.level_procedure,c_module_name, l_fnd_log_message );
             if g_debug= c_debug_enabled then
               mydebug(l_fnd_log_message, c_api_name,9);
             end if;
             l_fnd_log_message := 'demand source type id is :' || p_mtl_maintain_rsv_rec.demand_source_type_id ;
             -- fnd_log_debug(fnd_log.level_procedure,c_module_name, l_fnd_log_message );
             if g_debug= c_debug_enabled then
               mydebug(l_fnd_log_message, c_api_name,9);
             end if;
             l_fnd_log_message := 'demand source header id is:'||p_mtl_maintain_rsv_rec.demand_source_header_id;
             -- fnd_log_debug(fnd_log.level_procedure,c_module_name, l_fnd_log_message );
             if g_debug= c_debug_enabled then
               mydebug(l_fnd_log_message, c_api_name,9);
             end if;
             l_fnd_log_message := 'demand source line id is:'||p_mtl_maintain_rsv_rec.demand_source_line_id;
             -- fnd_log_debug(fnd_log.level_procedure,c_module_name, l_fnd_log_message );
             if g_debug= c_debug_enabled then
               mydebug(l_fnd_log_message, c_api_name,9);
             end if;
          end if;
          -- new message 003 . this is a warning not an error message
          -- "query reservation api returns no records"
          fnd_message.set_name('inv','inv_qry_rsv_api_rtns_no_rec');
          fnd_msg_pub.add;
          return ;
       end if;
       -- dbms_output.put_line('checking delete flag status');
       if upper(nvl(p_delete_flag,'N')) = 'Y' then
          -- check if there are any reservation records with staged_flag as 'y'
          -- if so, throw error
          if (g_debug= c_debug_enabled) then
             mydebug ('Inside delete flag is Y' ,c_api_name,1);
          end if;

          l_staged_rec_exists := 'N' ;
          for i in 1..l_mtl_reservation_tbl_count loop
             if l_mtl_reservation_tbl(i).supply_source_type_id
                = inv_reservation_global.g_source_type_inv
             and nvl(l_mtl_reservation_tbl(i).staged_flag, 'N') = 'Y' then
                l_staged_rec_exists := 'Y' ;
                if (g_debug= c_debug_enabled) then
                   mydebug ('Staged reservation exists' ,c_api_name,1);
                end if;
                exit ;
             end if;
          end loop ;
          if l_staged_rec_exists = 'Y' then
             -- new message 003 . this is a warning not an error message
             -- "reservation can not be deleted as one or more reservation
             -- records are in staged"
             if (g_debug= c_debug_enabled) then
                mydebug ('Staged reservation exists. Error out' ,c_api_name,1);
             end if;
             fnd_message.set_name('INV','INV_RSV_REC_IN_STAGING');
             fnd_msg_pub.add;
             raise fnd_api.g_exc_error;
          end if;

          -- dbms_output.put_line('delete flag is yes');
          for i in 1..l_mtl_reservation_tbl_count loop
             -- codereview.su.10  move it to begining of loop and assign record itself
             l_original_rsv_rec := l_mtl_reservation_tbl(i) ;
             if ( l_mtl_reservation_tbl(i).orig_supply_source_type_id
                  <> l_mtl_reservation_tbl(i).supply_source_type_id )
               and l_mtl_reservation_tbl(i).supply_source_type_id = inv_reservation_global.g_source_type_asn then
                l_original_rsv_rec.reservation_id :=
                  l_mtl_reservation_tbl(i).reservation_id ;
                if (g_debug= c_debug_enabled) then
                   mydebug ('ASN reservation. Need to transfer to the
                            original supply' ,c_api_name,1);
                end if;
                if p_mtl_maintain_rsv_rec.action = c_action_supply then
                   l_to_rsv_rec.supply_source_type_id      := inv_reservation_global.g_source_type_po ;
                   l_to_rsv_rec.supply_source_header_id    := l_original_rsv_rec.supply_source_header_id;
                   l_to_rsv_rec.supply_source_line_id      := l_original_rsv_rec.supply_source_line_id;
                   --codereview.su.11 assign supply_source_line_detail value too
                   l_to_rsv_rec.supply_source_line_detail  := l_original_rsv_rec.supply_source_line_detail;
                   l_is_transfer_supply := fnd_api.g_true ;
                   -- codereview.su.12 comment out else statement. not required
                /**************************
                else
                   l_to_rsv_rec.demand_source_type_id      := inv_reservation_global.g_source_type_po ;
                   l_to_rsv_rec.demand_source_header_id    := l_original_rsv_rec.demand_source_header_id;
                   l_to_rsv_rec.demand_source_line_id      := l_original_rsv_rec.demand_source_line_id;
                   l_to_rsv_rec.demand_source_delivery     := null;
                   l_is_transfer_supply := fnd_api.g_false;
                ***************************/
                end if;
                -- ignoring serial numbers assingment since serial numbers are not changed
                -- reservation is transfered from one document type to another one.

                -- call transfer reservation api and transfer reservation to po
                if (g_debug= c_debug_enabled) then
                   mydebug ('Transferring reservation to the original supply' ,c_api_name,9);
                   mydebug ('Header:Line:Line Detail :' || l_to_rsv_rec.supply_source_header_id ||': '||
                        l_to_rsv_rec.supply_source_line_id ||': '|| l_to_rsv_rec.supply_source_line_detail,c_api_name,9);
                end if;

                inv_reservation_pvt.transfer_reservation (
                   p_api_version_number => 1.0 ,
                   p_init_msg_lst      => fnd_api.g_false ,
                   x_return_status      => x_return_status,
                   x_msg_count          => x_msg_count,
                   x_msg_data           => x_msg_data,
                   --p_is_transfer_supply => l_is_transfer_supply,
                   p_original_rsv_rec   => l_original_rsv_rec ,
                   p_to_rsv_rec         => l_to_rsv_rec ,
                   p_original_serial_number => l_original_serial_number,
                   -- p_to_serial_number   => l_to_serial_number,
                   p_validation_flag    => fnd_api.g_true  ,
                   x_reservation_id     => l_reservation_id ) ;
                 -- check if transfer reservation has raised any errors, if so raise exception
                if (g_debug= c_debug_enabled) then
                   mydebug ('After calling transfer: ' || x_return_status ,c_api_name,1);
                end if;
                if x_return_status = fnd_api.g_ret_sts_error then
                    l_fnd_log_message := 'error while calling transfer_reservation api :';
                    -- fnd_log_debug(fnd_log.level_error,c_module_name, l_fnd_log_message );
                    if g_debug= c_debug_enabled then
                      mydebug(l_fnd_log_message, c_api_name,9);
                    end if;
                    raise fnd_api.g_exc_error;
                 elsif x_return_status = fnd_api.g_ret_sts_unexp_error then
                    l_fnd_log_message := 'error while calling transfer_reservation api :';
                    -- fnd_log_debug(fnd_log.level_error,c_module_name, l_fnd_log_message );
                    if g_debug= c_debug_enabled then
                      mydebug(l_fnd_log_message, c_api_name,9);
                    end if;
                    raise fnd_api.g_exc_unexpected_error;
                 elsif x_return_status = fnd_api.g_ret_sts_success then
                    l_fnd_log_message := 'calling transfer_reservation api was successful:';
                    -- fnd_log_debug(fnd_log.level_event,c_module_name, l_fnd_log_message );
                    if g_debug= c_debug_enabled then
                      mydebug(l_fnd_log_message, c_api_name,9);
                    end if;
                 end if;
              ELSE -- not ASN
                if (g_debug= c_debug_enabled) then
                   mydebug ('Deleting reservations, Delete flag: Y' ,c_api_name,1);
                   mydebug ('Header:Line:Line Detail :' || l_original_rsv_rec.supply_source_header_id ||': '
                        || l_original_rsv_rec.supply_source_line_id ||': '|| l_original_rsv_rec.supply_source_line_detail,c_api_name,1);
                end if;
                l_original_rsv_rec.reservation_id := l_mtl_reservation_tbl(i).reservation_id ;
                -- delete reservation record
                inv_reservation_pvt.delete_reservation(
                   p_api_version_number => 1.0 ,
                   p_init_msg_lst      => fnd_api.g_false ,
                   x_return_status      => x_return_status,
                   x_msg_count          => x_msg_count,
                   x_msg_data           => x_msg_data,
                   p_rsv_rec            => l_original_rsv_rec ,
                   p_original_serial_number  => l_original_serial_number,
                   p_validation_flag   => fnd_api.g_true);

                if (g_debug= c_debug_enabled) then
                   mydebug ('After calling delete: ' || x_return_status ,c_api_name,1);
                end if;
                 -- check if delete reservation has raised any errors, if so raise exception
                 if x_return_status = fnd_api.g_ret_sts_error then
                    l_fnd_log_message := 'error while calling delete_reservation api :';
                    -- fnd_log_debug(fnd_log.level_error,c_module_name, l_fnd_log_message );
                    if g_debug= c_debug_enabled then
                      mydebug(l_fnd_log_message, c_api_name,9);
                    end if;
                    raise fnd_api.g_exc_error;
                 elsif x_return_status = fnd_api.g_ret_sts_unexp_error then
                    l_fnd_log_message := 'error while calling delete_reservation api :';
                    -- fnd_log_debug(fnd_log.level_error,c_module_name, l_fnd_log_message );
                    if g_debug= c_debug_enabled then
                      mydebug(l_fnd_log_message, c_api_name,9);
                    end if;
                    raise fnd_api.g_exc_unexpected_error;
                 elsif x_return_status = fnd_api.g_ret_sts_success then
                    l_fnd_log_message := 'calling delete_reservation api was successful:';
                    -- fnd_log_debug(fnd_log.level_event,c_module_name, l_fnd_log_message );
                    if g_debug= c_debug_enabled then
                      mydebug(l_fnd_log_message, c_api_name,9);
                    end if;
                 end if; -- end of checking return status
                 -- update quantity reduced variable
                 x_quantity_modified := x_quantity_modified + l_mtl_reservation_tbl(i).reservation_quantity ;
             end if; -- end of checking original_source_type_id and source_type_id
          end loop;
       elsif upper(nvl(p_delete_flag,'N')) = 'N' then
          -- check for expected quantity value
          -- dbms_output.put_line('delete flag is no');
          if (g_debug= c_debug_enabled) then
             mydebug ('Expected qty: ' ||  Nvl(p_mtl_maintain_rsv_rec.expected_quantity,0), c_api_name,1);
             mydebug ('Expected qty uom: ' ||  p_mtl_maintain_rsv_rec.expected_quantity_uom, c_api_name,1);
             mydebug ('To primary uom: ' || p_mtl_maintain_rsv_rec.to_primary_uom_code ,c_api_name,1);
          end if;
          if nvl(p_mtl_maintain_rsv_rec.expected_quantity,0) > 0 then
             -- dbms_output.put_line('expected qty is > 0');
             if p_mtl_maintain_rsv_rec.expected_quantity_uom is null or
                p_mtl_maintain_rsv_rec.expected_quantity_uom = fnd_api.g_miss_char then
                -- codereview.su.13. raise error
                check_reqd_param
                  (
                   p_param_value =>  p_mtl_maintain_rsv_rec.expected_quantity_uom,
                   p_param_name =>  'p_mtl_maintain_rsv_rec.expected_quantity_uom',
                   p_api_name    =>  c_api_name );
                -- dbms_output.put_line('raising error as expected qty uom is null');
                raise fnd_api.g_exc_error ;
                -- commenting following lines
                -- it is assumed that expected qty uom is same as primary qty uom
                -- l_primary_expected_qty := p_mtl_maintain_rsv_rec.expected_quantity ;
             else -- expected_quantity_uom is not null
                -- dbms_output.put_line('expected qty uom is not null');
                if p_mtl_maintain_rsv_rec.to_primary_uom_code is null or
                   p_mtl_maintain_rsv_rec.to_primary_uom_code = fnd_api.g_miss_char then
                   -- in such cases we will take primary uom code of the first record
                   -- and assuming that for all the records primary uom code will be same as
                   -- inventory_item_id and organization_id will be same
                   l_primary_uom_code := l_mtl_reservation_tbl(1).primary_uom_code ;
                   -- codereview.su.14 comment out follwing line.
                else -- to_primary_uom_code is null
                   l_primary_uom_code := p_mtl_maintain_rsv_rec.to_primary_uom_code ;
                   -- su:06/15/2005
                end if; -- to_primary_uom_code is null
                if g_debug= c_debug_enabled then
                   mydebug('primary uom code: ' || l_primary_uom_code, c_api_name,9);
                   mydebug('primary expected qty : ' || l_primary_expected_qty, c_api_name,9);
                end if;
                IF p_mtl_maintain_rsv_rec.expected_quantity_uom <>
                  l_primary_uom_code THEN
                   -- dbms_output.put_line('expected qty uom is not equal to primary_uom_code');
                   l_primary_expected_qty := inv_convert.inv_um_convert
                     (
                      item_id        => p_mtl_maintain_rsv_rec.inventory_item_id,
                      precision      => null,
                      from_quantity  => p_mtl_maintain_rsv_rec.expected_quantity,
                      from_unit      => p_mtl_maintain_rsv_rec.expected_quantity_uom,
                      to_unit        => p_mtl_maintain_rsv_rec.to_primary_uom_code,
                      from_name      => null,
                      to_name        => null );
                   l_fnd_log_message := 'after calling api inv_convert.inv_um_convert:';
                   -- fnd_log_debug(fnd_log.level_event,c_module_name, l_fnd_log_message );
                   if g_debug= c_debug_enabled then
                      mydebug(l_fnd_log_message, c_api_name,9);
                      mydebug('primary expected qty: ' || l_primary_expected_qty, c_api_name,9);
                   end if;

                ELSE -- they are the same
                   l_primary_expected_qty := p_mtl_maintain_rsv_rec.expected_quantity ;
                END IF; -- end of expected qty uom <> primary qty uom su:06/15
                -- get sum of all primary reservation quantity
                -- intialize sum of primary reservation qty
                l_sum_primary_reservation_qty := 0 ;
                for i in 1..l_mtl_reservation_tbl_count loop
                   l_sum_primary_reservation_qty := l_sum_primary_reservation_qty +
                     l_mtl_reservation_tbl(i).primary_reservation_quantity ;
                end loop;

                l_primary_need_reduced_qty := l_sum_primary_reservation_qty - l_primary_expected_qty;

                if g_debug= c_debug_enabled THEN
                   mydebug('Expectd Qty is not null', c_api_name,9);
                   mydebug('Total reserved qty: ' || l_sum_primary_reservation_qty, c_api_name,9);
                   mydebug('To be reduced qty: ' || l_primary_need_reduced_qty, c_api_name,9);
                END IF;
                -- dbms_output.put_line('primary need reduced qty' || l_primary_need_reduced_qty );
                -- dbms_output.put_line('sum primary reservation qty' || l_sum_primary_reservation_qty );
                -- dbms_output.put_line('primary expected qty' || l_primary_expected_qty );
                -- end if; commented by satish
                -- end if; -- end of expected qty uom <> primary qty uom su:06/15
             end if; -- end of expected_quantity_uom is not null
          else  -- expected_qty is zero or null
             if g_debug= c_debug_enabled THEN
                mydebug('Expectd Qty is null', c_api_name,9);
                mydebug('from primary txn qty: ' ||p_mtl_maintain_rsv_rec.from_primary_txn_quantity,c_api_name,9);
                mydebug('from primary uom code: ' ||p_mtl_maintain_rsv_rec.from_primary_uom_code,c_api_name,9);
                mydebug('from txn uom code: ' ||p_mtl_maintain_rsv_rec.from_transaction_uom_code,c_api_name,9);

             END IF;
             if p_mtl_maintain_rsv_rec.from_primary_txn_quantity is null or
                p_mtl_maintain_rsv_rec.from_primary_txn_quantity = fnd_api.g_miss_num then
                --codereview.su.16 check if from_transaction_uom_code and from_primary_uom_code
                -- is not null, if they are then raise error

                -- from_primary_uom_code column is a required column
                check_reqd_param
                  (
                   p_param_value =>  p_mtl_maintain_rsv_rec.from_primary_uom_code,
                   p_param_name =>  'p_mtl_maintain_rsv_rec.from_primary_uom_code',
                   p_api_name    =>  c_api_name );

                -- from_transaction_uom_code column is a required column
                check_reqd_param
                  (
                   p_param_value =>  p_mtl_maintain_rsv_rec.from_transaction_uom_code,
                   p_param_name =>  'p_mtl_maintain_rsv_rec.from_transaction_uom_code',
                   p_api_name    =>  c_api_name );

                if p_mtl_maintain_rsv_rec.from_transaction_uom_code <> p_mtl_maintain_rsv_rec.from_primary_uom_code then
                   --codereview.su.17
                   l_from_primary_transaction_qty :=
                     inv_convert.inv_um_convert
                     (
                      item_id        => p_mtl_maintain_rsv_rec.inventory_item_id,
                      precision      => null,
                      from_quantity  => p_mtl_maintain_rsv_rec.from_transaction_quantity,
                      from_unit      => p_mtl_maintain_rsv_rec.from_transaction_uom_code,
                      to_unit        => p_mtl_maintain_rsv_rec.from_primary_uom_code,
                      from_name      => null,
                      to_name        => null );
                   l_fnd_log_message := 'after calling api inv_convert.inv_um_convert 02:';
                   -- fnd_log_debug(fnd_log.level_event,c_module_name, l_fnd_log_message );
                   if g_debug= c_debug_enabled then
                      mydebug(l_fnd_log_message, c_api_name,9);
                      mydebug('from primary txn qty' || l_from_primary_transaction_qty, c_api_name,9);
                   end if;

                end if; --check for transaction uom code
              else --
                if g_debug= c_debug_enabled then
                   mydebug('txn uom same as primary uom', c_api_name,9);
                end if;
                l_from_primary_transaction_qty := p_mtl_maintain_rsv_rec.from_primary_txn_quantity ;
             end if; -- from transaction uom code
             -- now check to_transaction_qty
             if g_debug= c_debug_enabled THEN
                mydebug('to primary txn qty: ' || p_mtl_maintain_rsv_rec.to_primary_txn_quantity, c_api_name,9);
                mydebug('to primary uom code: ' || p_mtl_maintain_rsv_rec.to_primary_uom_code, c_api_name,9);
                mydebug('to txn uom code: ' || p_mtl_maintain_rsv_rec.to_transaction_uom_code, c_api_name,9);

             END IF;
             if p_mtl_maintain_rsv_rec.to_primary_txn_quantity is null or
               p_mtl_maintain_rsv_rec.to_primary_txn_quantity = fnd_api.g_miss_num then
                -- to_primary_uom_code column is a required column
                check_reqd_param
                  (
                   p_param_value =>  p_mtl_maintain_rsv_rec.to_primary_uom_code,
                   p_param_name =>  'p_mtl_maintain_rsv_rec.to_primary_uom_code',
                   p_api_name    =>  c_api_name );

                -- to_transaction_uom_code column is a required column
                check_reqd_param
                  (
                   p_param_value =>  p_mtl_maintain_rsv_rec.to_transaction_uom_code,
                   p_param_name =>  'p_mtl_maintain_rsv_rec.to_transaction_uom_code',
                   p_api_name    =>  c_api_name );

                if p_mtl_maintain_rsv_rec.to_transaction_uom_code <>
                  p_mtl_maintain_rsv_rec.to_primary_uom_code then
                   l_to_primary_transaction_qty :=
                     inv_convert.inv_um_convert
                     (
                      item_id        => p_mtl_maintain_rsv_rec.inventory_item_id,
                      precision      => null,
                      from_quantity  => p_mtl_maintain_rsv_rec.to_transaction_quantity,
                      from_unit      => p_mtl_maintain_rsv_rec.to_transaction_uom_code,
                      to_unit        => p_mtl_maintain_rsv_rec.to_primary_uom_code,
                      from_name      => null,
                      to_name        => null );
                   l_fnd_log_message := 'after calling api inv_convert.inv_um_convert 03:';
                   -- fnd_log_debug(fnd_log.level_event,c_module_name, l_fnd_log_message );
                   if g_debug= c_debug_enabled then
                      mydebug(l_fnd_log_message, c_api_name,9);
                      mydebug('After convert to primary txn qty: '|| l_to_primary_transaction_qty, c_api_name,9);
                   end if;

                 else -- to_transaction_uom_code <> to_primary_uom_code
                   --codereview.su.20 added else statement
                   if g_debug= c_debug_enabled then
                      mydebug('to txn uom same as to primary uom', c_api_name,9);
                   end if;
                   l_to_primary_transaction_qty := p_mtl_maintain_rsv_rec.to_primary_txn_quantity ;
                end if; --to-transaction_uom_code <> to_primary_uom_code
             end if; --check for transaction uom code

             l_primary_need_reduced_qty := l_to_primary_transaction_qty -
               l_from_primary_transaction_qty;
             if g_debug= c_debug_enabled then
                mydebug('From primary txn qty' || l_from_primary_transaction_qty, c_api_name,9);
                mydebug('to primary txn qty' || l_to_primary_transaction_qty, c_api_name,9);
                mydebug('Need to reduce qty' || l_primary_need_reduced_qty, c_api_name,9);
             end if;
          end if; -- end of checking expected_qty value

          x_quantity_modified := 0;
          l_primary_need_reduced_qty := Nvl(l_primary_need_reduced_qty,0);
          -- loop through all the records

          for i in 1..l_mtl_reservation_tbl_count loop
             -- dbms_output.put_line('looping through reservation records');
             if l_mtl_reservation_tbl(i).supply_source_type_id
               = inv_reservation_global.g_source_type_inv
               and nvl(l_mtl_reservation_tbl(i).staged_flag, 'N') = 'Y' then
                -- skip record
                -- dbms_output.put_line('skipping record');
                null;
                if g_debug= c_debug_enabled then
                   mydebug('Skipped record as staged flag is null', c_api_name,9);
                END IF;
              else -- supply_souce_type is inv
                -- dbms_output.put_line('looping through reservation table');
                if l_primary_need_reduced_qty = 0 then
                   exit;
                end if;
                -- dbms_output.put_line('primary need reduced qty := ' || l_primary_need_reduced_qty );
                -- added following line : su:06/15/05
                l_original_rsv_rec := l_mtl_reservation_tbl(i) ;
                IF g_debug= c_debug_enabled then
                   mydebug('Reservation records primary reservation qty'||l_mtl_reservation_tbl(i).primary_reservation_quantity,c_api_name,9);
                   mydebug('l_primary_need_reduced_qty' || l_primary_need_reduced_qty, c_api_name,9);
                END IF;

                IF Nvl(l_mtl_reservation_tbl(i).primary_reservation_quantity,0) > l_primary_need_reduced_qty then
                   -- call update reservation api
                   -- dbms_output.put_line('calling update reservation api');
                   if p_mtl_maintain_rsv_rec.action = c_action_supply then
                      l_to_rsv_rec.supply_source_type_id := l_mtl_reservation_tbl(i).supply_source_type_id ;
                      l_to_rsv_rec.supply_source_header_id:= l_mtl_reservation_tbl(i).supply_source_header_id;
                      l_to_rsv_rec.supply_source_line_id:= l_mtl_reservation_tbl(i).supply_source_line_id;
                      l_to_rsv_rec.supply_source_line_detail:= l_mtl_reservation_tbl(i).supply_source_line_detail;

                      l_is_transfer_supply := fnd_api.g_true ;
                    else
                      l_to_rsv_rec.demand_source_type_id := l_mtl_reservation_tbl(i).demand_source_type_id ;
                      l_to_rsv_rec.demand_source_header_id:= l_mtl_reservation_tbl(i).demand_source_header_id;
                      l_to_rsv_rec.demand_source_line_id:= l_mtl_reservation_tbl(i).demand_source_line_id;
                      l_to_rsv_rec.demand_source_delivery     := null;
                      l_is_transfer_supply := fnd_api.g_false;
                   end if;
                   l_to_rsv_rec.primary_reservation_quantity := Nvl(l_mtl_reservation_tbl(i).primary_reservation_quantity,0)
                                                            - l_primary_need_reduced_qty;
                   IF g_debug= c_debug_enabled then
                      mydebug('Update reservation', c_api_name,9);
                      mydebug('Update qty' || l_primary_need_reduced_qty, c_api_name,9);
                   END IF;
                   inv_reservation_pvt.update_reservation
                     (
                      p_api_version_number =>  1.0,
                      p_init_msg_lst       =>  fnd_api.g_false,
                      x_return_status      =>  x_return_status,
                      x_msg_count          =>  x_msg_count,
                      x_msg_data           =>  x_msg_data ,
                      p_original_rsv_rec   =>  l_original_rsv_rec,
                      p_to_rsv_rec         =>  l_to_rsv_rec,
                      p_original_serial_number => l_original_serial_number,
                      p_to_serial_number   =>  l_to_serial_number,
                      p_validation_flag    =>  fnd_api.g_true ,
                      p_check_availability =>  fnd_api.g_false );

                   -- check if delete reservation has raised any errors, if so raise exception
                   if x_return_status = fnd_api.g_ret_sts_error then
                      l_fnd_log_message := 'error while calling update reservation api 02:';
                      -- fnd_log_debug(fnd_log.level_error,c_module_name, l_fnd_log_message );
                      if g_debug= c_debug_enabled then
                         mydebug(l_fnd_log_message, c_api_name,9);
                      end if;
                      raise fnd_api.g_exc_error;
                    elsif x_return_status = fnd_api.g_ret_sts_unexp_error then
                      l_fnd_log_message := 'error while calling update reservation api 02:';
                      -- fnd_log_debug(fnd_log.level_error,c_module_name, l_fnd_log_message );
                      if g_debug= c_debug_enabled then
                         mydebug(l_fnd_log_message, c_api_name,9);
                      end if;
                      raise fnd_api.g_exc_unexpected_error;
                    elsif x_return_status = fnd_api.g_ret_sts_success then
                      l_fnd_log_message := 'calling update reservation api was successful -02:';
                      -- fnd_log_debug(fnd_log.level_error,c_module_name, l_fnd_log_message );
                      if g_debug= c_debug_enabled then
                         mydebug(l_fnd_log_message, c_api_name,9);
                      end if;
                   end if;
                   x_quantity_modified := x_quantity_modified + l_primary_need_reduced_qty ;
                   l_primary_need_reduced_qty := 0;

                 ELSIF (Nvl(l_mtl_reservation_tbl(i).primary_reservation_quantity,0) <= l_primary_need_reduced_qty) THEN
                 -- reservation_qty < primary_need_reduced_qty
                   -- call delete reservation
                   IF g_debug= c_debug_enabled then
                      mydebug('Call delete reservation for reservation id' || l_mtl_reservation_tbl(i).reservation_id, c_api_name,9);
                   END IF;
                   l_original_rsv_rec.reservation_id := l_mtl_reservation_tbl(i).reservation_id ;
                   -- not assigning any values to l_original_serial_number as it does not matter
                   -- dbms_output.put_line('calling delete reservation api');
                   inv_reservation_pvt.delete_reservation
                     (
                      p_api_version_number =>  1.0,
                      p_init_msg_lst       =>  fnd_api.g_false,
                      x_return_status      =>  x_return_status,
                      x_msg_count          =>  x_msg_count,
                      x_msg_data           =>  x_msg_data ,
                      p_rsv_rec            =>  l_original_rsv_rec,
                      p_original_serial_number => l_original_serial_number,
                      p_validation_flag    =>  fnd_api.g_true  );

                   -- check if delete reservation has raised any errors, if so raise exception
                   if x_return_status = fnd_api.g_ret_sts_error then
                      l_fnd_log_message := 'error while calling delete reservation api 02:';
                      -- fnd_log_debug(fnd_log.level_error,c_module_name, l_fnd_log_message );
                      if g_debug= c_debug_enabled then
                         mydebug(l_fnd_log_message, c_api_name,9);
                      end if;
                      raise fnd_api.g_exc_error;
                    elsif x_return_status = fnd_api.g_ret_sts_unexp_error then
                      l_fnd_log_message := 'error while calling delete reservation api 02:';
                      ----  fnd_log_debug(fnd_log.level_error,c_module_name, l_fnd_log_message );
                      if g_debug= c_debug_enabled then
                         mydebug(l_fnd_log_message, c_api_name,9);
                      end if;
                      raise fnd_api.g_exc_unexpected_error;
                    elsif x_return_status = fnd_api.g_ret_sts_success then
                      l_fnd_log_message := 'calling delete reservation api was successful -02:';
                      -- fnd_log_debug(fnd_log.level_error,c_module_name, l_fnd_log_message );
                      if g_debug= c_debug_enabled then
                         mydebug(l_fnd_log_message, c_api_name,9);
                      end if;
                      l_primary_need_reduced_qty := Nvl(l_primary_need_reduced_qty,0) -
                        Nvl(l_mtl_reservation_tbl(i).primary_reservation_quantity,0) ;
                      x_quantity_modified := x_quantity_modified +
                        Nvl(l_mtl_reservation_tbl(i).primary_reservation_quantity,0) ;
                   end if; -- end of checking return status
                end if; -- reservation_qty > primary_need_reduced_qty
             end if; -- if source type id = inv
          end loop ;

          -- dbms_output.put_line('end of looping through reservation table');
          /*******satish01**
        else
          l_to_primary_transaction_qty := p_mtl_maintain_rsv_rec.to_primary_txn_quantity ;
          end if;
          -- moving this line up
          -- end if; -- end of checking expected_qty value
          **************satish ***/
       end if; -- p_delete_flag = y

       -- call fnd_log api at the end of the api
       l_fnd_log_message := 'at the end of procedure :';
       -- -- fnd_log_debug(fnd_log.level_procedure,c_module_name, l_fnd_log_message );

       if g_debug= c_debug_enabled then
          mydebug(l_fnd_log_message, c_api_name,9);
       end if;
   exception
      when fnd_api.g_exc_error then
          x_return_status := fnd_api.g_ret_sts_error;

          --  get message count and data
          fnd_msg_pub.count_and_get
            (  p_count => x_msg_count
             , p_data  => x_msg_data
             );

           -- call fnd_log api at the end of the api
           l_fnd_log_message := 'when expected exception raised for procedure :' ;
           -- fnd_log_debug(fnd_log.level_error,c_module_name, l_fnd_log_message );

           -- log message in trace file
           if g_debug= c_debug_enabled then
               mydebug(l_fnd_log_message,c_api_name,9);
           end if;

           -- get messages from stack and log them in fnd tables
           if x_msg_count = 1 then
              -- fnd_log_debug(fnd_log.level_error,c_module_name, x_msg_data );
              -- log message in trace file
              if g_debug= c_debug_enabled then
                mydebug(l_fnd_log_message,c_api_name,9);
              end if;
           elsif x_msg_count > 1 then
               for i in 1..x_msg_count loop
                 fnd_msg_pub.get
                  (p_msg_index     => i,
                   p_encoded       => 'f',
                   p_data          => l_fnd_log_message,
                   p_msg_index_out => l_msg_index_out );

                  -- fnd_log_debug(fnd_log.level_error,c_module_name, l_fnd_log_message );

                  -- log message in trace file
                  if g_debug= c_debug_enabled then
                      mydebug(l_fnd_log_message,c_api_name,9);
                  end if;
               end loop ;
           end if;


       when fnd_api.g_exc_unexpected_error then
            x_return_status := fnd_api.g_ret_sts_unexp_error ;

            --  get message count and data
            fnd_msg_pub.count_and_get
              (  p_count  => x_msg_count
               , p_data   => x_msg_data
                );
            -- call fnd_log api at the end of the api
            l_fnd_log_message := 'when unexpected exception raised for procedure :';
            -- fnd_log_debug(fnd_log.level_error,c_module_name, l_fnd_log_message );

            -- log message in trace file
            if g_debug= c_debug_enabled then
                mydebug(l_fnd_log_message,c_api_name,9);
            end if;

            -- get messages from stack and log them in fnd tables
            if x_msg_count = 1 then
              -- fnd_log_debug(fnd_log.level_error,c_module_name, x_msg_data );

              -- log message in trace file
              if g_debug= c_debug_enabled then
                mydebug(l_fnd_log_message,c_api_name,9);
              end if;
            elsif x_msg_count > 1 then
               for i in 1..x_msg_count loop
                 fnd_msg_pub.get
                  (p_msg_index     => i,
                   p_encoded       => 'f',
                   p_data          => l_fnd_log_message,
                   p_msg_index_out => l_msg_index_out );

                  -- fnd_log_debug(fnd_log.level_error,c_module_name, l_fnd_log_message );

                  -- log message in trace file
                  if g_debug= c_debug_enabled then
                      mydebug(l_fnd_log_message,c_api_name,9);
                  end if;
               end loop ;
            end if;

        when others then
            x_return_status := fnd_api.g_ret_sts_unexp_error ;

            if fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
              then
               fnd_msg_pub.add_exc_msg
                 (  g_pkg_name
                  , c_api_name
                  );
            end if;

            --  get message count and data
            fnd_msg_pub.count_and_get
              (  p_count  => x_msg_count
               , p_data   => x_msg_data
                 );

            -- call fnd_log api at the end of the api
            l_fnd_log_message := 'when others exception raised for procedure :' || g_pkg_name || '.' || c_api_name ;
            -- fnd_log_debug(fnd_log.level_error,c_module_name, l_fnd_log_message );

            -- log message in trace file
            if g_debug= c_debug_enabled then
                mydebug(l_fnd_log_message,c_api_name,9);
            end if;

           -- get messages from stack and log them in fnd tables
           if x_msg_count = 1 then
              -- fnd_log_debug(fnd_log.level_error,c_module_name, x_msg_data );

              -- log message in trace file
              if g_debug= c_debug_enabled then
                 mydebug(l_fnd_log_message,c_api_name,9);
               end if;
            elsif x_msg_count > 1 then
                for i in 1..x_msg_count loop
                  fnd_msg_pub.get
                   (p_msg_index     => i,
                    p_encoded       => 'f',
                    p_data          => l_fnd_log_message,
                    p_msg_index_out => l_msg_index_out );

                   -- fnd_log_debug(fnd_log.level_error,c_module_name, l_fnd_log_message );

                   -- log message in trace file
                   if g_debug= c_debug_enabled then
                       mydebug(l_fnd_log_message,c_api_name,9);
                   end if;
                end loop ;
            end if;

     end reduce_reservation;
--this procedure initializes the reservation record - only done when a new requisition reservation
--is created
--
procedure build_res_rec (x_reservation_rec out nocopy inv_reservation_global.mtl_reservation_rec_type)
is

   -- define constants for api version and api name
   c_api_version_number       constant number       := 1.0;
   c_api_name                 constant varchar2(30) := 'build_res_rec';
   c_module_name              constant varchar2(2000) := 'inv.plsql.inv_maintain_reservation_pub';
   c_debug_enabled            constant number := 1 ;
   l_fnd_log_message          varchar2(2000);

   l_rsv      inv_reservation_global.mtl_reservation_rec_type;

begin
   --this procedure initializes the mtl_reservation record
   l_fnd_log_message := 'begining of procedure :';
   -- dbms_output.put_line('begining of procedure');
   -- fnd_log_debug(fnd_log.level_procedure, c_module_name, l_fnd_log_message);

   -- log message in trace file
   if g_debug= c_debug_enabled then
      g_version_printed := true ;
      mydebug(l_fnd_log_message,c_api_name,9);
      g_version_printed := false ;
   end if;

   l_rsv.reservation_id                 := null;
   l_rsv.requirement_date               := null;
   l_rsv.organization_id                := null;       -- org id
   l_rsv.inventory_item_id              := null;       -- item id
   l_rsv.demand_source_type_id          :=
         inv_reservation_global.g_source_type_oe;   -- order entry
   l_rsv.demand_source_name             := null;
   l_rsv.demand_source_header_id        := null;     -- oe order number
   l_rsv.demand_source_line_id          := null;     -- oe order line number
   l_rsv.demand_source_delivery         := null;
   l_rsv.primary_uom_code               := null;  --10
   l_rsv.primary_uom_id                 := null;
   l_rsv.reservation_uom_code           := null;
   l_rsv.reservation_uom_id             := null;
   l_rsv.reservation_quantity           := null;
   l_rsv.primary_reservation_quantity   := null;        -- reservation quantity

   l_rsv.detailed_quantity              := null;
   l_rsv.secondary_uom_code             := null;
   l_rsv.secondary_uom_id               := null;
   l_rsv.secondary_reservation_quantity := null;
   l_rsv.secondary_detailed_quantity    := null;  --20

   l_rsv.autodetail_group_id            := null;
   l_rsv.external_source_code           := null;
   l_rsv.external_source_line_id        := null;
   l_rsv.supply_source_type_id          :=
         inv_reservation_global.g_source_type_req;
   l_rsv.supply_source_header_id        := null;       -- po req header id
   l_rsv.supply_source_line_id          := null;       -- po req line id
   l_rsv.supply_source_name             := null;
   l_rsv.supply_source_line_detail      := null;
   l_rsv.revision                       := null;
   l_rsv.subinventory_code              := null;  --30
   l_rsv.subinventory_id                := null;
   l_rsv.locator_id                     := null;
   l_rsv.lot_number                     := null;
   l_rsv.lot_number_id                  := null;
   l_rsv.pick_slip_number               := null;
   l_rsv.lpn_id                         := null;
   l_rsv.attribute_category             := null;
   l_rsv.attribute1                     := null;
   l_rsv.attribute2                     := null;
   l_rsv.attribute3                     := null;  --40
   l_rsv.attribute4                     := null;
   l_rsv.attribute5                     := null;
   l_rsv.attribute6                     := null;
   l_rsv.attribute7                     := null;
   l_rsv.attribute8                     := null;
   l_rsv.attribute9                     := null;
   l_rsv.attribute10                    := null;
   l_rsv.attribute11                    := null;
   l_rsv.attribute12                    := null;
   l_rsv.attribute13                    := null;  --50
   l_rsv.attribute14                    := null;
   l_rsv.attribute15                    := null;
   l_rsv.ship_ready_flag                := null;
   l_rsv.staged_flag                    := null;

   l_rsv.crossdock_flag                 := null;
   l_rsv.crossdock_criteria_id          := null;
   l_rsv.demand_source_line_detail      := null;
   l_rsv.serial_reservation_quantity    := null;
   l_rsv.supply_receipt_date            := null;
   l_rsv.demand_ship_date               := null;  --60
   l_rsv.project_id                     := null;
   l_rsv.task_id                        := null;
   l_rsv.orig_supply_source_type_id     := null;
   l_rsv.orig_supply_source_header_id   := null;
   l_rsv.orig_supply_source_line_id     := null;
   l_rsv.orig_supply_source_line_detail := null;
   l_rsv.orig_demand_source_type_id     := null;
   l_rsv.orig_demand_source_header_id   := null;
   l_rsv.orig_demand_source_line_id     := null;
   l_rsv.orig_demand_source_line_detail := null;  --70
   l_rsv.serial_number                  := null;  --71

   x_reservation_rec := l_rsv;

   -- call fnd_log api at the end of the api
   l_fnd_log_message := 'at the end of procedure :';
   -- -- fnd_log_debug(fnd_log.level_procedure,c_module_name, l_fnd_log_message );

   if g_debug= c_debug_enabled then
     mydebug(l_fnd_log_message, c_api_name,9);
   end if;

exception
   when others then
        l_fnd_log_message := 'when others exception raised for procedure :' || g_pkg_name || '.' || c_api_name ;
        -- fnd_log_debug(fnd_log.level_error,c_module_name, l_fnd_log_message );

        -- log message in trace file
        if g_debug= c_debug_enabled then
             mydebug(l_fnd_log_message,c_api_name,9);
        end if;
end;


-- procedure create_res calls the inventory api create_reservation with the appropriate parameters
--
--
procedure create_res
  (p_inventory_item_id        in number
   ,p_organization_id          in number
   ,p_demand_source_header_id  in number
   ,p_demand_source_line_id    in NUMBER
   ,p_supply_source_type_id    IN NUMBER
   ,p_supply_source_header_id  in number
   ,p_supply_source_line_id    in number
   ,p_requirement_date         in date
   ,p_reservation_quantity     in number
   ,p_reservation_uom_code     in varchar2
   ,p_project_id               in number
   ,p_task_id                  in number
   ,x_msg_count                out nocopy number
   ,x_msg_data                 out nocopy varchar2
   ,x_return_status            out nocopy varchar2)
  is

     -- define constants for api version and api name
     c_api_version_number       constant number       := 1.0;
     c_api_name                 constant varchar2(30) := 'create_res';
     c_module_name              constant varchar2(2000) := 'inv.plsql.inv_maintain_reservation_pub.maintain_reservation';
     c_debug_enabled            constant number := 1 ;

     --l_debug                    number := nvl(fnd_profile.value('inv_debug_trace'), 0);
     l_fnd_log_message          varchar2(2000);
     l_msg_index_out            number;

     l_rsv                      inv_reservation_global.mtl_reservation_rec_type;
     l_return_status            varchar2(1);
     --l_msg_count                number := 0;
     --l_msg_data                 varchar2(2000);
     l_qty                      number;
     l_second_qty               number;
     l_rsv_id                   number;
     l_demand_source_type_id    number;
begin
     l_fnd_log_message := 'begining of procedure :';
     -- dbms_output.put_line('begining of procedure');
     -- fnd_log_debug(fnd_log.level_procedure, c_module_name, l_fnd_log_message);

     -- log message in trace file
     if g_debug= c_debug_enabled then
        g_version_printed := true ;
        mydebug(l_fnd_log_message,c_api_name,9);
        g_version_printed := false ;
     end if;

     -- bug 3600118: initialize return status variable
     l_return_status := fnd_api.g_ret_sts_success;

     build_res_rec(x_reservation_rec =>l_rsv);

     l_rsv.inventory_item_id       := p_inventory_item_id;
     l_rsv.organization_id         := p_organization_id;
     l_rsv.demand_source_header_id := p_demand_source_header_id;
     l_rsv.demand_source_line_id   := p_demand_source_line_id;
     l_rsv.supply_source_header_id := p_supply_source_header_id;
     l_rsv.supply_source_line_id   := p_supply_source_line_id;
     l_rsv.requirement_date        := p_requirement_date;
     l_rsv.reservation_quantity    := p_reservation_quantity;
     l_rsv.reservation_uom_code    := p_reservation_uom_code;
     l_rsv.project_id              := p_project_id;
     l_rsv.task_id                 := p_task_id;
     --
     --for internal sales order the demand source needs to be of type internal order
     --for creating a reservation.  we removed the call to cto_util to remove the
     --dependency between po and cto
     -- l_source_document_type_id :=
     --     cto_utility_pk.get_source_document_id (plineid => p_demand_source_line_id );

     if g_debug= c_debug_enabled then
         l_fnd_log_message := 'progress 100';
         mydebug(l_fnd_log_message,c_api_name,9);
     end if;

     select decode (h.source_document_type_id, 10,
               inv_reservation_global.g_source_type_internal_ord,
               inv_reservation_global.g_source_type_oe )
       into l_demand_source_type_id
       from oe_order_headers_all h, oe_order_lines_all l
      where h.header_id = l.header_id
        and l.line_id = p_demand_source_line_id;

     l_rsv.demand_source_type_id        := l_demand_source_type_id;
     l_rsv.supply_source_type_id        := p_supply_source_type_id;

     if g_debug= c_debug_enabled then
           l_fnd_log_message := 'progress 200';
           mydebug(l_fnd_log_message,c_api_name,9);
     end if;

     inv_reservation_pvt.create_reservation
        (
           p_api_version_number          => 1.0
         , p_init_msg_lst                => fnd_api.g_false
         , x_return_status               => l_return_status
         , x_msg_count                   => x_msg_count
         , x_msg_data                    => x_msg_data
         , p_rsv_rec                     => l_rsv
         , p_serial_number               => g_dummy_sn_tbl
         , x_serial_number               => g_dummy_sn_tbl
         , p_partial_reservation_flag    => fnd_api.g_true
         , p_force_reservation_flag      => fnd_api.g_false
         , p_validation_flag             => fnd_api.g_true
         --, p_validation_flag             => fnd_api.g_false
         , x_quantity_reserved           => l_qty
         , x_secondary_quantity_reserved => l_second_qty
         , x_reservation_id              => l_rsv_id
         );

     if g_debug= c_debug_enabled then
           l_fnd_log_message := 'l_return_status: '|| l_return_status;
           mydebug(l_fnd_log_message,c_api_name,9);
     end if;

     x_return_status := l_return_status;

     if x_return_status = fnd_api.g_ret_sts_success then
        l_fnd_log_message := 'calling create_reservation api was successful ';
        -- fnd_log_debug(fnd_log.level_error,c_module_name, l_fnd_log_message );
        if g_debug= c_debug_enabled then
           mydebug(l_fnd_log_message, c_api_name,9);
        end if;
     else
        l_fnd_log_message := 'error while calling create_reservation api ';
        -- fnd_log_debug(fnd_log.level_error,c_module_name, l_fnd_log_message );
        if g_debug= c_debug_enabled then
           mydebug(l_fnd_log_message, c_api_name,9);
        end if;
     end if;

     -- call fnd_log api at the end of the api
     l_fnd_log_message := 'at the end of procedure :';
     -- -- fnd_log_debug(fnd_log.level_procedure,c_module_name, l_fnd_log_message );

     if g_debug= c_debug_enabled then
           mydebug(l_fnd_log_message, c_api_name,9);
     end if;

exception
   when fnd_api.g_exc_error then
        x_return_status := fnd_api.g_ret_sts_error;

        --  get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );

         -- call fnd_log api at the end of the api
         l_fnd_log_message := 'when expected exception raised for procedure :' ;
         -- fnd_log_debug(fnd_log.level_error,c_module_name, l_fnd_log_message );

         -- log message in trace file
         if g_debug= c_debug_enabled then
             mydebug(l_fnd_log_message,c_api_name,9);
         end if;

         -- get messages from stack and log them in fnd tables
         if x_msg_count = 1 then
            -- fnd_log_debug(fnd_log.level_error,c_module_name, x_msg_data );
            -- log message in trace file
            if g_debug= c_debug_enabled then
              mydebug(l_fnd_log_message,c_api_name,9);
            end if;
         elsif x_msg_count > 1 then
             for i in 1..x_msg_count loop
               fnd_msg_pub.get
                (p_msg_index     => i,
                 p_encoded       => 'f',
                 p_data          => l_fnd_log_message,
                 p_msg_index_out => l_msg_index_out );

                -- fnd_log_debug(fnd_log.level_error,c_module_name, l_fnd_log_message );

                -- log message in trace file
                if g_debug= c_debug_enabled then
                    mydebug(l_fnd_log_message,c_api_name,9);
                end if;
             end loop ;
         end if;


     when fnd_api.g_exc_unexpected_error then
          x_return_status := fnd_api.g_ret_sts_unexp_error ;

          --  get message count and data
          fnd_msg_pub.count_and_get
            (  p_count  => x_msg_count
             , p_data   => x_msg_data
              );
          -- call fnd_log api at the end of the api
          l_fnd_log_message := 'when unexpected exception raised for procedure :';
          -- fnd_log_debug(fnd_log.level_error,c_module_name, l_fnd_log_message );

          -- log message in trace file
          if g_debug= c_debug_enabled then
              mydebug(l_fnd_log_message,c_api_name,9);
          end if;

          -- get messages from stack and log them in fnd tables
          if x_msg_count = 1 then
            -- fnd_log_debug(fnd_log.level_error,c_module_name, x_msg_data );

            -- log message in trace file
            if g_debug= c_debug_enabled then
              mydebug(l_fnd_log_message,c_api_name,9);
            end if;
          elsif x_msg_count > 1 then
             for i in 1..x_msg_count loop
               fnd_msg_pub.get
                (p_msg_index     => i,
                 p_encoded       => 'f',
                 p_data          => l_fnd_log_message,
                 p_msg_index_out => l_msg_index_out );

                -- fnd_log_debug(fnd_log.level_error,c_module_name, l_fnd_log_message );

                -- log message in trace file
                if g_debug= c_debug_enabled then
                    mydebug(l_fnd_log_message,c_api_name,9);
                end if;
             end loop ;
          end if;

   when others then
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        if fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          then
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , c_api_name
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
           );

        -- Call fnd_log api at the end of the API
        l_Fnd_Log_message := 'When Others exception raised for procedure :' || G_Pkg_Name || '.' || C_API_Name ;
        -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );

        -- Log message in trace file
        IF G_debug= C_Debug_Enabled THEN
            mydebug(l_Fnd_Log_Message,c_api_name,9);
        END IF;

        -- Get messages from stack and log them in fnd tables
        If X_Msg_Count = 1 Then
          -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, X_Msg_Data );

          -- Log message in trace file
          If G_debug= C_Debug_Enabled Then
             mydebug(l_Fnd_Log_Message,c_api_name,9);
           End If;
        Elsif X_Msg_Count > 1 Then
            For I In 1..X_Msg_Count Loop
              FND_MSG_PUB.Get
               (p_msg_index     => i,
                p_encoded       => 'F',
                p_data          => l_Fnd_Log_Message,
                p_msg_index_out => l_msg_index_out );

               -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );

               -- Log message in trace file
               IF G_debug= C_Debug_Enabled THEN
                   mydebug(l_Fnd_Log_Message,c_api_name,9);
               END IF;
            End Loop ;
        End If;
END;

--
--this procedure calls inventory API query_reservation with the appropriate parameters
--
PROCEDURE QUERY_RES
    (p_supply_source_header_id  IN NUMBER DEFAULT NULL
    ,p_supply_source_line_id    IN NUMBER DEFAULT NULL
    ,p_supply_source_type_id    IN NUMBER
    ,p_project_id               IN NUMBER
    ,p_task_id                  IN NUMBER
    ,x_rsv_array                OUT NOCOPY inv_reservation_global.mtl_reservation_tbl_type
    ,x_record_count             OUT NOCOPY NUMBER
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
    ,x_return_status            OUT NOCOPY VARCHAR2)
IS
   -- Define Constants for API version and API name
   C_api_version_number       CONSTANT NUMBER       := 1.0;
   C_api_name                 CONSTANT VARCHAR2(30) := 'QUERY_RES';
   C_Module_Name              Constant Varchar2(2000) := 'inv.plsql.inv_maintain_reservation_pub.maintain_reservation';
   C_Debug_Enabled            Constant Number := 1 ;

   --l_debug                  NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
   l_Fnd_Log_Message          VARCHAR2(2000);
   l_Msg_Index_Out            Number;

   l_rsv_rec           inv_reservation_global.mtl_reservation_rec_type;
   --l_msg_count         NUMBER;
   --l_msg_data          VARCHAR2(240);
   l_rsv_id            NUMBER;
   l_return_status     VARCHAR2(1);
   l_error_code        NUMBER;
   l_rsv_array         inv_reservation_global.mtl_reservation_tbl_type;
   l_record_count      NUMBER;
   l_error_text        VARCHAR2(2000);
BEGIN
   l_Fnd_Log_message := 'Begining of procedure :';
   -- Dbms_output.Put_line('Begining Of Procedure');
   -- Fnd_Log_Debug(Fnd_Log.Level_Procedure, C_Module_name, l_Fnd_Log_Message);

   -- Log message in trace file
   IF G_debug= C_Debug_Enabled THEN
      G_Version_Printed := TRUE ;
      mydebug(l_Fnd_Log_Message,c_api_name,9);
      G_Version_Printed := FALSE ;
   END IF;

   -- Bug 3600118: Initialize return status variable
   l_return_status := FND_API.g_ret_sts_success;

   IF p_supply_source_header_id is not null THEN
       l_rsv_rec.supply_source_header_id := p_supply_source_header_id;   --supply header id
   END IF;

   IF p_supply_source_line_id is not null THEN
       l_rsv_rec.supply_source_line_id := p_supply_source_line_id;   -- supply line id
   END IF;

   IF p_supply_source_type_id IS NULL THEN
        FND_MESSAGE.SET_NAME('INV','INV_API_NULL_SOURCE_TYPE_ID');
        FND_MSG_PUB.Add;
        RAISE fnd_api.g_exc_unexpected_error;
   ELSIF p_supply_source_type_id NOT IN
         (inv_reservation_global.g_source_type_po,
          inv_reservation_global.g_source_type_internal_req,
          inv_reservation_global.g_source_type_req) THEN
        FND_MESSAGE.SET_NAME('INV','INV_API_INVALID_SOURCE_TYPE_ID');
        FND_MSG_PUB.Add;
        RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   IF p_project_id is not null THEN
       l_rsv_rec.project_id       := p_project_id;   -- project id
   END IF;

   IF p_task_id is not null THEN
       l_rsv_rec.task_id          := p_task_id;   -- task id
   END IF;

   l_rsv_rec.supply_source_type_id := p_supply_source_type_id;

   inv_reservation_pvt.query_reservation
     (
        p_api_version_number        => 1.0
      , p_init_msg_lst              => fnd_api.g_false
      , x_return_status             => l_return_status
      , x_msg_count                 => x_msg_count
      , x_msg_data                  => x_msg_data
      , p_query_input               => l_rsv_rec
      , p_lock_records              => fnd_api.g_false
      , p_sort_by_req_date          => inv_reservation_global.g_query_demand_ship_date_asc
      , p_cancel_order_mode         => inv_reservation_global.g_cancel_order_no
      , x_mtl_reservation_tbl       => l_rsv_array
      , x_mtl_reservation_tbl_count => l_record_count
      , x_error_code                => l_error_code
      );

   If g_debug= C_Debug_Enabled Then
         l_Fnd_Log_Message := 'l_return_status: '|| l_return_status;
         mydebug(l_Fnd_Log_Message,c_api_name,9);
   End If;

   x_return_status := l_return_status;

   If x_return_status = fnd_api.g_ret_sts_success THEN
      l_Fnd_Log_message := 'Calling query_reservation API was successful ';
      -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );
      x_rsv_array := l_rsv_array;
      x_record_count := l_record_count;

      IF G_debug= C_Debug_Enabled THEN
         mydebug(l_Fnd_Log_Message, c_api_name,9);
      END IF;
   else
      l_Fnd_Log_message := 'Error while calling query_reservation API ';
      -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );
      x_record_count := -1;
      IF G_debug= C_Debug_Enabled THEN
         mydebug(l_Fnd_Log_Message, c_api_name,9);
      END IF;
   end if;

   -- Call fnd_log api at the end of the API
   l_Fnd_Log_message := 'At the end of procedure :';
   -- Fnd_Log_Debug(Fnd_Log.Level_Procedure,C_Module_name, l_Fnd_Log_Message );

   IF G_debug= C_Debug_Enabled THEN
         mydebug(l_Fnd_Log_Message, c_api_name,9);
   END IF;



EXCEPTION
   WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;
        x_record_count := -1;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );

         -- Call fnd_log api at the end of the API
         l_Fnd_Log_message := 'When Expected exception raised for procedure :' ;
         -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );

         -- Log message in trace file
         IF G_debug= C_Debug_Enabled THEN
             mydebug(l_Fnd_Log_Message,c_api_name,9);
         END IF;

         -- Get messages from stack and log them in fnd tables
         If X_Msg_Count = 1 Then
            -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, X_Msg_Data );
            -- Log message in trace file
            If G_debug= C_Debug_Enabled THEN
              mydebug(l_Fnd_Log_Message,c_api_name,9);
            End If;
         Elsif x_msg_count > 1 Then
             For I In 1..X_Msg_Count Loop
               FND_MSG_PUB.Get
                (p_msg_index     => i,
                 p_encoded       => 'F',
                 p_data          => l_Fnd_Log_Message,
                 p_msg_index_out => l_msg_index_out );

                -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );

                -- Log message in trace file
                IF G_debug= C_Debug_Enabled THEN
                    mydebug(l_Fnd_Log_Message,c_api_name,9);
                END IF;
             End Loop ;
         End If;


     WHEN fnd_api.g_exc_unexpected_error THEN
          x_return_status := fnd_api.g_ret_sts_unexp_error ;
          x_record_count := -1;

          --  Get message count and data
          fnd_msg_pub.count_and_get
            (  p_count  => x_msg_count
             , p_data   => x_msg_data
              );
          -- Call fnd_log api at the end of the API
          l_Fnd_Log_message := 'When unexpected exception raised for procedure :';
          -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );

          -- Log message in trace file
          IF G_debug= C_Debug_Enabled THEN
              mydebug(l_Fnd_Log_Message,c_api_name,9);
          END IF;

          -- Get messages from stack and log them in fnd tables
          If X_Msg_Count = 1 Then
            -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, X_Msg_Data );

            -- Log message in trace file
            IF G_debug= C_Debug_Enabled THEN
              mydebug(l_Fnd_Log_Message,c_api_name,9);
            END IF;
          Elsif X_Msg_Count > 1 Then
             For I In 1..X_Msg_Count Loop
               FND_MSG_PUB.Get
                (p_msg_index     => i,
                 p_encoded       => 'F',
                 p_data          => l_Fnd_Log_Message,
                 p_msg_index_out => l_msg_index_out );

                -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );

                -- Log message in trace file
                IF G_debug= C_Debug_Enabled THEN
                    mydebug(l_Fnd_Log_Message,c_api_name,9);
                END IF;
             End Loop ;
          End If;

   WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;
        x_record_count := -1;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , c_api_name
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
           );

        -- Call fnd_log api at the end of the API
        l_Fnd_Log_message := 'When Others exception raised for procedure :' || G_Pkg_Name || '.' || C_API_Name ;
        -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );

        -- Log message in trace file
        IF G_debug= C_Debug_Enabled THEN
            mydebug(l_Fnd_Log_Message,c_api_name,9);
        END IF;

        -- Get messages from stack and log them in fnd tables
        If X_Msg_Count = 1 Then
          -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, X_Msg_Data );

          -- Log message in trace file
          If G_debug= C_Debug_Enabled Then
             mydebug(l_Fnd_Log_Message,c_api_name,9);
           End If;
        Elsif X_Msg_Count > 1 Then
            For I In 1..X_Msg_Count Loop
              FND_MSG_PUB.Get
               (p_msg_index     => i,
                p_encoded       => 'F',
                p_data          => l_Fnd_Log_Message,
                p_msg_index_out => l_msg_index_out );

               -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );

               -- Log message in trace file
               IF G_debug= C_Debug_Enabled THEN
                   mydebug(l_Fnd_Log_Message,c_api_name,9);
               END IF;
            End Loop ;
     End If;
END;


--
-- this procedure checks whether a reservation exists
--
FUNCTION EXISTS_RESERVATION( p_supply_source_header_id  IN NUMBER DEFAULT NULL
                           , p_supply_source_line_id    IN NUMBER DEFAULT NULL
                           , p_supply_source_type_id        IN NUMBER DEFAULT inv_reservation_global.g_source_type_po)

RETURN BOOLEAN IS
     -- Define Constants for API version and API name
     C_api_version_number       CONSTANT NUMBER       := 1.0;
     C_api_name                 CONSTANT VARCHAR2(30) := 'EXISTS_RESERVATION';
     C_Module_Name              Constant Varchar2(2000) := 'inv.plsql.inv_maintain_reservation_pub.maintain_reservation';
     C_Debug_Enabled            Constant Number := 1 ;

     --l_debug                  NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
     l_Fnd_Log_Message          VARCHAR2(2000);
     l_Msg_Index_Out            Number;

     l_rsv_array                inv_reservation_global.mtl_reservation_tbl_type;
     l_record_count             NUMBER;
     l_msg_count                NUMBER;
     l_msg_data                 VARCHAR2(2000);
     l_return_status            VARCHAR2(1);

BEGIN

     l_Fnd_Log_message := 'Begining of procedure :';
     -- Dbms_output.Put_line('Begining Of Procedure');
     -- Fnd_Log_Debug(Fnd_Log.Level_Procedure, C_Module_name, l_Fnd_Log_Message);

     -- Log message in trace file
     IF G_debug= C_Debug_Enabled THEN
        G_Version_Printed := TRUE ;
        mydebug(l_Fnd_Log_Message,c_api_name,9);
        G_Version_Printed := FALSE ;
     END IF;

     QUERY_RES
        ( p_supply_source_header_id => p_supply_source_header_id
         ,p_supply_source_line_id   => p_supply_source_line_id
         ,p_supply_source_type_id   => p_supply_source_type_id
         ,p_project_id              => NULL
         ,p_task_id                 => NULL
         ,x_rsv_array               => l_rsv_array
         ,x_record_count            => l_record_count
         ,x_msg_count               => l_msg_count
         ,x_msg_data                => l_msg_data
         ,x_return_status           => l_return_status);

     If g_debug= C_Debug_Enabled Then
           l_Fnd_Log_Message := 'l_return_status: '|| l_return_status;
           mydebug(l_Fnd_Log_Message,c_api_name,9);
     End If;


     If l_return_status = fnd_api.g_ret_sts_success THEN
        l_Fnd_Log_message := 'Calling QUERY_RES API was successful ';
        -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );
        IF G_debug= C_Debug_Enabled THEN
           mydebug(l_Fnd_Log_Message, c_api_name,9);
        END IF;

        IF l_record_count > 0 THEN
               return TRUE;
        ELSE
               return FALSE;
        END IF;
        --?? what should be returned if l_return_status is not 'S'.
        -- should we return fales. the reason is
        -- if a reservation is existing, .... then we think it is not,
        --  then we were trying to transfer from req to PO, which will fail.
        -- if a reservation is not existing, then no impact..
        -- or if we returns TRUE.  THEN
        -- if a reservation exists, then no impact....
        -- if a reservation is not existing, then we will update the reservation...
     else
        l_Fnd_Log_message := 'Error while calling QUERY_RES API ';
        -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );
        IF G_debug= C_Debug_Enabled THEN
           mydebug(l_Fnd_Log_Message, c_api_name,9);
        END IF;
        return FALSE;
     end if;

     -- Call fnd_log api at the end of the API
     l_Fnd_Log_message := 'At the end of procedure :';
     -- Fnd_Log_Debug(Fnd_Log.Level_Procedure,C_Module_name, l_Fnd_Log_Message );

     IF G_debug= C_Debug_Enabled THEN
           mydebug(l_Fnd_Log_Message, c_api_name,9);
     END IF;


EXCEPTION
    WHEN OTHERS THEN
        l_Fnd_Log_message := 'OTHER exception happens when calling QUERY_RES API :';
        -- Fnd_Log_Debug(Fnd_Log.Level_Procedure,C_Module_name, l_Fnd_Log_Message );

        IF G_debug= C_Debug_Enabled THEN
              mydebug(l_Fnd_Log_Message, c_api_name,9);
        END IF;
        return FALSE;
END;


-- this procedure finds the reservation on the requisition and returns the reservation records
-- so far we should only have one record returned for gaven requisition_line_id.
PROCEDURE GET_REQ_LINE_RES
(
  p_req_line_id           IN  NUMBER
 ,p_project_id            IN  NUMBER
 ,p_task_id               IN  NUMBER
 ,x_res_array             OUT NOCOPY inv_reservation_global.mtl_reservation_tbl_type
 ,x_record_count          OUT NOCOPY NUMBER
)
IS
    -- Define Constants for API version and API name
    C_api_version_number       CONSTANT NUMBER       := 1.0;
    C_api_name                 CONSTANT VARCHAR2(30) := 'GET_REQ_LINE_RES';
    C_Module_Name              Constant Varchar2(2000) := 'inv.plsql.inv_maintain_reservation_pub.maintain_reservation';
    C_Debug_Enabled            Constant Number := 1 ;

    --l_debug                  NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_Fnd_Log_Message          VARCHAR2(2000);
    l_Msg_Index_Out            Number;

    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(2000);
    l_record_count             NUMBER;
    l_return_status            VARCHAR2(1);

BEGIN
      -- this procedure checks whether a reservation exists on the req line
      -- if so, it returns the reservation record

      l_Fnd_Log_message := 'Begining of procedure :';
      -- Dbms_output.Put_line('Begining Of Procedure');
      -- Fnd_Log_Debug(Fnd_Log.Level_Procedure, C_Module_name, l_Fnd_Log_Message);

      -- Log message in trace file
      IF G_debug= C_Debug_Enabled THEN
         G_Version_Printed := TRUE ;
         mydebug(l_Fnd_Log_Message,c_api_name,9);
         G_Version_Printed := FALSE ;
      END IF;

      -- Bug 3600118: Initialize return status variable
      --l_return_status := FND_API.g_ret_sts_success;
      --
      -- bug fix 2341308
      if p_req_line_id IS NULL then
         l_Fnd_Log_message := 'p_req_line_id is NULL :';
         IF G_debug= C_Debug_Enabled THEN
            mydebug(l_Fnd_Log_Message,c_api_name,9);
         END IF;
         x_record_count := -1;
         return;
      end if;


      QUERY_RES
          (p_supply_source_line_id   => p_req_line_id
          ,p_supply_source_type_id   => inv_reservation_global.g_source_type_req
          ,p_project_id              => p_project_id
          ,p_task_id                 => p_task_id
          ,x_rsv_array               => x_res_array
          ,x_record_count            => l_record_count
          ,x_msg_count               => l_msg_count
          ,x_msg_data                => l_msg_data
          ,x_return_status           => l_return_status);


      If g_debug= C_Debug_Enabled Then
            l_Fnd_Log_Message := 'l_return_status: '|| l_return_status;
            mydebug(l_Fnd_Log_Message,c_api_name,9);
      End If;

      If l_return_status = fnd_api.g_ret_sts_success THEN
         l_Fnd_Log_message := 'Calling QUERY_RES API was successful ';
         -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );
         IF G_debug= C_Debug_Enabled THEN
            mydebug(l_Fnd_Log_Message, c_api_name,9);
         END IF;
         x_record_count := l_record_count;
      else
         l_Fnd_Log_message := 'Error while calling QUERY_RES API ';
         -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );
         IF G_debug= C_Debug_Enabled THEN
            mydebug(l_Fnd_Log_Message, c_api_name,9);
         END IF;
         x_record_count := -1;
      end if;

      -- Call fnd_log api at the end of the API
      l_Fnd_Log_message := 'At the end of procedure :';
      -- -- Fnd_Log_Debug(Fnd_Log.Level_Procedure,C_Module_name, l_Fnd_Log_Message );

      IF G_debug= C_Debug_Enabled THEN
            mydebug(l_Fnd_Log_Message, c_api_name,9);
      END IF;

EXCEPTION
    WHEN OTHERS THEN
       x_record_count := -1;
       l_Fnd_Log_message := ' OTHER exceptions happens ';
       IF G_debug= C_Debug_Enabled THEN
              mydebug(l_Fnd_Log_Message, c_api_name,9);
       END IF;
END;


--
-- this procedure calls the inventory API update_reservation with the appropriate parameters
--
PROCEDURE UPDATE_RES
   (p_supply_source_header_id       IN NUMBER
   ,p_supply_source_line_id         IN NUMBER
   ,p_supply_source_type_id         IN NUMBER
   ,p_primary_uom_code              IN VARCHAR2 DEFAULT NULL
   ,p_primary_reservation_quantity  IN NUMBER
   ,p_reservation_id                IN NUMBER
   ,p_project_id                    IN NUMBER
   ,p_task_id                       IN NUMBER
   ,x_msg_count                     OUT NOCOPY NUMBER
   ,x_msg_data                      OUT NOCOPY VARCHAR2
   ,x_return_status                 OUT NOCOPY VARCHAR2)
IS

   -- Define Constants for API version and API name
   C_api_version_number       CONSTANT NUMBER       := 1.0;
   C_api_name                 CONSTANT VARCHAR2(30) := 'UPDATE_RES';
   C_Module_Name              Constant Varchar2(2000) := 'inv.plsql.inv_maintain_reservation_pub.maintain_reservation';
   C_Debug_Enabled            Constant Number := 1 ;

   --l_debug                  NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
   l_Fnd_Log_Message          VARCHAR2(2000);
   l_Msg_Index_Out            Number;

   l_rsv              inv_reservation_global.mtl_reservation_rec_type;
   l_rsv_new          inv_reservation_global.mtl_reservation_rec_type;
   --l_msg_count        NUMBER;
   --l_msg_data         VARCHAR2(240);
   l_rsv_id           NUMBER;
   l_return_status    VARCHAR2(1);
BEGIN
   l_Fnd_Log_message := 'Begining of procedure :';
   -- Dbms_output.Put_line('Begining Of Procedure');
   -- Fnd_Log_Debug(Fnd_Log.Level_Procedure, C_Module_name, l_Fnd_Log_Message);

   -- Log message in trace file
   IF G_debug= C_Debug_Enabled THEN
      G_Version_Printed := TRUE ;
      mydebug(l_Fnd_Log_Message,c_api_name,9);
      G_Version_Printed := FALSE ;
   END IF;

   -- Bug 3600118: Initialize return status variable
   l_return_status := FND_API.g_ret_sts_success;

   -- find the existing reservation
   -- REQ or PO id's
   l_rsv.supply_source_header_id := p_supply_source_header_id;
   l_rsv.supply_source_line_id   := p_supply_source_line_id;
   l_rsv.supply_source_type_id   := p_supply_source_type_id;
   l_rsv.project_id              := p_project_id;
   l_rsv.task_id                 := p_task_id;

   IF p_reservation_id IS NOT NULL THEN
      l_rsv.reservation_id := p_reservation_id;
   END IF;

-- specify the new values
   l_rsv_new.primary_reservation_quantity := p_primary_reservation_quantity;
--
   inv_reservation_pub.update_reservation
     (
        p_api_version_number        => 1.0
      , p_init_msg_lst              => fnd_api.g_false
      , x_return_status             => l_return_status
      , x_msg_count                 => x_msg_count
      , x_msg_data                  => x_msg_data
      , p_original_rsv_rec          => l_rsv
      , p_to_rsv_rec                => l_rsv_new
      , p_original_serial_number    => g_dummy_sn_tbl -- no serial contorl
      , p_to_serial_number          => g_dummy_sn_tbl -- no serial control
      , p_validation_flag           => fnd_api.g_true
      );

   If g_debug= C_Debug_Enabled Then
         l_Fnd_Log_Message := 'l_return_status: '|| l_return_status;
         mydebug(l_Fnd_Log_Message,c_api_name,9);
   End If;

   x_return_status := l_return_status;

   If x_return_status = fnd_api.g_ret_sts_success THEN
      l_Fnd_Log_message := 'Calling update_reservation API was successful ';
      -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );
      IF G_debug= C_Debug_Enabled THEN
         mydebug(l_Fnd_Log_Message, c_api_name,9);
      END IF;
   else
      l_Fnd_Log_message := 'Error while calling update_reservation API ';
      -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );
      IF G_debug= C_Debug_Enabled THEN
         mydebug(l_Fnd_Log_Message, c_api_name,9);
      END IF;
   end if;

   -- Call fnd_log api at the end of the API
   l_Fnd_Log_message := 'At the end of procedure :';
   -- -- Fnd_Log_Debug(Fnd_Log.Level_Procedure,C_Module_name, l_Fnd_Log_Message );

   IF G_debug= C_Debug_Enabled THEN
         mydebug(l_Fnd_Log_Message, c_api_name,9);
   END IF;


EXCEPTION
   WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );

         -- Call fnd_log api at the end of the API
         l_Fnd_Log_message := 'When Expected exception raised for procedure :' ;
         -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );

         -- Log message in trace file
         IF G_debug= C_Debug_Enabled THEN
             mydebug(l_Fnd_Log_Message,c_api_name,9);
         END IF;

         -- Get messages from stack and log them in fnd tables
         If X_Msg_Count = 1 Then
            -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, X_Msg_Data );
            -- Log message in trace file
            If G_debug= C_Debug_Enabled THEN
              mydebug(l_Fnd_Log_Message,c_api_name,9);
            End If;
         Elsif x_msg_count > 1 Then
             For I In 1..X_Msg_Count Loop
               FND_MSG_PUB.Get
                (p_msg_index     => i,
                 p_encoded       => 'F',
                 p_data          => l_Fnd_Log_Message,
                 p_msg_index_out => l_msg_index_out );

                -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );

                -- Log message in trace file
                IF G_debug= C_Debug_Enabled THEN
                    mydebug(l_Fnd_Log_Message,c_api_name,9);
                END IF;
             End Loop ;
         End If;


     WHEN fnd_api.g_exc_unexpected_error THEN
          x_return_status := fnd_api.g_ret_sts_unexp_error ;

          --  Get message count and data
          fnd_msg_pub.count_and_get
            (  p_count  => x_msg_count
             , p_data   => x_msg_data
              );
          -- Call fnd_log api at the end of the API
          l_Fnd_Log_message := 'When unexpected exception raised for procedure :';
          -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );

          -- Log message in trace file
          IF G_debug= C_Debug_Enabled THEN
              mydebug(l_Fnd_Log_Message,c_api_name,9);
          END IF;

          -- Get messages from stack and log them in fnd tables
          If X_Msg_Count = 1 Then
            -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, X_Msg_Data );

            -- Log message in trace file
            IF G_debug= C_Debug_Enabled THEN
              mydebug(l_Fnd_Log_Message,c_api_name,9);
            END IF;
          Elsif X_Msg_Count > 1 Then
             For I In 1..X_Msg_Count Loop
               FND_MSG_PUB.Get
                (p_msg_index     => i,
                 p_encoded       => 'F',
                 p_data          => l_Fnd_Log_Message,
                 p_msg_index_out => l_msg_index_out );

                -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );

                -- Log message in trace file
                IF G_debug= C_Debug_Enabled THEN
                    mydebug(l_Fnd_Log_Message,c_api_name,9);
                END IF;
             End Loop ;
          End If;

   WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , c_api_name
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
           );

        -- Call fnd_log api at the end of the API
        l_Fnd_Log_message := 'When Others exception raised for procedure :' || G_Pkg_Name || '.' || C_API_Name ;
        -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );

        -- Log message in trace file
        IF G_debug= C_Debug_Enabled THEN
            mydebug(l_Fnd_Log_Message,c_api_name,9);
        END IF;

        -- Get messages from stack and log them in fnd tables
        If X_Msg_Count = 1 Then
          -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, X_Msg_Data );

          -- Log message in trace file
          If G_debug= C_Debug_Enabled Then
             mydebug(l_Fnd_Log_Message,c_api_name,9);
           End If;
        Elsif X_Msg_Count > 1 Then
            For I In 1..X_Msg_Count Loop
              FND_MSG_PUB.Get
               (p_msg_index     => i,
                p_encoded       => 'F',
                p_data          => l_Fnd_Log_Message,
                p_msg_index_out => l_msg_index_out );

               -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );

               -- Log message in trace file
               IF G_debug= C_Debug_Enabled THEN
                   mydebug(l_Fnd_Log_Message,c_api_name,9);
               END IF;
            End Loop ;
       End If;
END;



--
-- this procedure calls the inventory API transfer_reservation with the appropriate parameters
--
PROCEDURE TRANSFER_RES
(p_from_reservation_id       IN NUMBER    DEFAULT NULL
,p_from_source_header_id     IN NUMBER    DEFAULT NULL
,p_from_source_line_id       IN NUMBER    DEFAULT NULL
,p_supply_source_type_id     IN NUMBER    DEFAULT NULL
,p_to_source_header_id       IN NUMBER    DEFAULT NULL
,p_to_source_line_id         IN NUMBER    DEFAULT NULL
,p_to_supply_source_type_id  IN NUMBER    DEFAULT NULL
,p_subinventory_code         IN VARCHAR2  DEFAULT NULL
,p_locator_id                IN NUMBER    DEFAULT NULL
,p_lot_number                IN VARCHAR2  DEFAULT NULL
,p_revision                  IN VARCHAR2  DEFAULT NULL
,p_lpn_id                    IN VARCHAR2  DEFAULT NULL --#Bug3020166
,p_primary_uom_code          IN VARCHAR2  DEFAULT NULL
,p_primary_res_quantity      IN NUMBER    DEFAULT NULL
,p_secondary_uom_code        IN VARCHAR2  DEFAULT NULL
,p_secondary_res_quantity    IN NUMBER    DEFAULT NULL
,x_msg_count                OUT NOCOPY    NUMBER
,x_msg_data                 OUT NOCOPY    VARCHAR2
,x_return_status            OUT NOCOPY    VARCHAR2)
IS

   -- Define Constants for API version and API name
   C_api_version_number       CONSTANT NUMBER       := 1.0;
   C_api_name                 CONSTANT VARCHAR2(30) := 'TRANSFER_RES';
   C_Module_Name              Constant Varchar2(2000) := 'inv.plsql.inv_maintain_reservation_pub.maintain_reservation';
   C_Debug_Enabled            Constant Number := 1 ;

   --l_debug                    NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
   l_Fnd_Log_Message          VARCHAR2(2000);
   l_Msg_Index_Out            Number;

   l_rsv         inv_reservation_global.mtl_reservation_rec_type;
   l_rsv_new     inv_reservation_global.mtl_reservation_rec_type;
   --l_msg_count   NUMBER;
   --l_msg_data    VARCHAR2(240);
   l_rsv_id         NUMBER;
   l_return_status  VARCHAR2(1);
   l_new_rsv_id     NUMBER;
BEGIN
   l_Fnd_Log_message := 'Begining of procedure :';
   -- Dbms_output.Put_line('Begining Of Procedure');
   -- Fnd_Log_Debug(Fnd_Log.Level_Procedure, C_Module_name, l_Fnd_Log_Message);

   -- Log message in trace file
   IF G_debug= C_Debug_Enabled THEN
      G_Version_Printed := TRUE ;
      mydebug(l_Fnd_Log_Message,c_api_name,9);
      G_Version_Printed := FALSE ;
   END IF;

   -- Bug 3600118: Initialize return status variable
   l_return_status := FND_API.g_ret_sts_success;

   -- print out IN parameter values
   IF g_debug= C_Debug_Enabled THEN
     l_Fnd_Log_Message := 'p_from_reservation_id:' || p_from_reservation_id;
     mydebug(l_Fnd_Log_Message, c_api_name,9);
      l_Fnd_Log_Message := 'p_from_source_header_id:' || p_from_source_header_id;
         mydebug(l_Fnd_Log_Message, c_api_name,9);
         l_Fnd_Log_Message := 'p_from_source_line_id: ' || p_from_source_line_id;
         mydebug(l_Fnd_Log_Message, c_api_name,9);
         l_Fnd_Log_Message := 'p_supply_source_type_id :'||p_supply_source_type_id;
         mydebug(l_Fnd_Log_Message, c_api_name,9);
         l_Fnd_Log_Message := 'p_to_source_header_id :'||p_to_source_header_id;
         mydebug(l_Fnd_Log_Message, c_api_name,9);
         l_Fnd_Log_Message := 'p_to_source_line_id: '||p_to_source_line_id;
         mydebug(l_Fnd_Log_Message, c_api_name,9);
         l_Fnd_Log_Message := 'p_to_supply_source_type_id:'||p_to_supply_source_type_id;
         mydebug(l_Fnd_Log_Message, c_api_name,9);
         l_Fnd_Log_Message := 'p_subinventory_code:'||p_subinventory_code;
         mydebug(l_Fnd_Log_Message, c_api_name,9);
         l_Fnd_Log_Message := 'p_locator_id:'||p_locator_id;
         mydebug(l_Fnd_Log_Message, c_api_name,9);
         l_Fnd_Log_Message := 'p_lot_number:'||p_lot_number;
         mydebug(l_Fnd_Log_Message, c_api_name,9);
         l_Fnd_Log_Message := 'p_revision:'||p_revision;
         mydebug(l_Fnd_Log_Message, c_api_name,9);
         l_Fnd_Log_Message := 'p_lpn_id:'||p_lpn_id;
         mydebug(l_Fnd_Log_Message, c_api_name,9);
         l_Fnd_Log_Message := 'p_primary_uom_code: ' || p_primary_uom_code;
         mydebug(l_Fnd_Log_Message, c_api_name,9);
         l_Fnd_Log_Message := 'p_primary_res_quantity : '|| p_primary_res_quantity;
         mydebug(l_Fnd_Log_Message, c_api_name,9);
         l_Fnd_Log_Message := 'p_secondary_uom_code: ' || p_secondary_uom_code;
         mydebug(l_Fnd_Log_Message, c_api_name,9);
         l_Fnd_Log_Message := 'p_secondary_res_quantity : '|| p_secondary_res_quantity;
         mydebug(l_Fnd_Log_Message, c_api_name,9);
   END IF;

   -- REQ or PO id's

   l_rsv.supply_source_header_id      := p_from_source_header_id;
   l_rsv.supply_source_line_id        := p_from_source_line_id ;
   l_rsv.supply_source_type_id        := p_supply_source_type_id;

   -- specify other new values  if any
   l_rsv_new.supply_source_header_id      := p_to_source_header_id;
   l_rsv_new.supply_source_line_id        := p_to_source_line_id ;
   l_rsv_new.supply_source_type_id        := p_to_supply_source_type_id;
   l_rsv_new.primary_reservation_quantity := p_primary_res_quantity;

   IF p_secondary_uom_code IS NOT NULL THEN
      l_rsv_new.secondary_reservation_quantity := p_secondary_res_quantity;
      l_rsv_new.secondary_uom_code             := p_secondary_uom_code;
   END IF;

-- these values will be available for a transfer from PO to inventory (receipt)

   IF p_from_reservation_id IS NOT NULL THEN
      l_rsv.reservation_id := p_from_reservation_id;
   END IF;

   IF p_subinventory_code is not NULL THEN
      l_rsv_new.subinventory_code            := p_subinventory_code;
   END IF;

   IF p_locator_id is not NULL THEN
      l_rsv_new.locator_id                   := p_locator_id;
   END IF;

   IF p_lot_number is not NULL THEN
      l_rsv_new.lot_number                   := p_lot_number;
   END IF;

   IF p_revision is not NULL THEN
      l_rsv_new.revision                     := p_revision;
   END IF;

/*Bug 3020166 Assigning p_lpn_id got from rcv_transactions to the lpn_id in the
  record type */
   IF p_lpn_id is not NULL THEN
      l_rsv_new.lpn_id                       := p_lpn_id;
   END IF;

   inv_reservation_pvt.transfer_reservation
     (
        p_api_version_number        => 1.0
      , p_init_msg_lst              => fnd_api.g_false
      , x_return_status             => l_return_status
      , x_msg_count                 => x_msg_count
      , x_msg_data                  => x_msg_data
      --, p_is_transfer_supply        => fnd_api.g_true
      , p_original_rsv_rec          => l_rsv
      , p_to_rsv_rec                => l_rsv_new
      , p_original_serial_number    => g_dummy_sn_tbl -- no serial contorl
     -- , p_to_serial_number          => g_dummy_sn_tbl -- no serial control
      , p_validation_flag           => fnd_api.g_true
      , x_reservation_id            => l_new_rsv_id
      );

   If g_debug= C_Debug_Enabled Then
          l_Fnd_Log_Message := 'l_return_status: '|| l_return_status;
          mydebug(l_Fnd_Log_Message,c_api_name,9);
   End If;

   x_return_status := l_return_status;

   If x_return_status = fnd_api.g_ret_sts_success THEN
      l_Fnd_Log_message := 'Calling transfer_reservation API was successful ';
      -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );
      IF G_debug= C_Debug_Enabled THEN
         mydebug(l_Fnd_Log_Message, c_api_name,9);
      END IF;
   else
      l_Fnd_Log_message := 'Error while calling transfer_reservation API ';
      -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );
      IF G_debug= C_Debug_Enabled THEN
         mydebug(l_Fnd_Log_Message, c_api_name,9);
      END IF;
   end if;

   -- Call fnd_log api at the end of the API
   l_Fnd_Log_message := 'At the end of procedure :';
   -- -- Fnd_Log_Debug(Fnd_Log.Level_Procedure,C_Module_name, l_Fnd_Log_Message );

   IF G_debug= C_Debug_Enabled THEN
         mydebug(l_Fnd_Log_Message, c_api_name,9);
   END IF;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
       x_return_status := fnd_api.g_ret_sts_error;

       --  Get message count and data
       fnd_msg_pub.count_and_get
         (  p_count => x_msg_count
          , p_data  => x_msg_data
          );

        -- Call fnd_log api at the end of the API
        l_Fnd_Log_message := 'When Expected exception raised for procedure :' ;
        -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );

        -- Log message in trace file
        IF G_debug= C_Debug_Enabled THEN
            mydebug(l_Fnd_Log_Message,c_api_name,9);
        END IF;

        -- Get messages from stack and log them in fnd tables
        If X_Msg_Count = 1 Then
           -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, X_Msg_Data );
           -- Log message in trace file
           If G_debug= C_Debug_Enabled THEN
             mydebug(l_Fnd_Log_Message,c_api_name,9);
           End If;
        Elsif x_msg_count > 1 Then
            For I In 1..X_Msg_Count Loop
              FND_MSG_PUB.Get
               (p_msg_index     => i,
                p_encoded       => 'F',
                p_data          => l_Fnd_Log_Message,
                p_msg_index_out => l_msg_index_out );

               -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );

               -- Log message in trace file
               IF G_debug= C_Debug_Enabled THEN
                   mydebug(l_Fnd_Log_Message,c_api_name,9);
               END IF;
            End Loop ;
        End If;

    WHEN fnd_api.g_exc_unexpected_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         --  Get message count and data
         fnd_msg_pub.count_and_get
           (  p_count  => x_msg_count
            , p_data   => x_msg_data
             );
         -- Call fnd_log api at the end of the API
         l_Fnd_Log_message := 'When unexpected exception raised for procedure :';
         -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );

         -- Log message in trace file
         IF G_debug= C_Debug_Enabled THEN
             mydebug(l_Fnd_Log_Message,c_api_name,9);
         END IF;

         -- Get messages from stack and log them in fnd tables
         If X_Msg_Count = 1 Then
           -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, X_Msg_Data );

           -- Log message in trace file
           IF G_debug= C_Debug_Enabled THEN
             mydebug(l_Fnd_Log_Message,c_api_name,9);
           END IF;
         Elsif X_Msg_Count > 1 Then
            For I In 1..X_Msg_Count Loop
              FND_MSG_PUB.Get
               (p_msg_index     => i,
                p_encoded       => 'F',
                p_data          => l_Fnd_Log_Message,
                p_msg_index_out => l_msg_index_out );

               -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );

               -- Log message in trace file
               IF G_debug= C_Debug_Enabled THEN
                   mydebug(l_Fnd_Log_Message,c_api_name,9);
               END IF;
            End Loop ;
         End If;

  WHEN OTHERS THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error ;

       IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
          fnd_msg_pub.add_exc_msg
            (  g_pkg_name
             , c_api_name
             );
       END IF;

       --  Get message count and data
       fnd_msg_pub.count_and_get
         (  p_count  => x_msg_count
          , p_data   => x_msg_data
          );

       -- Call fnd_log api at the end of the API
       l_Fnd_Log_message := 'When Others exception raised for procedure :' || G_Pkg_Name || '.' || C_API_Name ;
       -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );

       -- Log message in trace file
       IF G_debug= C_Debug_Enabled THEN
           mydebug(l_Fnd_Log_Message,c_api_name,9);
       END IF;

       -- Get messages from stack and log them in fnd tables
       If X_Msg_Count = 1 Then
         -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, X_Msg_Data );

         -- Log message in trace file
         If G_debug= C_Debug_Enabled Then
            mydebug(l_Fnd_Log_Message,c_api_name,9);
          End If;
       Elsif X_Msg_Count > 1 Then
           For I In 1..X_Msg_Count Loop
             FND_MSG_PUB.Get
              (p_msg_index     => i,
               p_encoded       => 'F',
               p_data          => l_Fnd_Log_Message,
               p_msg_index_out => l_msg_index_out );

              -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );

              -- Log message in trace file
              IF G_debug= C_Debug_Enabled THEN
                  mydebug(l_Fnd_Log_Message,c_api_name,9);
              END IF;
           End Loop ;
      End If;
END;


--
-- this procedure calls inventory API delete_reservation with the appropriate parameters
--
PROCEDURE DELETE_RES
(p_supply_source_header_id  IN NUMBER DEFAULT NULL
,p_supply_source_line_id    IN NUMBER DEFAULT NULL
,p_supply_source_type_id    IN NUMBER DEFAULT NULL
,x_msg_count               OUT NOCOPY NUMBER
,x_msg_data                OUT NOCOPY VARCHAR2
,x_return_status           OUT NOCOPY VARCHAR2)
IS
   -- Define Constants for API version and API name
   C_api_version_number       CONSTANT NUMBER       := 1.0;
   C_api_name                 CONSTANT VARCHAR2(30) := 'DELETE_RES';
   C_Module_Name              Constant Varchar2(2000) := 'inv.plsql.inv_maintain_reservation_pub.maintain_reservation';
   C_Debug_Enabled            Constant Number := 1 ;

   --l_debug                    NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
   l_Fnd_Log_Message          VARCHAR2(2000);
   l_Msg_Index_Out            Number;

   l_rsv       inv_reservation_global.mtl_reservation_rec_type;
   --l_msg_count NUMBER;
   --l_msg_data  VARCHAR2(240);
   l_rsv_id    NUMBER;
   --l_dummy_sn  inv_reservation_global.serial_number_tbl_type;
   l_return_status   VARCHAR2(1);
BEGIN
   l_Fnd_Log_message := 'Begining of procedure :';
   -- Dbms_output.Put_line('Begining Of Procedure');
   -- Fnd_Log_Debug(Fnd_Log.Level_Procedure, C_Module_name, l_Fnd_Log_Message);

   -- Log message in trace file
   IF G_debug= C_Debug_Enabled THEN
      G_Version_Printed := TRUE ;
      mydebug(l_Fnd_Log_Message,c_api_name,9);
      G_Version_Printed := FALSE ;
   END IF;

   -- Bug 3600118: Initialize return status variable
   l_return_status := FND_API.g_ret_sts_success;

   -- print out IN parameter values
   IF G_debug= C_Debug_Enabled THEN
        l_Fnd_Log_Message := 'p_supply_source_header_id: '|| p_supply_source_header_id;
        mydebug(l_Fnd_Log_Message, c_api_name,9);
        l_Fnd_Log_Message := 'p_supply_source_line_id: '|| p_supply_source_line_id;
        mydebug(l_Fnd_Log_Message, c_api_name,9);
        l_Fnd_Log_Message := 'p_supply_source_type_id: '|| p_supply_source_type_id;
        mydebug(l_Fnd_Log_Message, c_api_name,9);
   END IF;

   -- REQ or PO id's
   l_rsv.supply_source_type_id := p_supply_source_type_id;
   IF p_supply_source_header_id IS NOT NULL THEN
     l_rsv.supply_source_header_id := p_supply_source_header_id;
   END IF;

   IF p_supply_source_line_id IS NOT NULL THEN
     l_rsv.supply_source_line_id  := p_supply_source_line_id;
   END IF;
--
   inv_reservation_pub.delete_reservation
     (
        p_api_version_number        => 1.0
      , p_init_msg_lst              => fnd_api.g_false
      , x_return_status             => l_return_status
      , x_msg_count                 => x_msg_count
      , x_msg_data                  => x_msg_data
      , p_rsv_rec                   => l_rsv
      , p_serial_number             => g_dummy_sn_tbl
      );

   If g_debug= C_Debug_Enabled Then
          l_Fnd_Log_Message := 'l_return_status: '|| l_return_status;
          mydebug(l_Fnd_Log_Message,c_api_name,9);
   End If;

   x_return_status := l_return_status;

   If x_return_status = fnd_api.g_ret_sts_success THEN
      l_Fnd_Log_message := 'Calling delete_reservation API was successful ';
      -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );
      IF G_debug= C_Debug_Enabled THEN
         mydebug(l_Fnd_Log_Message, c_api_name,9);
      END IF;
   else
      l_Fnd_Log_message := 'Error while calling delete_reservation API ';
      -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );
      IF G_debug= C_Debug_Enabled THEN
         mydebug(l_Fnd_Log_Message, c_api_name,9);
      END IF;
   end if;

   -- Call fnd_log api at the end of the API
   l_Fnd_Log_message := 'At the end of procedure :';
   -- -- Fnd_Log_Debug(Fnd_Log.Level_Procedure,C_Module_name, l_Fnd_Log_Message );

   IF G_debug= C_Debug_Enabled THEN
         mydebug(l_Fnd_Log_Message, c_api_name,9);
   END IF;
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
       x_return_status := fnd_api.g_ret_sts_error;

       --  Get message count and data
       fnd_msg_pub.count_and_get
         (  p_count => x_msg_count
          , p_data  => x_msg_data
          );

        -- Call fnd_log api at the end of the API
        l_Fnd_Log_message := 'When Expected exception raised for procedure :' ;
        -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );

        -- Log message in trace file
        IF G_debug= C_Debug_Enabled THEN
            mydebug(l_Fnd_Log_Message,c_api_name,9);
        END IF;

        -- Get messages from stack and log them in fnd tables
        If X_Msg_Count = 1 Then
           -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, X_Msg_Data );
           -- Log message in trace file
           If G_debug= C_Debug_Enabled THEN
             mydebug(l_Fnd_Log_Message,c_api_name,9);
           End If;
        Elsif x_msg_count > 1 Then
            For I In 1..X_Msg_Count Loop
              FND_MSG_PUB.Get
               (p_msg_index     => i,
                p_encoded       => 'F',
                p_data          => l_Fnd_Log_Message,
                p_msg_index_out => l_msg_index_out );

               -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );

               -- Log message in trace file
               IF G_debug= C_Debug_Enabled THEN
                   mydebug(l_Fnd_Log_Message,c_api_name,9);
               END IF;
            End Loop ;
        End If;

    WHEN fnd_api.g_exc_unexpected_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         --  Get message count and data
         fnd_msg_pub.count_and_get
           (  p_count  => x_msg_count
            , p_data   => x_msg_data
             );
         -- Call fnd_log api at the end of the API
         l_Fnd_Log_message := 'When unexpected exception raised for procedure :';
         -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );

         -- Log message in trace file
         IF G_debug= C_Debug_Enabled THEN
             mydebug(l_Fnd_Log_Message,c_api_name,9);
         END IF;

         -- Get messages from stack and log them in fnd tables
         If X_Msg_Count = 1 Then
           -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, X_Msg_Data );

           -- Log message in trace file
           IF G_debug= C_Debug_Enabled THEN
             mydebug(l_Fnd_Log_Message,c_api_name,9);
           END IF;
         Elsif X_Msg_Count > 1 Then
            For I In 1..X_Msg_Count Loop
              FND_MSG_PUB.Get
               (p_msg_index     => i,
                p_encoded       => 'F',
                p_data          => l_Fnd_Log_Message,
                p_msg_index_out => l_msg_index_out );

               -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );

               -- Log message in trace file
               IF G_debug= C_Debug_Enabled THEN
                   mydebug(l_Fnd_Log_Message,c_api_name,9);
               END IF;
            End Loop ;
         End If;

  WHEN OTHERS THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error ;

       IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
          fnd_msg_pub.add_exc_msg
            (  g_pkg_name
             , c_api_name
             );
       END IF;

       --  Get message count and data
       fnd_msg_pub.count_and_get
         (  p_count  => x_msg_count
          , p_data   => x_msg_data
          );

       -- Call fnd_log api at the end of the API
       l_Fnd_Log_message := 'When Others exception raised for procedure :' || G_Pkg_Name || '.' || C_API_Name ;
       -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );

       -- Log message in trace file
       IF G_debug= C_Debug_Enabled THEN
           mydebug(l_Fnd_Log_Message,c_api_name,9);
       END IF;

       -- Get messages from stack and log them in fnd tables
       If X_Msg_Count = 1 Then
         -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, X_Msg_Data );

         -- Log message in trace file
         If G_debug= C_Debug_Enabled Then
            mydebug(l_Fnd_Log_Message,c_api_name,9);
          End If;
       Elsif X_Msg_Count > 1 Then
           For I In 1..X_Msg_Count Loop
             FND_MSG_PUB.Get
              (p_msg_index     => i,
               p_encoded       => 'F',
               p_data          => l_Fnd_Log_Message,
               p_msg_index_out => l_msg_index_out );

              -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );

              -- Log message in trace file
              IF G_debug= C_Debug_Enabled THEN
                  mydebug(l_Fnd_Log_Message,c_api_name,9);
              END IF;
           End Loop ;
       End If;
END;

--BUG#3497445
--Procedure below converts the PO Quantity and the Reservation Quantity as per
--the quantity and UOM changes done at the PO_level without altering the PO UOM and the Reservation UOM.

PROCEDURE UOM_CONVERSION
(   p_res_uom        IN  VARCHAR2 ,
    p_primary_uom    IN  VARCHAR2,
    p_po_qty         IN  NUMBER,
    p_po_line_id     IN  NUMBER,
    x_res_qty        IN OUT NOCOPY NUMBER,
    x_po_primary_qty    OUT NOCOPY NUMBER)
IS
   -- Define Constants for API version and API name
   C_api_version_number CONSTANT NUMBER       := 1.0;
   C_api_name           CONSTANT VARCHAR2(30) := 'UOM_CONVERSION';
   C_Module_Name        Constant Varchar2(2000) := 'inv.plsql.inv_maintain_reservation_pub.maintain_reservation';
   C_Debug_Enabled      Constant Number := 1 ;

   --l_debug            NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
   l_fnd_log_message    VARCHAR2(2000);
   l_Msg_Index_Out      Number;

   l_item_id            NUMBER ;
   l_po_uom             VARCHAR2(25);
   l_primary_meas       VARCHAR2(25);
   l_res_meas           VARCHAR2(25);

--Get the Primary UOM and the Reservation UOM,and quantities in PO and Reservation  respectively.
--Make comparisons of the three UOMs and calculate the primary_reservation_quantity and the reservation quantity.

BEGIN
    l_Fnd_Log_message := 'Begining of procedure :';
    -- Dbms_output.Put_line('Begining Of Procedure');
    -- Fnd_Log_Debug(Fnd_Log.Level_Procedure, C_Module_name, l_Fnd_Log_Message);

    -- Log message in trace file
    IF G_debug= C_Debug_Enabled THEN
       G_Version_Printed := TRUE ;
       mydebug(l_Fnd_Log_Message,c_api_name,9);
       G_Version_Printed := FALSE ;
    END IF;

    BEGIN
        SELECT   item_id
               , unit_meas_lookup_code
          INTO   l_item_id
               , l_po_uom
          FROM po_lines_all
         WHERE po_line_id= p_po_line_id;

        SELECT unit_of_measure
          INTO l_primary_meas
          FROM mtl_units_of_measure
         WHERE uom_code = p_primary_uom;

        SELECT unit_of_measure
          INTO l_res_meas
          FROM mtl_units_of_measure
         WHERE uom_code = p_res_uom;

    EXCEPTION
        WHEN OTHERS THEN
        --po_message_s.sql_error('UOM_CONVERSION', '010', sqlcode);
        -- inv message....
           FND_MESSAGE.SET_NAME('INV','INV_RSV_UOM_CONVERSION');
           FND_MSG_PUB.Add;
           IF G_debug= C_Debug_Enabled THEN
              l_Fnd_Log_message := 'OTHERS exception happens when geting item_id, primary_uom, res_uom';
              mydebug(l_Fnd_Log_Message,c_api_name,9);
           END IF;
           RAISE;
    END;

    IF G_debug= C_Debug_Enabled THEN
           l_Fnd_Log_message := 'l_item_id: '|| l_item_id;
           mydebug(l_Fnd_Log_Message,c_api_name,9);
           l_Fnd_Log_message := 'l_primary_meas: '|| l_primary_meas;
           mydebug(l_Fnd_Log_Message,c_api_name,9);
           l_Fnd_Log_message := 'l_res_meas: '|| l_res_meas;
           mydebug(l_Fnd_Log_Message,c_api_name,9);
    END IF;

  --Comparing if all three UOMs are same.

   IF(l_po_uom=l_primary_meas  AND  l_res_meas = l_primary_meas )  THEN
       x_po_primary_qty:=p_po_qty;
       x_res_qty := p_po_qty;
       return;
   END IF;

--Compare the PO and the primary_uom and if different convert the PO quantity in its primary UOM

   IF(l_po_uom <> l_primary_meas ) THEN
   -- remove the dependency on PO, changes to call inv_convert API
      /*po_uom_s.uom_convert(p_po_qty
                          ,l_po_uom
                          ,l_item_id
                          ,l_primary_meas
                          ,x_po_primary_qty);*/

      x_po_primary_qty := inv_convert.inv_um_convert
               (
                 item_id       => l_item_id    --number,
                ,precision     => NULL         --number,
                ,from_quantity => p_po_qty     --number,
                ,from_unit     => l_po_uom     --varchar2,
                ,to_unit       => l_primary_meas   --varchar2,
                ,from_name     => NULL     --varchar2,
                ,to_name       => NULL    --varchar2
                );
   ELSE
      x_po_primary_qty := p_po_qty;
   END IF;

--Compare the PO UOM and Reservation UOM and if different convert the PO quantity in the Reservation UOM.

   IF(l_po_uom <> l_res_meas) THEN
        --inv_convert.??
         /*po_uom_s.uom_convert(p_po_qty
                             ,l_po_uom
                             ,l_item_id
                             ,l_res_meas
                             ,x_res_qty);*/
      x_res_qty := inv_convert.inv_um_convert
              (
                item_id       => l_item_id    --number,
               ,precision     => NULL         --number,
               ,from_quantity => p_po_qty     --number,
               ,from_unit     => l_po_uom     --varchar2,
               ,to_unit       => l_res_meas   --varchar2,
               ,from_name     => NULL     --varchar2,
               ,to_name       => NULL    --varchar2
               );
   ELSE
        x_res_qty := p_po_qty;
   END IF;

   IF G_debug= C_Debug_Enabled THEN
        l_Fnd_Log_message := 'x_po_primary_qty :'|| x_po_primary_qty;
        mydebug(l_Fnd_Log_Message, c_api_name,9);
        l_Fnd_Log_message := 'x_res_qty :'|| x_res_qty;
   END IF;

   -- Call fnd_log api at the end of the API
   l_Fnd_Log_message := 'At the end of procedure :';
   -- Fnd_Log_Debug(Fnd_Log.Level_Procedure,C_Module_name, l_Fnd_Log_Message );

   IF G_debug= C_Debug_Enabled THEN
        mydebug(l_Fnd_Log_Message, c_api_name,9);
   END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF G_debug= C_Debug_Enabled THEN
              l_Fnd_Log_message := 'OTHERS exception happens in uom_conversion';
              mydebug(l_Fnd_Log_Message,c_api_name,9);
        END IF;
END UOM_CONVERSION;
--BUG#3497445



-- Procedure
--   MAINTAIN_RESERVATION
--
-- Description
--   API will handle changes to the resevation record based on the action code.
--
-- Input Paramters
--   p_api_version_number   API version number (current version is 1.0 Standard in parameter)
--   p_Init_Msg_lst         Flag to determine to initialize message stack for API, standard input parameter
--   p_header_id            Purchase order header id or requisition header id
--   p_line_id              Purchase order line id or requisition line id
--   p_line_location_id     Purchase order shipment id
--   p_distribution_id      Purchase order distribution_id
--   p_transaction_id       Receiving transaction id
--   p_ordered_quantity     Ordered quantity from order entry form
--   p_ordered_uom          Ordered uom from order entry form
--   p_action               different action codes for po approve/delete, requisition approve/delete
-- Output Parameters
--   x_Return_Status        Return Status of API, Standard out parameter
--   x_Msg_Count            Message count from the stack, standard out parameter
--   x_Msg_Data             Message from message stack, standard out parameter


PROCEDURE MAINTAIN_RESERVATION
(
  p_api_version_number        IN   NUMBER   DEFAULT 1.0
, p_init_msg_lst              IN   VARCHAR2 DEFAULT fnd_api.g_false
, p_header_id                 IN   NUMBER   DEFAULT NULL
, p_line_id                   IN   NUMBER   DEFAULT NULL
, p_line_location_id          IN   NUMBER   DEFAULT NULL
, p_distribution_id           IN   NUMBER   DEFAULT NULL
, p_transaction_id            IN   NUMBER   DEFAULT NULL
, p_ordered_quantity          IN   NUMBER   DEFAULT NULL
, p_ordered_uom               IN   VARCHAR2 DEFAULT NULL
, p_action                    IN   VARCHAR2
, x_return_status             OUT  NOCOPY   VARCHAR2
, x_msg_count                 OUT  NOCOPY   NUMBER
, x_msg_data                  OUT  NOCOPY   VARCHAR2
)

IS

  --get the records to be processed from the po_requiusitions_interface table (for create reservations)
  --this gets the records inserted into the interface table by req import
  --and creates a resevation on the req
  --
    /* Bug 5520620: Added UNION clause to handle the master tables along with interface data*/
    /* Bug 8524455. Get the unit of measure also. The quantity will be in
    unit of measure rather than uom code*/
   CURSOR get_interface_records IS
      SELECT requisition_header_id
           , requisition_line_id
           , interface_source_line_id
           , need_by_date
           , item_id
           , destination_organization_id
           , uom_code
           , quantity
           , project_id
           , task_id
           , source_type_code
           , unit_of_measure  -- Bug 8524455
      FROM   po_requisitions_interface
      WHERE  requisition_header_id = p_header_id
      AND    interface_source_code = 'CTO'
  UNION
   select  prl.requisition_header_id
        , prl.requisition_line_id
        , interface_source_line_id
        , need_by_date
        , item_id
        , destination_organization_id
        , uom_code
        , quantity
        , project_id
        , task_id
        , source_type_code
        , unit_of_measure  -- Bug 8524455
    from po_requisition_lines_all prl, po_requisition_headers_all prh , po_req_distributions_all prd, mtl_units_of_measure muom
   where prh.requisition_header_id = p_header_id
     and prh.REQUISITION_HEADER_ID = prl.REQUISITION_HEADER_ID
     and prd.requisition_line_id = prl.requisition_line_id
     and nvl(prl.modified_by_agent_flag,'N') <> 'Y'
     AND muom.unit_of_measure= unit_meas_lookup_code
     and not exists (select null
                  FROM po_requisitions_interface pri
                   where pri.requisition_header_id = prh.requisition_header_id
                   and   pri.interface_source_code = 'CTO');



  --get the sales order header for the sales order line
  --the interface table does not have the sales order header information
  --
  /* Bug 2693130: Changed the table name in the following cursor
     from 'oe_order_lines' to 'oe_order_lines_all'  */
 /* Bug 8524455, get the unit of measure and uom code also */
   CURSOR get_sales_order_line(v_demand_line_id IN NUMBER) IS
      SELECT  oel.header_id
            , oel.ordered_quantity
            , oel.order_quantity_uom
            , muom.unit_of_measure
        FROM  oe_order_lines_all oel
            , mtl_units_of_measure muom
       WHERE  oel.line_id = v_demand_line_id
         AND  cancelled_flag = 'N'
         AND  oel.order_quantity_uom = muom.uom_code;

  --
  --get quantity that is already reserved against INV
  --this is subtracted from the sales order quantity which
  --will then be the quantity that is to be reserved
  --

  CURSOR get_inv_res_qty(v_demand_header_id IN NUMBER,
                         v_demand_line_id   IN NUMBER) IS
      --SELECT sum(nvl(reservation_quantity,0))
      SELECT sum(nvl(primary_reservation_quantity,0)) sum_pri_res_qty, primary_uom_code
        FROM mtl_reservations
       WHERE demand_source_header_id = v_demand_header_id
         AND demand_source_line_id = v_demand_line_id
         AND demand_source_type_id in (inv_reservation_global.g_source_type_oe,
                                       inv_reservation_global.g_source_type_internal_ord)
       GROUP BY primary_uom_code;
   --    AND supply_source_type_id = inv_reservation_global.g_source_type_inv;
   -- comment out last restriction supply_source_type_id = inv_reservation_global.g_source_type_inv
   -- since starting from r12, we will start to open manual reservations for WIP job....


  /* Bug# 3085721, This Cursor will check if the reservation is already
  created for the Requisitions */

  CURSOR get_res_exists(v_requisition_header_id IN NUMBER,
                        v_requisition_line_id   IN NUMBER) IS
      SELECT 'Exists'
        FROM mtl_reservations
       WHERE supply_source_header_id = v_requisition_header_id
         AND supply_source_line_id = v_requisition_line_id
         AND Supply_source_type_id=inv_reservation_global.g_source_type_req;

  CURSOR get_po_shipment(v_po_header_id IN NUMBER) IS
      SELECT  pll.po_header_id
             ,pll.po_line_id
             ,pll.line_location_id
             ,pll.ship_to_organization_id
             ,pl.item_id
        FROM  po_line_locations_all pll
             ,po_lines_all  pl
       WHERE  pll.po_header_id = v_po_header_id
         AND  pl.po_line_id = pll.po_line_id;


  CURSOR get_req_line_of_po_shipment(v_po_shipment_id IN NUMBER) IS
      SELECT  b.requisition_line_id req_line_id
            , Nvl(b.project_id,-99) project_id
            , Nvl(b.task_id, -99) task_id
           -- , sum(a.quantity_ordered) quantity_ordered
        FROM  po_distributions_all a
            , po_req_distributions_all b
       WHERE  a.line_location_id = v_po_shipment_id
         AND  a.req_distribution_id = b.distribution_id
         AND  a.distribution_type <> 'AGREEMENT' --<Encumbrance FPJ>
    GROUP BY  b.requisition_line_id
            , b.project_id
            , b.task_id;

  CURSOR get_pt_count_po_shipment(v_po_shipment_id IN NUMBER) IS
      SELECT COUNT(min(po_distribution_id)) count
        FROM  po_distributions_all pd
       WHERE  pd.line_location_id = v_po_shipment_id
    GROUP BY project_id, task_id;

  CURSOR get_proj_task_of_po_shipment(v_po_shipment_id IN NUMBER) IS
        SELECT    Nvl(project_id, -99) project_id, Nvl(task_id, -99) task_id
          FROM    po_distributions_all
         WHERE    line_location_id = v_po_shipment_id
      GROUP BY    project_id,task_id;

  CURSOR get_po_res_qty(v_po_header_id        IN NUMBER
                       ,v_po_line_location_id IN NUMBER
                       ,v_project_id          IN NUMBER
                       ,v_task_id             IN NUMBER) IS
   SELECT  reservation_uom_code
         , primary_uom_code
         , sum(nvl(primary_reservation_quantity,0)) primary_reservation_quantity
     FROM  mtl_reservations
    WHERE  supply_source_header_id = v_po_header_id
      AND  supply_source_line_id = v_po_line_location_id
      AND  supply_source_type_id = inv_reservation_global.g_source_type_po
      AND  Nvl(project_id,-99) = nvl(v_project_id, -99)
      AND  Nvl(task_id,-99) = nvl(v_task_id, -99)
 GROUP BY  reservation_uom_code
         , primary_uom_code;


  CURSOR get_po_shipment_for_release(v_po_header_id IN NUMBER) IS
      SELECT  pll.po_header_id
            , pll.po_line_id
            , pll.line_location_id
            , pll.ship_to_organization_id    --?? is it correct org_id ??
            , pl.item_id
        FROM  po_line_locations_all  pll
             ,po_lines_all pl
       WHERE  pll.po_release_id = v_po_header_id
         AND  pll.po_line_id = pl.po_line_id;

 --
 -- get requisition lines for the req header
 -- to delete the reservation on the req (remove req supply)
 --
  CURSOR get_req_hdr_lines (v_po_req_header_id IN NUMBER) IS
      SELECT requisition_line_id, source_type_code
        FROM po_requisition_lines_all --<Shared Proc FPJ>
       WHERE requisition_header_id = v_po_req_header_id;

  --
  --get the PO header for the po line id that is cancelled
  --when po line is cancelled the reservations needs to be transferred back to the req or deleted
  --
  CURSOR get_po_header_id_line(v_po_line_id IN NUMBER) IS
     SELECT po_header_id
     FROM   po_lines_all --<Shared Proc FPJ>
   WHERE  po_line_id = v_po_line_id;


  --
  --get Distribution Records for the PO Line ID
  --when a PO line is cancelled the reservations needs to be transferred back to the req or deleted
  --

  --BUG#3497445.Added po_line_id in the cursor below.

  CURSOR get_line_loc_for_po_line (v_po_line_id IN NUMBER) IS
     SELECT pll.po_header_id
       , pll.po_line_id
       , pll.line_location_id
       , pll.ship_to_organization_id
       , pl.item_id
       , pll.quantity
       FROM po_line_locations_all pll, po_lines_all pl --<Shared Proc FPJ>
       WHERE pl.po_line_id = v_po_line_id
       AND pl.po_line_id = pll.po_line_id;

  --
  --get PO Header ID for the PO Line Location ID
  --to Check whether reservation exists for the PO
  --
  CURSOR get_po_header_id_shipment (v_po_line_location_id IN NUMBER)IS
      SELECT   po_header_id
        FROM   po_line_locations_all --<Shared Proc FPJ>
       WHERE   line_location_id = p_line_location_id;


  --
  --get Distribution Records for the PO Line Location ID
  --cancel shipment need to transfer reservation from PO to req or be deleted
  --

  --BUG#3497445.In cursor below the po_line_id was also fetched for fetching the quantity and UOM from the PO Lines.

  CURSOR get_line_loc_for_po_shipment (v_po_line_location_id IN NUMBER) IS
     SELECT  pll.po_header_id
       , pll.po_line_id
       , pll.line_location_id
       , pll.ship_to_organization_id
       , pl.item_id
       , pll.quantity
       FROM  po_line_locations_all pll, po_lines_all pl--<Shared Proc FPJ>
       WHERE  pll.line_location_id = v_po_line_location_id AND
       pl.po_line_id = pll.po_line_id;

  --
  --release ID will come as Header ID
  --get the po header id for the release
  --when a release is cancelled the reservations need to be transferred from the PO to the req or
  --deleted
  --
  CURSOR get_po_header_id_release (v_po_header_id IN NUMBER)IS
     SELECT   po_header_id
       FROM   po_releases_all --<Shared Proc FPJ>
       WHERE  po_release_id = v_po_header_id;
  --
  --get Distribution Records for the PO Release ID
  --

  --BUG#3497445.In cursor below the po_line_id was also fetched for fetching the quantity and UOM from the PO Lines.

  CURSOR get_distr_for_po_release (v_po_header_id IN NUMBER) IS
     SELECT  po_header_id
       , po_line_id
       , line_location_id
       , req_distribution_id
       , quantity_ordered
       FROM  po_distributions_all --<Shared Proc FPJ>
       WHERE  po_release_id = v_po_header_id;

  CURSOR get_source_doc_code (v_transaction_id IN NUMBER) IS
     SELECT source_document_code, organization_id FROM rcv_transactions
       WHERE transaction_id = v_transaction_id;

  CURSOR get_rcv_transaction (v_transaction_id IN NUMBER) IS
     SELECT  decode(a.source_document_code,'PO'
       , decode(b.asn_line_flag, 'Y', 'ASN', 'PO'), a.source_document_code)  supply_type
       , a.po_header_id, a.po_line_id
       , a.po_line_location_id
       , a.po_distribution_id
       , d.uom_code primary_unit_of_measure
       , a.primary_quantity
       , a.secondary_quantity
       , a.secondary_unit_of_measure
       , a.requisition_line_id
       , a.req_distribution_id
       , a.shipment_line_id
       , a.shipment_header_id
       , a.subinventory
       , a.locator_id
       , a.organization_id
       , a.lpn_id
       , b.item_revision
       , b.item_id
       , b.to_organization_id
       , c.project_id
       , c.task_id
       FROM  rcv_transactions a
       , rcv_shipment_lines b
       , po_distributions_all c
       , mtl_units_of_measure d
       WHERE  transaction_id = v_transaction_id
       AND  a.shipment_line_id = b.shipment_line_id
       AND  c.po_distribution_id = a.po_distribution_id
       AND  c.po_header_id = a.po_header_id
       AND  c.po_line_id = a.po_line_id
       AND  c.line_location_id = a.po_line_location_id
       AND d.unit_of_measure = a.primary_unit_of_measure;

  --Bug#3009495 Get the lot number for the delivered item
  CURSOR get_rcv_lot_number(v_shipment_line_id IN NUMBER) IS
     SELECT lot_num
          , primary_quantity
          , secondary_quantity
       FROM rcv_lot_transactions
      WHERE shipment_line_id = v_shipment_line_id;

  -- Bug 5611560
  CURSOR get_rcv_txn_lot_number(v_shipment_line_id IN NUMBER, v_transaction_id IN NUMBER) IS
     SELECT lot_num
          , primary_quantity
          , secondary_quantity
       FROM rcv_lot_transactions
      WHERE shipment_line_id = v_shipment_line_id
        AND transaction_id = v_transaction_id;

  CURSOR get_rcv_transaction_asn(v_transaction_id IN NUMBER) IS
     SELECT  a.po_header_id
       , a.po_line_id
       , a.po_line_location_id
       , a.po_distribution_id
       , d.uom_code primary_unit_of_measure
       , a.primary_quantity
       , a.shipment_line_id
       , a.subinventory
       , a.locator_id
       , a.organization_id
       , a.lpn_id
       , b.item_revision
       , b.item_id
       , b.to_organization_id
       , c.project_id
       , c.task_id
       FROM  rcv_transactions a
       , rcv_shipment_lines b
       , po_distributions_all c
       , mtl_units_of_measure d
       WHERE a.transaction_id = v_transaction_id
       AND a.source_document_code = 'PO'
       AND b.shipment_line_id = a.shipment_line_id
       AND b.asn_line_flag = 'Y'
       AND c.po_distribution_id = a.po_distribution_id
       AND c.po_header_id = a.po_header_id
       AND c.po_line_id = a.po_line_id
       AND c.line_location_id = a.po_line_location_id
       AND d.unit_of_measure = a.primary_unit_of_measure;


  CURSOR get_rcv_txn_int_req(v_transaction_id IN NUMBER) IS

     /* Fix for Bug#8673423. Added secondary_quantity and secondary unit of measure */

     SELECT  a.requisition_line_id
       , e.uom_code primary_unit_of_measure
       , a.primary_quantity
       , a.secondary_quantity
       , a.secondary_unit_of_measure
       , a.shipment_line_id
       , a.subinventory
       , a.locator_id
       , a.organization_id
       , a.lpn_id
       , b.item_revision
       , b.item_id
       , b.to_organization_id
       , c.project_id
       , c.task_id
       , d.requisition_header_id
       FROM  rcv_transactions a
       , rcv_shipment_lines b
       , po_req_distributions_all c
       , po_requisition_lines_all d
       , mtl_units_of_measure e
       WHERE a.transaction_id = v_transaction_id
       AND a.source_document_code = 'REQ'
       AND b.shipment_line_id = a.shipment_line_id
       AND c.distribution_id = a.req_distribution_id
       AND c.requisition_line_id = a.requisition_line_id
       AND d.requisition_line_id = c.requisition_line_id
       AND e.unit_of_measure = a.primary_unit_of_measure;


      --are we sure the req_distribution_id is populated in rcv_transactions ???

  -- Define Constants for API version and API name
  C_api_version_number CONSTANT NUMBER       := 1.0;
  C_api_name           CONSTANT VARCHAR2(30) := 'Maintain_Reservation';
  C_Module_Name  Constant Varchar2(2000) := 'inv.plsql.inv_maintain_reservation.Maintain_Reservation';
  C_Debug_Enabled      Constant Number := 1 ;

  --l_debug                      NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  l_Fnd_Log_Message            VARCHAR2(2000);

  l_return_status              VARCHAR2(1);
  l_reservation_quantity       NUMBER;
  l_demand_header_id           NUMBER;
  l_ordered_quantity           NUMBER;
  l_exist_inv_res_qty          NUMBER;
  l_temp_res_qty               NUMBER;
  l_lead_time                  NUMBER; -- Bug# 2984835.
  l_res_exists                 VARCHAR2(10); -- Bug# 3085721.

  l_rsv_rec                    inv_reservation_global.mtl_reservation_rec_type;
  l_rsv_array                  inv_reservation_global.mtl_reservation_tbl_type;

  l_record_count               NUMBER;
  l_qty_avail_to_reserve       NUMBER;
  l_qty_avail                  NUMBER;
  l_po_primary_qty             NUMBER;
  l_primary_res_quantity       NUMBER;
  l_po_header_id               NUMBER;
  l_record_index               NUMBER;
  l_primary_quantity           NUMBER;
  l_supply_source_type_id      NUMBER;
  l_source_type_code           VARCHAR2(25);

  --l_msg_count                  NUMBER;
  --l_msg_data                   VARCHAR2(2000);
  l_msg_index_out              NUMBER;
  l_org_id                     NUMBER;

  l_item_revision              VARCHAR2(3);
  l_revision_control_code      NUMBER;
  l_lot_control_code           NUMBER;

  l_quantity_modified          NUMBER;
  l_secondary_uom_code         VARCHAR2(3); /* Fix for Bug#8673423 */

  --interface_record                get_interface_records%ROWTYPE;
  sales_order_record                get_sales_order_line%ROWTYPE;
  get_inv_res_qty_rec               get_inv_res_qty%ROWTYPE;

  get_po_shipment_rec               get_po_shipment%ROWTYPE;
  get_req_line_po_shipment_rec      get_req_line_of_po_shipment%ROWTYPE;
  get_pt_count_po_shipment_rec      get_pt_count_po_shipment%ROWTYPE;
  get_pt_po_shipment_rec            get_proj_task_of_po_shipment%ROWTYPE;

  l_mtl_maint_rsv_rec               inv_reservation_global.mtl_maintain_rsv_rec_type;

  get_po_res_qty_rec                get_po_res_qty%ROWTYPE;
  get_po_shipment_rel_rec           get_po_shipment_for_release%ROWTYPE;
  get_req_hdr_lines_rec             get_req_hdr_lines%ROWTYPE;
 -- get_distr_rec                     get_distr_for_po_line%ROWTYPE;
  get_line_loc_rec                  get_line_loc_for_po_line%ROWTYPE;
  get_rcv_lot_number_rec            GET_RCV_LOT_NUMBER%ROWTYPE;

  get_rcv_transaction_rec           get_rcv_transaction%ROWTYPE;
  get_rcv_transaction_asn_rec       get_rcv_transaction_asn%ROWTYPE;
  get_rcv_txn_int_req_rec           get_rcv_txn_int_req%ROWTYPE;
  p_mtl_maintain_rsv_rec            inv_reservation_global.mtl_maintain_rsv_rec_type;
  get_source_doc_code_rec           get_source_doc_code%ROWTYPE;
  l_delete_flag VARCHAR2(1);
  l_sort_by_criteria Number;
  --l_transaction_id NUMBER;
  --Bug 5253916: For update so qty
  l_organization_id NUMBER;
  l_inventory_item_id NUMBER;
  l_primary_res_qty NUMBER;
  l_req_unit_meas VARCHAR2(25);
  l_req_qty NUMBER;
  l_temp_uom_res_qty           NUMBER;              -- Bug 8524455

    --Bug# 2984835.
    CURSOR get_lead_time (v_item_id IN NUMBER
                         ,v_org_id  IN NUMBER) IS
        SELECT  POSTPROCESSING_LEAD_TIME
          FROM  MTL_SYSTEM_ITEMS
         WHERE  INVENTORY_ITEM_ID = v_item_id
           AND  ORGANIZATION_ID = v_org_id;

BEGIN

   l_Fnd_Log_message := 'Begining of procedure :';

-- Log message in trace file
   IF g_debug= C_Debug_Enabled THEN
      g_Version_Printed := TRUE ;
      mydebug(l_Fnd_Log_Message,c_api_name,9);
      g_Version_Printed := FALSE ;
   END IF;

   -- Bug 3600118: Initialize return status variable
   l_return_status := FND_API.g_ret_sts_success;

   l_secondary_uom_code := null ; -- Fix for 8673423

   -- print out all the IN paramter values
   IF g_debug= C_Debug_Enabled THEN
     l_Fnd_Log_Message := 'p_header_id : '|| p_header_id ;
     mydebug(l_Fnd_Log_Message, c_api_name,9);
     l_Fnd_Log_Message := 'p_line_id : '|| p_line_id ;
     mydebug(l_Fnd_Log_Message, c_api_name,9);
     l_Fnd_Log_Message := 'p_line_location_id : '|| p_line_location_id ;
     mydebug(l_Fnd_Log_Message, c_api_name,9);
    -- l_Fnd_Log_Message := 'p_distribution_id : '|| p_distribution_id ;
     mydebug(l_Fnd_Log_Message, c_api_name,9);
     l_Fnd_Log_Message := 'p_transaction_id : '|| p_transaction_id ;
     mydebug(l_Fnd_Log_Message, c_api_name,9);
     l_Fnd_Log_Message := 'p_ordered_quantity : '|| p_ordered_quantity ;
     mydebug(l_Fnd_Log_Message, c_api_name,9);
     l_Fnd_Log_Message := 'p_ordered_uom : '|| p_ordered_uom ;
     mydebug(l_Fnd_Log_Message, c_api_name,9);
     l_Fnd_Log_Message := 'p_action : '|| p_action ;
     mydebug(l_Fnd_Log_Message, c_api_name,9);
   END IF;

   IF p_action IS NULL OR LTRIM(p_action) = '' THEN
      IF g_debug = C_Debug_Enabled THEN
        l_Fnd_Log_Message := 'Null action code';
        mydebug(l_Fnd_Log_Message, c_api_name,9);
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   IF upper(p_action) = 'APPROVE_REQ_SUPPLY' THEN
      --replace with FOR Loops
      --OPEN get_interface_records;
      --null;

      IF g_debug = C_Debug_Enabled THEN
        l_Fnd_Log_Message := 'Approve Req Supply ';
        mydebug(l_Fnd_Log_Message, c_api_name,9);
      END IF;

      FOR interface_record_rec IN get_interface_records LOOP

--       get the records after req import runs - to create reservation on the req

         --FETCH get_interface_records into interface_record;
         --EXIT WHEN get_interface_records%NOTFOUND;

         -- Bug 8742568, all further processing (create reservation) is required only if requisition
         --              is created corresponding to a sales order (back to back order). No need to
         --              do anything if interface_source_line_id is NULL
         IF interface_record_rec.interface_source_line_id IS NOT NULL THEN

            l_reservation_quantity   := interface_record_rec.quantity;

            OPEN get_sales_order_line(interface_record_rec.interface_source_line_id);

            IF g_debug= C_Debug_Enabled THEN
                    l_Fnd_Log_Message := 'interface_source_line_id: '||interface_record_rec.interface_source_line_id;
                    mydebug(l_Fnd_Log_Message, c_api_name,9);
            END IF;

            -- bug 8676222, no need to exit (no loop)
            FETCH get_sales_order_line INTO sales_order_record;
            --EXIT WHEN get_sales_order_line%NOTFOUND;
            --CLOSE get_sales_order_line;

            l_demand_header_id := oe_header_util.get_mtl_sales_order_id(sales_order_record.header_id);
            l_ordered_quantity := sales_order_record.ordered_quantity;

            IF g_debug= C_Debug_Enabled THEN
                    l_Fnd_Log_Message := 'l_ordered_quantity :'|| l_ordered_quantity;
                    mydebug(l_Fnd_Log_Message, c_api_name,9);
            END IF;
   --
            OPEN get_inv_res_qty(l_demand_header_id
                               , interface_record_rec.interface_source_line_id);
   --
            --FETCH get_inv_res_qty INTO l_exist_inv_res_qty;
            FETCH get_inv_res_qty INTO get_inv_res_qty_rec;
            --CLOSE get_inv_res_qty;
            IF g_debug= C_Debug_Enabled THEN
                l_Fnd_Log_Message := 'sales_order_record.order_quantity_uom: '||sales_order_record.order_quantity_uom;
                mydebug(l_Fnd_Log_Message, c_api_name,9);
                l_Fnd_Log_Message := 'l_ordered_quantity: '|| l_ordered_quantity;
                mydebug(l_Fnd_Log_Message, c_api_name,9);
            END IF;

            -- bug 8676222: if get_inv_res_qty%NOTFOUND, quantity and UOM are retained from previous record
            --              Added IF get_inv_res_qty%FOUND .. ELSE .. END IF
            if get_inv_res_qty%FOUND then

                IF g_debug= C_Debug_Enabled THEN
                        l_Fnd_Log_Message := 'get_inv_res_qty_rec.sum_pri_res_qty: '||get_inv_res_qty_rec.sum_pri_res_qty;
                        mydebug(l_Fnd_Log_Message, c_api_name,9);
                        l_Fnd_Log_Message := 'get_inv_res_qty_rec.primary_uom_code: '||get_inv_res_qty_rec.primary_uom_code;
                        mydebug(l_Fnd_Log_Message, c_api_name,9);
                END IF;

                IF  sales_order_record.order_quantity_uom = get_inv_res_qty_rec.primary_uom_code THEN
                     l_exist_inv_res_qty := get_inv_res_qty_rec.sum_pri_res_qty;
                ELSE
                     l_exist_inv_res_qty := inv_convert.inv_um_convert
                            (
                              item_id       => interface_record_rec.item_id    --number,
                             ,precision     => NULL         --number,
                             ,from_quantity => get_inv_res_qty_rec.sum_pri_res_qty     --number,
                             ,from_unit     => get_inv_res_qty_rec.primary_uom_code     --varchar2,
                             ,to_unit       => sales_order_record.order_quantity_uom   --varchar2,
                             ,from_name     => NULL     --varchar2,
                             ,to_name       => NULL    --varchar2
                            );
                END IF;
            else
               l_exist_inv_res_qty := 0;
            end if;
            if g_debug = c_debug_enabled then
               mydebug('l_exist_inv_res_qty:'|| l_exist_inv_res_qty, c_api_name,9);
            end if;

            CLOSE get_inv_res_qty;
            CLOSE get_sales_order_line;
   --
   --       calculate the actual quantity to be reserved;
   --
           -- SELECT nvl((l_ordered_quantity - nvl(l_exist_inv_res_qty,0)),l_ordered_quantity)
            --INTO l_temp_res_qty
            --FROM DUAL;

            l_temp_res_qty := nvl((l_ordered_quantity - nvl(l_exist_inv_res_qty,0)),l_ordered_quantity);

                 --
                 /* Bug 8524455
                  l_temp_res_qty is in Reservation uom, which is same as sales order UOM.
                  l_reservation_quantity is from req lines which is in req uom.
                  Need to convert l_reservation_quantity before comparison. */
                 IF interface_record_rec.unit_of_measure <> sales_order_record.unit_of_measure THEN
                    po_uom_s.uom_convert( l_reservation_quantity,
                                          interface_record_rec.unit_of_measure,
                                          interface_record_rec.item_id,
                                          sales_order_record.unit_of_measure,
                                          l_temp_uom_res_qty);

                    l_reservation_quantity := l_temp_uom_res_qty;

                 END IF;
                 /* End of Bug 8524455. Now the l_reservation_quantity is in Sales Order UOM */
                 --
            IF nvl(l_temp_res_qty,0) < nvl(l_reservation_quantity,0) THEN
               l_reservation_quantity := l_temp_res_qty;
            END IF;
   --

           /* Bug# 2984835,
              In maintain reservation we need to pass need_by_date+post-process-lead-time
              to the reservation routine. This is a part of the Bug fix done in
              Bug# 2931808 */

            IF g_debug= C_Debug_Enabled THEN
                  l_Fnd_Log_Message := 'l_reservation_quantity: '|| l_reservation_quantity;
                  mydebug(l_Fnd_Log_Message, c_api_name,9);
            END IF;

   --
            IF interface_record_rec.item_id is not NULL then
                 OPEN  get_lead_time (interface_record_rec.item_id
                                      ,interface_record_rec.destination_organization_id);
                 FETCH get_lead_time INTO l_lead_time;
                 CLOSE get_lead_time;
            END IF;
   --
            /* Bug# 3085721, If Encumbrance is ON the supply Code will be called twice.
               This creates 2 Resevations records. To avoid this we check if the
               reservation already exists we do not create reservation */


            OPEN get_res_exists(interface_record_rec.requisition_header_id,
                                interface_record_rec.requisition_line_id);
            FETCH get_res_exists INTO l_res_exists;
            IF g_debug= C_Debug_Enabled THEN
                    l_Fnd_Log_Message := 'progress 600 ';
                    mydebug(l_Fnd_Log_Message, c_api_name,9);
            END IF;
            IF get_res_exists%NOTFOUND THEN
               IF g_debug= C_Debug_Enabled THEN
                     l_Fnd_Log_Message := 'reservation is not existing ';
                     mydebug(l_Fnd_Log_Message, c_api_name,9);
               END IF;
               -- Get the source_type_code to determine the requistion type
               IF Upper(interface_record_rec.source_type_code) = 'INVENTORY' THEN
                  l_supply_source_type_id := inv_reservation_global.g_source_type_internal_req;
                else
                  l_supply_source_type_id := inv_reservation_global.g_source_type_req;
               END IF;

               /* Bug# 8524455, changed interface_record_rec.uom_code to
                  sales_order_record.order_quantity_uom below */
               CREATE_RES
                 ( p_inventory_item_id        => interface_record_rec.item_id
                   ,p_organization_id          => interface_record_rec.destination_organization_id
                   ,p_demand_source_header_id  => l_demand_header_id
                   ,p_demand_source_line_id    => interface_record_rec.interface_source_line_id
                   ,p_supply_source_type_id    => l_supply_source_type_id
                   ,p_supply_source_header_id  => p_header_id
                   ,p_supply_source_line_id    => interface_record_rec.requisition_line_id
                   ,p_requirement_date         => interface_record_rec.need_by_date + nvl(l_lead_time,0)
                   ,p_reservation_quantity     => l_reservation_quantity
                   ,p_reservation_uom_code     => sales_order_record.order_quantity_uom
                   ,p_project_id               => interface_record_rec.project_id
                   ,p_task_id                  => interface_record_rec.task_id
                   ,x_msg_count                => x_msg_count
                   ,x_msg_data                 => x_msg_data
                   ,x_return_status            => l_return_status);

                IF g_debug= C_Debug_Enabled THEN
                       l_Fnd_Log_Message := 'calling create_res :l_return_status: '|| l_return_status;
                       mydebug(l_Fnd_Log_Message, c_api_name,9);
                END IF;

                x_return_status := l_return_status;

                If x_return_status = fnd_api.g_ret_sts_success THEN
                   l_Fnd_Log_message := 'Calling CREATE_RES API was successful ';
                   -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );
                   IF G_debug= C_Debug_Enabled THEN
                      mydebug(l_Fnd_Log_Message, c_api_name,9);
                   END IF;
                else
                   l_Fnd_Log_message := 'Error while calling CREATE_RES API ';
                   -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );
                   IF G_debug= C_Debug_Enabled THEN
                      mydebug(l_Fnd_Log_Message, c_api_name,9);
                   END IF;
                end if;

            END IF;
            CLOSE get_res_exists;

         END IF;  --interface_record_rec.interface_source_line_id IS NOT NULL

      END LOOP;  -- get interface_records
      --CLOSE get_interface_records;

      IF g_debug= C_Debug_Enabled THEN
              l_Fnd_Log_Message := 'progress 800 ';
              mydebug(l_Fnd_Log_Message, c_api_name,9);
      END IF;

   ELSIF upper(p_action) = 'APPROVE_PO_SUPPLY' THEN
   --IF upper(p_action) = 'APPROVE_PO_SUPPLY' THEN
      IF g_debug= C_Debug_Enabled THEN
            l_Fnd_Log_Message := 'Inside of APPROVE_PO_SUPPLY ';
            mydebug(l_Fnd_Log_Message, c_api_name,9);
      END IF;

      IF NOT EXISTS_RESERVATION(p_supply_source_header_id        => p_header_id) THEN
         -- normal path taken when a PO is approved and there is no reservation on the PO
         --

         IF g_debug= C_Debug_Enabled THEN
            l_Fnd_Log_Message := 'Inside no reservations. p_header_id: '||p_header_id;
            mydebug(l_Fnd_Log_Message, c_api_name,9);
            l_Fnd_Log_Message := 'No reservation existing for PO, normal path taken when a PO is approved ';
            mydebug(l_Fnd_Log_Message, c_api_name,9);
         END IF;

         OPEN get_po_shipment(p_header_id);
         LOOP
            FETCH get_po_shipment INTO get_po_shipment_rec;
            EXIT WHEN get_po_shipment%NOTFOUND;

            IF g_debug= C_Debug_Enabled THEN
               l_Fnd_Log_Message := 'get_po_shipment_rec.line_location_id: '||get_po_shipment_rec.line_location_id;
               mydebug(l_Fnd_Log_Message, c_api_name,9);
            END IF;

            OPEN get_req_line_of_po_shipment(get_po_shipment_rec.line_location_id);
            LOOP
               FETCH get_req_line_of_po_shipment INTO get_req_line_po_shipment_rec;
               EXIT WHEN get_req_line_of_po_shipment%NOTFOUND;

               IF g_debug= C_Debug_Enabled THEN
                  l_Fnd_Log_Message := 'Before get_req_line_po_shipment_rec.project_id: '||get_req_line_po_shipment_rec.project_id;
                  mydebug(l_Fnd_Log_Message, c_api_name,9);
                  l_Fnd_Log_Message := 'before get_req_line_po_shipment_rec.task_id: '||get_req_line_po_shipment_rec.task_id;
                  mydebug(l_Fnd_Log_Message, c_api_name,9);
               END IF;

               IF (get_req_line_po_shipment_rec.project_id = -99) THEN
                  get_req_line_po_shipment_rec.project_id := NULL;
               END IF;
               IF (get_req_line_po_shipment_rec.task_id = -99) THEN
                  get_req_line_po_shipment_rec.task_id := NULL;
               END IF;

               IF g_debug= C_Debug_Enabled THEN
                  l_Fnd_Log_Message := 'after get_req_line_po_shipment_rec.project_id: '||get_req_line_po_shipment_rec.project_id;
                  mydebug(l_Fnd_Log_Message, c_api_name,9);
                  l_Fnd_Log_Message := 'after get_req_line_po_shipment_rec.task_id: '||get_req_line_po_shipment_rec.task_id;
                  mydebug(l_Fnd_Log_Message, c_api_name,9);
               END IF;
               --IF   (get_req_line_po_shipment_rec.project_id IS NOT NULL
               -- OR
               --  get_req_line_po_shipment_rec.task_id IS NOT NULL) THEN

               INV_RESERVATION_AVAIL_PVT.available_supply_to_reserve
                 (
                  x_return_status            =>l_return_status    --OUT  NOCOPY VARCHAR2
                  , x_msg_count                =>x_msg_count     --OUT     NOCOPY NUMBER
                  , x_msg_data                 =>x_msg_data     --OUT     NOCOPY VARCHAR2
                  , p_organization_id          =>get_po_shipment_rec.ship_to_organization_id--IN  NUMBER default null
                  , p_item_id                  =>get_po_shipment_rec.item_id --IN  NUMBER default null
                  , p_supply_source_type_id    =>inv_reservation_global.g_source_type_po --IN NUMBER
                  , p_supply_source_header_id  =>p_header_id --IN NUMBER
                  , p_supply_source_line_id    =>get_po_shipment_rec.line_location_id --IN NUMBER
                  , p_project_id               =>get_req_line_po_shipment_rec.project_id--IN NUMBER default null
                  , p_task_id                  =>get_req_line_po_shipment_rec.task_id --IN NUMBER default null
                  , x_qty_available_to_reserve =>l_qty_avail_to_reserve --OUT      NOCOPY NUMBER
                  , x_qty_available            =>l_qty_avail  --OUT      NOCOPY NUMBER
                 );

               IF g_debug= C_Debug_Enabled THEN
                  l_Fnd_Log_Message := 'l_qty_avail_to_reserve: '|| l_qty_avail_to_reserve;
                  mydebug(l_Fnd_Log_Message, c_api_name,9);
                  l_Fnd_Log_Message := 'l_qty_avail: '|| l_qty_avail;
                  mydebug(l_Fnd_Log_Message, c_api_name,9);
               END IF;

               -- check to see if reservation exist on the req line
               -- Under normal circumstances, there will be a reservation on a req-line
                     --
               get_req_line_res
                 (p_req_line_id  =>get_req_line_po_shipment_rec.req_line_id,
                  p_project_id   =>get_req_line_po_shipment_rec.project_id,
                  p_task_id      =>get_req_line_po_shipment_rec.task_id,
                  x_res_array    =>l_rsv_array,
                  x_record_count =>l_record_count);

               IF g_debug= C_Debug_Enabled THEN
                  l_Fnd_Log_Message := 'l_record_count: '|| l_record_count;
                  mydebug(l_Fnd_Log_Message, c_api_name,9);
               END IF;

               IF l_record_count > 0 THEN
                  -- we should not compare a req_line reservation_qty with po_shipment_order_qty
                  -- since po shipment can comparise of multi req_line....
                  -- also there is no manual reservation against external req.,
                  -- so available_to_reserve qty should be the same as ordered_qty
                  -- plus there is no reservation for this PO
                  -- this is first time for PO approve.  before PO approve, we can not
                  -- create manual reservation against non-approved PO
                  -- only when PO approved, system created reservation plus manual reservation
                  -- can be created against this approved PO.
                  l_rsv_rec := l_rsv_array(1);
                  -- since l_qty_avail_to_reserve is already in primary_uom, there is
                  -- no need to convert.
                  /*uom_conversion(l_rsv_rec.reservation_uom_code
                  ,l_rsv_rec.primary_uom_code
                    ,l_qty_avail_to_reserve
                    ,get_po_shipment_rec.po_line_id
                    ,l_reservation_quantity
                    ,l_po_primary_qty); */

                    if (l_rsv_rec.primary_reservation_quantity > l_qty_avail_to_reserve)  THEN
                       IF g_debug= C_Debug_Enabled THEN
                          l_Fnd_Log_Message := 'calling update_res API ';
                          mydebug(l_Fnd_Log_Message, c_api_name,9);
                       END IF;

                       update_res
                         (p_supply_source_header_id      => l_rsv_rec.supply_source_header_id
                          ,p_supply_source_line_id        => l_rsv_rec.supply_source_line_id
                          ,p_supply_source_type_id        => inv_reservation_global.g_source_type_req
                          ,p_primary_reservation_quantity => l_qty_avail_to_reserve
                          ,p_project_id                   => get_req_line_po_shipment_rec.project_id
                          ,p_task_id                      => get_req_line_po_shipment_rec.task_id
                          ,p_reservation_id               => l_rsv_rec.reservation_id
                          ,x_msg_count                    => x_msg_count
                          ,x_msg_data                     => x_msg_data
                          ,x_return_status                => l_return_status);
                    end if;


                    --BUG#3497445.The l_po_primary_qty calculated from the UOM_conversion call is used below.

                    l_primary_res_quantity  := least(l_rsv_rec.primary_reservation_quantity,
                                                     l_qty_avail_to_reserve);
                    IF g_debug= C_Debug_Enabled THEN
                       l_Fnd_Log_Message := 'l_primary_res_quantity: '|| l_primary_res_quantity;
                       mydebug(l_Fnd_Log_Message, c_api_name,9);
                    END IF;

                    IF g_debug= C_Debug_Enabled THEN
                       l_Fnd_Log_Message := 'calling transfer reservation for, From req line id: '||
                           l_rsv_rec.supply_source_line_id || ' to po shipment line id: ' || get_po_shipment_rec.line_location_id;
                       mydebug(l_Fnd_Log_Message, c_api_name,9);
                    END IF;

                    -- calling transfer_res with project_id, task_id
                    TRANSFER_RES
                      (p_from_reservation_id       =>l_rsv_rec.reservation_id
                       ,p_from_source_header_id    =>l_rsv_rec.supply_source_header_id
                       ,p_from_source_line_id      =>l_rsv_rec.supply_source_line_id
                       ,p_supply_source_type_id    =>inv_reservation_global.g_source_type_req
                       ,p_to_source_header_id      =>p_header_id
                       ,p_to_source_line_id        =>get_po_shipment_rec.line_location_id
                       ,p_to_supply_source_type_id =>inv_reservation_global.g_source_type_po
                       ,p_primary_uom_code         =>l_rsv_rec.primary_uom_code
                       ,p_primary_res_quantity     =>l_primary_res_quantity
                       ,x_msg_count                => x_msg_count
                       ,x_msg_data                 => x_msg_data
                       ,x_return_status            =>l_return_status);

                    IF g_debug= C_Debug_Enabled THEN
                       l_Fnd_Log_Message := 'after calling transfer_res. The l_return_status : '|| l_return_status;
                       mydebug(l_Fnd_Log_Message, c_api_name,9);
                    END IF;

                ELSE -- if did not have any req reservation existing
                  FND_MESSAGE.SET_NAME('INV','INV_API_NO_RSV_EXIST');
                  FND_MSG_PUB.Add;
                  l_Fnd_Log_Message := 'calling get_req_line_res, no reservation records';
                  mydebug(l_Fnd_Log_Message, c_api_name,9);
               END IF; -- record_count

            END LOOP;
            CLOSE get_req_line_of_po_shipment;

         END LOOP;
         CLOSE get_po_shipment;

       ELSE
          -- reservation exists, means that
          -- new req lines were added to an already approved PO
          -- and therefore reservations need to be transferred from req-line to PO
          IF g_debug= C_Debug_Enabled THEN
             l_Fnd_Log_Message := 'reservation existing for PO  ';
             mydebug(l_Fnd_Log_Message, c_api_name,9);
          END IF;
          OPEN get_po_shipment(p_header_id);
          LOOP
             FETCH get_po_shipment INTO get_po_shipment_rec;
             EXIT WHEN get_po_shipment%NOTFOUND;

             IF g_debug= C_Debug_Enabled THEN
                l_Fnd_Log_Message := 'get_po_shipment_rec.line_location_id: '||get_po_shipment_rec.line_location_id;
                mydebug(l_Fnd_Log_Message, c_api_name,9);
             END IF;
             OPEN get_req_line_of_po_shipment(get_po_shipment_rec.line_location_id);
             LOOP
                FETCH get_req_line_of_po_shipment INTO get_req_line_po_shipment_rec;
                EXIT WHEN get_req_line_of_po_shipment%NOTFOUND;

                IF g_debug= C_Debug_Enabled THEN
                   l_Fnd_Log_Message := 'before calling get_req_line_res... ';
                   mydebug(l_Fnd_Log_Message, c_api_name,9);
                END IF;
                get_req_line_res(p_req_line_id   =>get_req_line_po_shipment_rec.req_line_id,
                                 p_project_id    =>get_req_line_po_shipment_rec.project_id,
                                 p_task_id       =>get_req_line_po_shipment_rec.task_id,
                                 x_res_array     =>l_rsv_array,
                                 x_record_count  =>l_record_count);

                IF g_debug= C_Debug_Enabled THEN
                   l_Fnd_Log_Message := 'after calling get_req_line_res,l_record_count: '|| l_record_count;
                   mydebug(l_Fnd_Log_Message, c_api_name,9);
                END IF;

                IF l_record_count > 0 THEN
                   l_rsv_rec := l_rsv_array(1);

                   IF g_debug= C_Debug_Enabled THEN
                      l_Fnd_Log_Message := 'calling transfer_res with following IN values:';
                      mydebug(l_Fnd_Log_Message, c_api_name,9);
                   END IF;
                   TRANSFER_RES
                     (p_from_reservation_id       =>l_rsv_rec.reservation_id
                      ,p_from_source_header_id     =>l_rsv_rec.supply_source_header_id
                      ,p_from_source_line_id       =>l_rsv_rec.supply_source_line_id
                      ,p_supply_source_type_id     =>inv_reservation_global.g_source_type_req
                      ,p_to_source_header_id       =>p_header_id
                      ,p_to_source_line_id         =>get_po_shipment_rec.line_location_id
                      ,p_to_supply_source_type_id  =>inv_reservation_global.g_source_type_po
                      ,p_primary_uom_code          =>l_rsv_rec.primary_uom_code
                      ,p_primary_res_quantity      =>l_rsv_rec.primary_reservation_quantity
                      ,x_msg_count                 =>x_msg_count
                      ,x_msg_data                  =>x_msg_data
                      ,x_return_status             =>l_return_status);
                   IF g_debug= C_Debug_Enabled THEN
                      l_Fnd_Log_Message := 'after calling transfer_res. The l_return_status : '|| l_return_status;
                      mydebug(l_Fnd_Log_Message, c_api_name,9);
                   END IF;
                 ELSE
                   FND_MESSAGE.SET_NAME('INV','INV_API_NO_RSV_EXIST');
                   FND_MSG_PUB.Add;
                   l_Fnd_Log_Message := 'calling get_req_line_res, no reservation records';
                   mydebug(l_Fnd_Log_Message, c_api_name,9);
                END IF;

             END LOOP;
             CLOSE get_req_line_of_po_shipment;

             OPEN  get_pt_count_po_shipment(get_po_shipment_rec.line_location_id);
             FETCH get_pt_count_po_shipment into get_pt_count_po_shipment_rec;
             CLOSE get_pt_count_po_shipment;

             IF g_debug= C_Debug_Enabled THEN
                l_Fnd_Log_Message := ' get_pt_count_po_shipment_rec.count : '||get_pt_count_po_shipment_rec.count;
                mydebug(l_Fnd_Log_Message, c_api_name,9);
             END IF;

             IF get_pt_count_po_shipment_rec.count > 1 THEN   -- multiple project/task

                IF g_debug= C_Debug_Enabled THEN
                   l_Fnd_Log_Message := 'Multiple project/task...  ';
                   l_Fnd_Log_Message := 'get_po_shipment_rec.org_id:'||get_po_shipment_rec.ship_to_organization_id;
                   mydebug(l_Fnd_Log_Message, c_api_name,9);
                END IF;

                IF (inv_install.adv_inv_installed(get_po_shipment_rec.ship_to_organization_id))  THEN
                   -- is wms org
                   -- delete all the reservations for this shipment
                   -- log message
                   IF g_debug= C_Debug_Enabled THEN
                      l_Fnd_Log_Message := 'Organization is wms org. calling delete_res API with IN parameters';
                      mydebug(l_Fnd_Log_Message, c_api_name,9);
                   END IF;
                   -- Call reduce reservations instead of delete
                   -- reservations
                   -- Call the reduce reservations API by setting the
                   -- delete_flag to yes. delete all reservations for that
                   -- supply line.
                   -- calling reduce_reservation API
                   l_delete_flag := 'Y';
                   l_sort_by_criteria := inv_reservation_global.g_query_demand_ship_date_desc;
                   l_mtl_maint_rsv_rec.action := 0;--supply is reduced
                   l_mtl_maint_rsv_rec.organization_id := get_po_shipment_rec.ship_to_organization_id;
                   l_mtl_maint_rsv_rec.inventory_item_id := get_po_shipment_rec.item_id;
                   l_mtl_maint_rsv_rec.supply_source_type_id:= inv_reservation_global.g_source_type_po;
                   l_mtl_maint_rsv_rec.supply_source_header_id := p_header_id;
                   l_mtl_maint_rsv_rec.supply_source_line_id := get_po_shipment_rec.line_location_id;
                   --l_mtl_maint_rsv_rec.supply_source_line_detail := NULL;

                   reduce_reservation
                     (
                       p_api_version_number     => 1.0
                       , p_init_msg_lst           => fnd_api.g_false
                       , x_return_status          => l_return_status
                       , x_msg_count              => x_msg_count
                       , x_msg_data               => x_msg_data
                       , p_mtl_maintain_rsv_rec   => l_mtl_maint_rsv_rec
                       , p_delete_flag            => l_delete_flag
                       , p_sort_by_criteria       => l_sort_by_criteria
                       , x_quantity_modified      => l_quantity_modified);
                   IF g_debug= C_Debug_Enabled THEN
                      mydebug ('Return Status after calling reduce reservations: '|| l_return_status, c_api_name,9);
                   END IF;

                   IF l_return_status = fnd_api.g_ret_sts_error THEN

                      IF g_debug= C_Debug_Enabled THEN
                         mydebug('Raising expected error'|| l_return_status, c_api_name,9);
                      END IF;
                      RAISE fnd_api.g_exc_error;

                    ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN

                      IF g_debug= C_Debug_Enabled THEN
                         mydebug('Rasing Unexpected error'|| l_return_status, c_api_name,9);
                      END IF;
                      RAISE fnd_api.g_exc_unexpected_error;

                   END IF;
                   /***** Call reduce reservations instead of delete reservations
                   DELETE_RES
                     (p_supply_source_header_id => p_header_id
                      ,p_supply_source_line_id   => get_po_shipment_rec.line_location_id
                      ,p_supply_source_type_id   => inv_reservation_global.g_source_type_po
                      ,x_msg_count               => x_msg_count
                      ,x_msg_data                => x_msg_data
                      ,x_return_status           => l_return_status);
                   IF g_debug= C_Debug_Enabled THEN
                      l_Fnd_Log_Message := 'l_return_status: '|| l_return_status;
                     END IF;
                     End comment*******/
                END IF;
             END IF;

             IF g_debug= C_Debug_Enabled THEN
                   mydebug('Line location id' || get_po_shipment_rec.line_location_id, c_api_name,9);
                END IF;
             OPEN get_proj_task_of_po_shipment(get_po_shipment_rec.line_location_id);
             LOOP
                FETCH  get_proj_task_of_po_shipment INTO
                  get_pt_po_shipment_rec;
                EXIT WHEN get_proj_task_of_po_shipment%NOTFOUND;

                IF g_debug= C_Debug_Enabled THEN
                   mydebug('Inside project/task loop', c_api_name,9);
                END IF;
                IF g_debug= C_Debug_Enabled THEN
                   mydebug('Project Id: '|| get_pt_po_shipment_rec.project_id, c_api_name,9);
                   mydebug('Task Id: '|| get_pt_po_shipment_rec.task_id, c_api_name,9);
                END IF;


                IF (get_pt_po_shipment_rec.project_id = -99) THEN
                   get_pt_po_shipment_rec.project_id := NULL;
                END IF;
                IF (get_pt_po_shipment_rec.task_id = -99) THEN
                   get_pt_po_shipment_rec.task_id := NULL;
                END IF;
                INV_RESERVATION_AVAIL_PVT.available_supply_to_reserve
                  (
                   x_return_status                  => l_return_status
                   , x_msg_count                      => x_msg_count
                   , x_msg_data                       => x_msg_data
                   , p_organization_id                => get_po_shipment_rec.ship_to_organization_id
                   , p_item_id                        => get_po_shipment_rec.item_id
                   , p_supply_source_type_id          => inv_reservation_global.g_source_type_po
                   , p_supply_source_header_id        => p_header_id
                   , p_supply_source_line_id          => get_po_shipment_rec.line_location_id
                   , p_project_id                     => get_pt_po_shipment_rec.project_id
                   , p_task_id                        => get_pt_po_shipment_rec.task_id
                   , x_qty_available_to_reserve       => l_qty_avail_to_reserve
                   , x_qty_available                  => l_qty_avail
                   );


                OPEN  get_po_res_qty
                  (p_header_id
                   ,get_po_shipment_rec.line_location_id
                   ,get_pt_po_shipment_rec.project_id
                   ,get_pt_po_shipment_rec.task_id);
                FETCH get_po_res_qty INTO get_po_res_qty_rec ;
                CLOSE get_po_res_qty ;

                IF g_debug= C_Debug_Enabled THEN
                   mydebug('Qty available: '|| l_qty_avail, c_api_name,9);
                   mydebug('Qty available to reserve: '|| l_qty_avail_to_reserve, c_api_name,9);
                   mydebug('Qty reserved qty: '|| get_po_res_qty_rec.primary_reservation_quantity, c_api_name,9);
                END IF;
                IF  get_po_res_qty_rec.primary_reservation_quantity > 0 THEN
                   -- since l_qty_avail_to_reserve is already in primary uom,
                   -- there is no need to convert it again
                   -- comment out the following uom convertion
                   /*uom_conversion(get_po_res_qty_rec.reservation_uom_code
                   ,get_po_res_qty_rec.primary_uom_code
                     ,l_qty_avail_to_reserve
                     ,get_po_shipment_rec.po_line_id
                     ,l_reservation_quantity
                     ,l_po_primary_qty);*/

                     IF (get_po_res_qty_rec.primary_reservation_quantity > l_qty_avail)  THEN
                        -- calling reduce_reservation API
                        l_mtl_maint_rsv_rec.action := 0;--supply is reduced
                        l_sort_by_criteria := inv_reservation_global.g_query_demand_ship_date_desc;
                        l_mtl_maint_rsv_rec.organization_id := get_po_shipment_rec.ship_to_organization_id;
                        l_mtl_maint_rsv_rec.inventory_item_id := get_po_shipment_rec.item_id;
                        l_mtl_maint_rsv_rec.supply_source_type_id:= inv_reservation_global.g_source_type_po;
                        l_mtl_maint_rsv_rec.supply_source_header_id := p_header_id;
                        l_mtl_maint_rsv_rec.supply_source_line_id := get_po_shipment_rec.line_location_id;
                --        l_mtl_maint_rsv_rec.supply_source_line_detail := NULL;
                        --l_mtl_maint_rsv_rec.expected_quantity := get_po_res_qty_rec.primary_reservation_quantity - l_qty_avail_to_reserve;
                        l_mtl_maint_rsv_rec.expected_quantity := l_qty_avail;
                        l_mtl_maint_rsv_rec.expected_quantity_uom := get_po_res_qty_rec.primary_uom_code;
                        l_mtl_maint_rsv_rec.project_id := get_pt_po_shipment_rec.project_id;
                        l_mtl_maint_rsv_rec.task_id := get_pt_po_shipment_rec.task_id;

                        reduce_reservation
                          (
                            p_api_version_number     => 1.0
                            , p_init_msg_lst           => fnd_api.g_false
                            , x_return_status          => l_return_status
                            , x_msg_count              => x_msg_count
                            , x_msg_data               => x_msg_data
                            , p_mtl_maintain_rsv_rec   => l_mtl_maint_rsv_rec
                            , p_delete_flag            => 'N'
                            , p_sort_by_criteria       => l_sort_by_criteria
                            , x_quantity_modified      => l_quantity_modified);

                        IF g_debug= C_Debug_Enabled THEN
                           mydebug ('Return Status after calling reduce reservations: '|| l_return_status, c_api_name,9);
                        END IF;

                        IF l_return_status = fnd_api.g_ret_sts_error THEN

                           IF g_debug= C_Debug_Enabled THEN
                              mydebug('Raising expected error'|| l_return_status, c_api_name,9);
                           END IF;
                           RAISE fnd_api.g_exc_error;

                         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN

                           IF g_debug= C_Debug_Enabled THEN
                              mydebug('Rasing Unexpected error'|| l_return_status, c_api_name,9);
                           END IF;
                           RAISE fnd_api.g_exc_unexpected_error;

                        END IF;

                     END IF;
                END IF;  -- > 0

             END LOOP;
             CLOSE  get_proj_task_of_po_shipment;

          END LOOP;
          CLOSE get_po_shipment;
      END IF;  -- if not_exist()
    ELSIF upper(p_action) = 'DELIVER_TO_INVENTORY' THEN
      IF g_debug= C_Debug_Enabled THEN
           l_Fnd_Log_Message := 'Deliver To Inventory. p_transaction_id : '||p_transaction_id;
           mydebug(l_Fnd_Log_Message, c_api_name,9);
      END IF;

        -- IF p_transaction_id IS NULL THEN
              -- l_transaction_id := p_header_id;
        --  ELSE
              -- l_transaction_id := p_transaction_id;
        -- END IF;

      IF (p_transaction_id IS NULL) THEN
         FND_MESSAGE.SET_NAME('INV','INV_INVALID_TRANSACTION_ID');
         FND_MSG_PUB.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;

      OPEN get_source_doc_code(p_transaction_id);
      FETCH get_source_doc_code INTO get_source_doc_code_rec;

      --IF g_debug= C_Debug_Enabled THEN
      --         l_Fnd_Log_Message := 'p_transaction_id : '|| l_transaction_id;
      --         mydebug(l_Fnd_Log_Message, c_api_name,9);
      -- END IF;

      IF g_debug= C_Debug_Enabled THEN
         l_Fnd_Log_Message := 'get_source_doc_code_rec.organization_id : '||get_source_doc_code_rec.organization_id;
         mydebug(l_Fnd_Log_Message, c_api_name,9);
      END IF;

      IF (get_source_doc_code_rec.organization_id IS NULL) THEN
         IF g_debug= C_Debug_Enabled THEN
            mydebug('Could not find the organization for the transaction id:' || p_transaction_id, c_api_name,9);
         END IF;
         RAISE fnd_api.g_exc_error;
      END IF;

      IF (inv_install.adv_inv_installed(get_source_doc_code_rec.organization_id)) THEN
           -- wms org
           -- return
           IF g_debug= C_Debug_Enabled THEN
                l_Fnd_Log_Message := 'it is WMS organization, return.';
                mydebug(l_Fnd_Log_Message, c_api_name,9);
           END IF;

           IF get_source_doc_code%isopen THEN
              CLOSE get_source_doc_code;
           END if;

           RETURN;
       ELSE

         IF g_debug= C_Debug_Enabled THEN
            l_Fnd_Log_Message := 'it is Inventory organization';
            mydebug(l_Fnd_Log_Message, c_api_name,9);
            l_Fnd_Log_Message := 'get_source_doc_code_rec.source_document_code :'|| get_source_doc_code_rec.source_document_code;
            mydebug(l_Fnd_Log_Message, c_api_name,9);
         END IF;

         IF (get_source_doc_code_rec.source_document_code = 'PO') THEN
            OPEN  get_rcv_transaction(p_transaction_id);
            FETCH get_rcv_transaction into get_rcv_transaction_rec;
            --CLOSE get_rcv_transaction;

            IF get_rcv_transaction_rec.supply_type = 'PO' THEN

              IF g_debug= C_Debug_Enabled THEN
                   l_Fnd_Log_Message := 'DTI. supply_type is PO';
                   mydebug(l_Fnd_Log_Message, c_api_name,9);
              END IF;
              IF get_rcv_transaction%FOUND THEN

                    IF g_debug= C_Debug_Enabled THEN
                          l_Fnd_Log_Message := 'get_rcv_transaction_rec.item_revision: '||get_rcv_transaction_rec.item_revision;
                          mydebug(l_Fnd_Log_Message, c_api_name,9);
                    END IF;
                    IF get_rcv_transaction_rec.item_revision is NULL then
                       IF g_debug= C_Debug_Enabled THEN
                             l_Fnd_Log_Message := 'get_rcv_transaction_rec.item_revision is NULL ';
                             mydebug(l_Fnd_Log_Message, c_api_name,9);
                       END IF;

                       BEGIN
                           SELECT    max(mir.revision)
                             INTO    l_item_revision
                             FROM    mtl_system_items msi
                                   , mtl_item_revisions mir
                            WHERE    msi.inventory_item_id = get_rcv_transaction_rec.item_id
                              AND    msi.organization_id = get_rcv_transaction_rec.organization_id
                              AND    msi.revision_qty_control_code = 2
                              AND    mir.organization_id = msi.organization_id
                              AND    msi.inventory_item_id = msi.inventory_item_id
                              AND    mir.effectivity_date in
                                      (SELECT   MAX(mir2.effectivity_date)
                                         FROM   mtl_item_revisions mir2
                                        WHERE   mir2.organization_id = get_rcv_transaction_rec.organization_id
                                          AND   mir2.inventory_item_id = get_rcv_transaction_rec.item_id
                                          AND   mir2.effectivity_date <= SYSDATE
                                          AND   mir2.implementation_date is not NULL);


                           get_rcv_transaction_rec.item_revision := l_item_revision;

                       EXCEPTION
                          when others then
                             l_item_revision := NULL;
                             get_rcv_transaction_rec.item_revision := NULL;
                       END;

                       IF g_debug= C_Debug_Enabled THEN
                              l_Fnd_Log_Message := 'l_item_revision :'|| l_item_revision;
                              mydebug(l_Fnd_Log_Message, c_api_name,9);
                       END IF;

                    ELSE
                      /* Begin Bug 3688014 : If the rcv_shipment_lines contains a item revision
                      for a non-revision controlled item, we should pass a NULL
                      item revision to inventory so that supply gets updated accordingly.
                      */

                      IF g_debug= C_Debug_Enabled THEN
                           l_Fnd_Log_Message := 'get_rcv_transaction_rec.item_revision is NOT NULL ';
                           mydebug(l_Fnd_Log_Message, c_api_name,9);
                      END IF;

                      BEGIN

                          SELECT msi.revision_qty_control_code
                            INTO l_revision_control_code
                            FROM mtl_system_items_b msi
                           WHERE msi.inventory_item_id = get_rcv_transaction_rec.item_id
                             AND msi.organization_id = get_rcv_transaction_rec.organization_id;

                          IF  l_revision_control_code = 1 THEN
                               get_rcv_transaction_rec.item_revision := NULL;
                          END IF;

                      EXCEPTION
                          WHEN others THEN
                              get_rcv_transaction_rec.item_revision := NULL;
                      END;

                      IF g_debug= C_Debug_Enabled THEN
                             l_Fnd_Log_Message := 'l_revision_control_code : '|| l_revision_control_code;
                             mydebug(l_Fnd_Log_Message, c_api_name,9);
                      END IF;

                      /* End Bug 3688014 */

                    END IF;  --get_rcv_transaction_rec.item_revision is NULL

                    --Bug#3009495.If item is lot controlled then we will derive the lot number
                    --from the rcv_lot_transactions.
                    get_rcv_lot_number_rec.lot_num := NULL;
                    --IF get_shipment_lines%FOUND THEN

                    --Bug 7559682 Error performing deliver transaction for Direct Items in EAM workorder
                    --having destination type as shop floor. Modified the code block to include MSI query
                    BEGIN
                        select nvl(lot_control_code,1)
                          into   l_lot_control_code
                          from   mtl_system_items
                         where  organization_id = get_rcv_transaction_rec.to_organization_id
                           and  inventory_item_id = get_rcv_transaction_rec.item_id ;

                        IF (l_lot_control_code = 2) THEN
                           --Begin         --commented for bug 7559682
                              -- 5611560 New cursor is opened and fetcched.
                              OPEN  get_rcv_txn_lot_number(get_rcv_transaction_rec.shipment_line_id,p_transaction_id);
                              FETCH get_rcv_txn_lot_number INTO get_rcv_lot_number_rec;
                        END IF;

                    EXCEPTION
                      WHEN OTHERS THEN
                        get_rcv_lot_number_rec.lot_num := NULL;
                        l_lot_control_code := 1;
                          -- END;        --commented for bug 7559682

                        --End If;  --commented for bug 7559682
                    END;
                    -- End If; -- End Bug#3009495

                    IF g_debug= C_Debug_Enabled THEN
                          l_Fnd_Log_Message := 'Calling query_res with following IN paramter values: ';
                          mydebug(l_Fnd_Log_Message, c_api_name,9);
                          l_Fnd_Log_Message := 'p_supply_source_header_id :' || get_rcv_transaction_rec.po_header_id;
                          mydebug(l_Fnd_Log_Message, c_api_name,9);
                          l_Fnd_Log_Message := 'p_supply_source_line_id : '|| get_rcv_transaction_rec.po_line_location_id;
                          mydebug(l_Fnd_Log_Message, c_api_name,9);
                          l_Fnd_Log_Message := 'p_supply_source_type_id : '|| inv_reservation_global.g_source_type_po;
                          mydebug(l_Fnd_Log_Message, c_api_name,9);
                          l_Fnd_Log_Message := 'p_project_id : '|| get_rcv_transaction_rec.project_id;
                          mydebug(l_Fnd_Log_Message, c_api_name,9);
                          l_Fnd_Log_Message := 'p_task_id: '||get_rcv_transaction_rec.task_id;
                          mydebug(l_Fnd_Log_Message, c_api_name,9);
                    END IF;
                    query_res(p_supply_source_header_id  => get_rcv_transaction_rec.po_header_id
                             ,p_supply_source_line_id    => get_rcv_transaction_rec.po_line_location_id
                             ,p_supply_source_type_id    => inv_reservation_global.g_source_type_po
                             ,p_project_id               => get_rcv_transaction_rec.project_id
                             ,p_task_id                  => get_rcv_transaction_rec.task_id
                             ,x_rsv_array                => l_rsv_array
                             ,x_record_count             => l_record_count
                             ,x_msg_count                => x_msg_count
                             ,x_msg_data                 => x_msg_data
                             ,x_return_status            => l_return_status);

                    IF g_debug= C_Debug_Enabled THEN
                        l_Fnd_Log_Message := 'l_record_count: '|| l_record_count;
                        mydebug(l_Fnd_Log_Message, c_api_name,9);
                        l_Fnd_Log_Message := 'l_return_status: '|| l_return_status;
                        mydebug(l_Fnd_Log_Message, c_api_name,9);
                    END IF;
                    IF l_record_count > 0 THEN
                       l_record_index := 1;

                       /* Fix for Bug#8673423. Populated secondary_uom_code from cache and
                          added secondary_uom_code and secondary_res_quantity in transfer_res
                       */

                      IF (get_rcv_transaction_rec.secondary_unit_of_measure IS NOT NULL ) THEN
                       IF (INV_CACHE.set_item_rec(get_rcv_transaction_rec.to_organization_id,
                                                  get_rcv_transaction_rec.item_id)) THEN
                           l_secondary_uom_code := INV_CACHE.item_rec.secondary_uom_code ;

                       END IF ;
                      END IF ;

                       LOOP
                          EXIT WHEN get_rcv_transaction_rec.primary_quantity = 0;
                          IF g_debug= C_Debug_Enabled THEN
                             l_Fnd_Log_Message := 'get_rcv_transaction_rec.primary_quantity: '||get_rcv_transaction_rec.primary_quantity;
                             mydebug(l_Fnd_Log_Message, c_api_name,9);
                             l_Fnd_Log_Message := 'get_rcv_transaction_rec.secondary_quantity: '||get_rcv_transaction_rec.secondary_quantity;
                             mydebug(l_Fnd_Log_Message, c_api_name,9);
                          END IF;
                          IF l_record_index <= l_record_count THEN
                             IF g_debug= C_Debug_Enabled THEN
                                l_Fnd_Log_Message := 'l_record_index: '|| l_record_index;
                                mydebug(l_Fnd_Log_Message, c_api_name,9);
                                l_Fnd_Log_Message := 'l_rsv_array(l_record_index).primary_reservation_quantity:'
                                                      || l_rsv_array(l_record_index).primary_reservation_quantity;
                                mydebug(l_Fnd_Log_Message, c_api_name,9);
                                l_Fnd_Log_Message := 'calling transfer_res with folling IN paramter values:';
                                mydebug(l_Fnd_Log_Message, c_api_name,9);

                             END IF;

                               -- 4891711 use lot level quantities where lot control is appropriate



                             IF l_rsv_array(l_record_index).primary_reservation_quantity
                               > NVL(get_rcv_lot_number_rec.primary_quantity,get_rcv_transaction_rec.primary_quantity) THEN


                                 TRANSFER_RES
                                 (p_from_reservation_id       => l_rsv_array(l_record_index).reservation_id
                                  ,p_from_source_header_id    => get_rcv_transaction_rec.po_header_id
                                  ,p_from_source_line_id      => get_rcv_transaction_rec.po_line_location_id
                                  ,p_supply_source_type_id    => inv_reservation_global.g_source_type_po
                                  ,p_to_supply_source_type_id => inv_reservation_global.g_source_type_inv
                                  ,p_subinventory_code        => get_rcv_transaction_rec.subinventory
                                  ,p_locator_id               => get_rcv_transaction_rec.locator_id
                                  ,p_lot_number               => NVL(get_rcv_lot_number_rec.lot_num, NULL)
                                  ,p_revision                 => get_rcv_transaction_rec.item_revision
                                  ,p_lpn_id                   => get_rcv_transaction_rec.lpn_id
                                  ,p_primary_uom_code         => get_rcv_transaction_rec.primary_unit_of_measure
                                  ,p_primary_res_quantity     => NVL(get_rcv_lot_number_rec.primary_quantity,
                                                                     get_rcv_transaction_rec.primary_quantity)
                                  ,p_secondary_uom_code       => l_secondary_uom_code
                                  ,p_secondary_res_quantity   => NVL(get_rcv_lot_number_rec.secondary_quantity,
                                                                     get_rcv_transaction_rec.secondary_quantity)
                                  ,x_msg_count                => x_msg_count
                                  ,x_msg_data                 => x_msg_data
                                  ,x_return_status            => l_return_status);

                                  get_rcv_transaction_rec.primary_quantity := get_rcv_transaction_rec.primary_quantity
                                                                                 - NVL(get_rcv_lot_number_rec.primary_quantity,
                                                                                       get_rcv_transaction_rec.primary_quantity);

                                  -- Bug 5611560 *** Possible case of split reservation .
                                  -- Set the Remaining reservation Quantity which is still can be transferred.
                                  -- The Lot can be fully satisfied by the Reservation so Set the Lot qty as Zero.

                                  l_rsv_array(l_record_index).primary_reservation_quantity :=
                                       l_rsv_array(l_record_index).primary_reservation_quantity
                                       - NVL(get_rcv_lot_number_rec.primary_quantity,get_rcv_transaction_rec.primary_quantity);

                                  IF (l_lot_control_code = 2) then
                                     get_rcv_lot_number_rec.primary_quantity := 0;
                                  END IF;

                                  IF g_debug= C_Debug_Enabled THEN
                                    l_Fnd_Log_Message := 'Remaining reserv Qty := '||l_rsv_array(l_record_index).primary_reservation_quantity;
                                    mydebug(l_Fnd_Log_Message, c_api_name,9);
                                  END IF;

                             ELSE
                                  TRANSFER_RES
                                  (p_from_reservation_id       => l_rsv_array(l_record_index).reservation_id
                                  ,p_from_source_header_id     => get_rcv_transaction_rec.po_header_id
                                  ,p_from_source_line_id       => get_rcv_transaction_rec.po_line_location_id
                                  ,p_supply_source_type_id     => inv_reservation_global.g_source_type_po
                                  ,p_to_supply_source_type_id  => inv_reservation_global.g_source_type_inv
                                  ,p_subinventory_code         => get_rcv_transaction_rec.subinventory
                                  ,p_locator_id                => get_rcv_transaction_rec.locator_id
                                  ,p_lot_number                => NVL(get_rcv_lot_number_rec.lot_num, NULL)
                                  ,p_revision                  => get_rcv_transaction_rec.item_revision
                                  ,p_lpn_id                    => get_rcv_transaction_rec.lpn_id
                                  ,p_primary_uom_code          => get_rcv_transaction_rec.primary_unit_of_measure
                                  ,p_primary_res_quantity      => l_rsv_array(l_record_index).primary_reservation_quantity
                                  ,p_secondary_uom_code        => l_secondary_uom_code
                                  ,p_secondary_res_quantity    => l_rsv_array(l_record_index).secondary_reservation_quantity
                                  ,x_msg_count                 => x_msg_count
                                  ,x_msg_data                  => x_msg_data
                                  ,x_return_status             => l_return_status);

                                  get_rcv_transaction_rec.primary_quantity :=
                                    get_rcv_transaction_rec.primary_quantity - l_rsv_array(l_record_index).primary_reservation_quantity;

                                  -- Bug 5611560. reservation is fully consumed. So Set the
                                  -- Remaining resesrvation for this row as zero .
                                  -- Also Reduce the Lot Qty by the Reservation Qty transferred to Inv the same way
                                  -- as done above for delivered qty.

                                  IF (l_lot_control_code = 2) then
                                     get_rcv_lot_number_rec.primary_quantity := get_rcv_lot_number_rec.primary_quantity
                                     - l_rsv_array(l_record_index).primary_reservation_quantity;

                                     IF g_debug= C_Debug_Enabled THEN
                                         l_Fnd_Log_Message := 'Remaining lot Qty := '||get_rcv_lot_number_rec.primary_quantity;
                                         mydebug(l_Fnd_Log_Message, c_api_name,9);
                                     END IF;
                                  END IF;

                                  l_rsv_array(l_record_index).primary_reservation_quantity := 0;

                                  IF g_debug= C_Debug_Enabled THEN
                                      l_Fnd_Log_Message := 'Reservation Transfered completely for this Line';
                                      mydebug(l_Fnd_Log_Message, c_api_name,9);
                                  END IF;

                               END IF;

                               IF g_debug= C_Debug_Enabled THEN
                                  l_Fnd_Log_Message := 'l_return_status:'|| l_return_status;
                                  mydebug(l_Fnd_Log_Message, c_api_name,9);
                               END IF;
                          ELSE
                             IF g_debug= C_Debug_Enabled THEN
                                l_Fnd_Log_Message := 'l_record_index > l_record_count. more received than reserved.
                                  l_record_count :' || l_record_count || ' l_record_index: '|| l_record_index;
                                mydebug(l_Fnd_Log_Message, c_api_name,9);
                             END IF;
                             EXIT;
                          END IF;   -- res_qty > received_qty
                          -- 4891711 BEGIN need lot level looping

                          -- 5611560
                          -- Changed the Logic so that when reservation qty is set as zero the index is increased
                          -- Also when there is no more Lot rows just exit from the Loop;
                          --
                          IF (l_lot_control_code = 2) then
                              Begin
                                   IF get_rcv_lot_number_rec.primary_quantity = 0 then
                                      FETCH get_rcv_txn_lot_number INTO get_rcv_lot_number_rec;
                                      IF get_rcv_txn_lot_number%NOTFOUND THEN
                                         CLOSE get_rcv_txn_lot_number;
                                         --l_record_index := l_record_index + 1;
                                         -- No Need to Loop again Just Return from here.
                                         EXIT;
                                      END IF;
                                   END IF;
                              END;
                          END IF;

                          -- Bug 5611560
                          -- Increase the Index when no more reservation qty to be transfered.
                          IF ( l_rsv_array(l_record_index).primary_reservation_quantity = 0 ) THEN
                            l_record_index := l_record_index + 1;
                          End If;

                          -- 4891711 END

                       END LOOP;
                    ELSE -- l_record_count = 0
                         -- there is no reservation existing
                         -- log messeage
                         IF g_debug= C_Debug_Enabled THEN
                               l_Fnd_Log_Message := 'l_return_status:'|| l_return_status;
                               mydebug(l_Fnd_Log_Message, c_api_name,9);
                         END IF;

                    END IF;  -- l_record_count > 0

              END IF; -- get_rcv_transaction%found

          ELSIF get_rcv_transaction_rec.supply_type = 'ASN' THEN
             IF g_debug= C_Debug_Enabled THEN
                mydebug( 'DTI. ASN.', c_api_name,9);
             END IF;
             OPEN  get_rcv_transaction_asn(p_transaction_id);
             FETCH get_rcv_transaction_asn into get_rcv_transaction_asn_rec;
             --CLOSE get_rcv_transaction_asn;

             IF get_rcv_transaction_asn%FOUND THEN

                IF get_rcv_transaction_asn_rec.item_revision is NULL then

                  BEGIN
                     SELECT    max(mir.revision)
                       INTO    l_item_revision
                       FROM    mtl_system_items msi
                       , mtl_item_revisions mir
                       WHERE    msi.inventory_item_id = get_rcv_transaction_asn_rec.item_id
                       AND    msi.organization_id = get_rcv_transaction_asn_rec.organization_id
                       AND    msi.revision_qty_control_code = 2
                       AND    mir.organization_id = msi.organization_id
                       AND    msi.inventory_item_id = msi.inventory_item_id
                       AND    mir.effectivity_date in
                       (SELECT   MAX(mir2.effectivity_date)
                        FROM   mtl_item_revisions mir2
                        WHERE   mir2.organization_id = get_rcv_transaction_asn_rec.organization_id
                        AND   mir2.inventory_item_id = get_rcv_transaction_asn_rec.item_id
                        AND   mir2.effectivity_date <= SYSDATE
                        AND   mir2.implementation_date is not NULL);


                        get_rcv_transaction_rec.item_revision := l_item_revision;

                  EXCEPTION when others then
                     l_item_revision := NULL;
                     get_rcv_transaction_rec.item_revision := NULL;
                  END;

                 ELSE
                     /* Begin Bug 3688014 : If the rcv_shipment_lines contains a item revision
                     for a non-revision controlled item, we should pass a NULL
                       item revision to inventory so that supply gets updated accordingly.
                       */
                       BEGIN

                          SELECT msi.revision_qty_control_code
                            INTO l_revision_control_code
                            FROM mtl_system_items_b msi
                            WHERE msi.inventory_item_id = get_rcv_transaction_asn_rec.item_id
                            AND msi.organization_id = get_rcv_transaction_asn_rec.organization_id;

                          IF  l_revision_control_code = 1 THEN
                             get_rcv_transaction_asn_rec.item_revision := NULL;
                          END IF;

                       EXCEPTION
                          WHEN others THEN
                             get_rcv_transaction_asn_rec.item_revision := NULL;
                       END;

                       /* End Bug 3688014 */

                END IF;  --get_rcv_transaction_asn_rec.item_revision is NULL


                --Bug#3009495.If item is lot controlled then we will derive the lot number
                --from the rcv_lot_transactions.
                get_rcv_lot_number_rec.lot_num := NULL;
                --IF get_shipment_lines%FOUND THEN

                --Bug 7559682 Error performing deliver transaction for Direct Items in EAM workorder
                --having destination type as shop floor. Modified the code block to include MSI query
                BEGIN
                    select nvl(lot_control_code,1)
                      into   l_lot_control_code
                      from   mtl_system_items
                     where  organization_id = get_rcv_transaction_asn_rec.to_organization_id
                       and  inventory_item_id = get_rcv_transaction_asn_rec.item_id ;

                    IF (l_lot_control_code = 2) THEN
                       --Begin         --commented for bug 7559682
                          -- 5611560 New cursor is opened and fetched.
                          OPEN  get_rcv_txn_lot_number(get_rcv_transaction_asn_rec.shipment_line_id,p_transaction_id);
                          FETCH get_rcv_txn_lot_number INTO get_rcv_lot_number_rec;
                    END IF;

                EXCEPTION
                  WHEN OTHERS THEN
                    get_rcv_lot_number_rec.lot_num := NULL;
                    l_lot_control_code := 1;
                      -- END;        --commented for bug 7559682

                    --End If;  --commented for bug 7559682
                END;
                -- End If; -- End Bug#3009495

                query_res
                  (p_supply_source_header_id  => get_rcv_transaction_asn_rec.po_header_id
                   ,p_supply_source_line_id    => get_rcv_transaction_asn_rec.po_line_location_id
                   ,p_supply_source_type_id    => inv_reservation_global.g_source_type_po
                   ,p_project_id               => get_rcv_transaction_asn_rec.project_id
                   ,p_task_id                  => get_rcv_transaction_asn_rec.task_id
                   ,x_rsv_array                => l_rsv_array
                   ,x_record_count             => l_record_count
                   ,x_msg_count                => x_msg_count
                   ,x_msg_data                 => x_msg_data
                   ,x_return_status            => l_return_status);


                IF l_record_count > 0 THEN
                   IF (get_rcv_transaction_asn_rec.primary_unit_of_measure <> l_rsv_array(1).primary_uom_code) THEN

                      l_primary_quantity := inv_convert.inv_um_convert
                        (
                         item_id        => get_rcv_transaction_asn_rec.item_id,
                         precision      => NULL,
                         from_quantity  => get_rcv_transaction_asn_rec.primary_quantity,
                         from_unit      => get_rcv_transaction_asn_rec.primary_unit_of_measure,
                         to_unit        => l_rsv_array(1).primary_uom_code,
                         from_name      => NULL,
                         to_name        => NULL);

                      get_rcv_transaction_asn_rec.primary_quantity := l_primary_quantity;

                   END IF;

                   l_record_index := 1;



                   LOOP

                      EXIT WHEN get_rcv_transaction_asn_rec.primary_quantity = 0;

                      IF l_record_index <= l_record_count THEN

                         IF l_rsv_array(l_record_index).primary_reservation_quantity > get_rcv_transaction_asn_rec.primary_quantity THEN
                            TRANSFER_RES
                              (p_from_reservation_id           => l_rsv_array(l_record_index).reservation_id
                               , p_from_source_header_id     => get_rcv_transaction_asn_rec.po_header_id
                               ,p_from_source_line_id       => get_rcv_transaction_asn_rec.po_line_location_id
                               ,p_supply_source_type_id     => inv_reservation_global.g_source_type_po
                               ,p_to_supply_source_type_id  => inv_reservation_global.g_source_type_inv
                               ,p_subinventory_code         => get_rcv_transaction_rec.subinventory
                               ,p_locator_id                => get_rcv_transaction_rec.locator_id
                               ,p_lot_number                => NVL(get_rcv_lot_number_rec.lot_num, NULL)
                               ,p_revision                  => get_rcv_transaction_asn_rec.item_revision
                               ,p_lpn_id                    => get_rcv_transaction_asn_rec.lpn_id
                               ,p_primary_uom_code          => get_rcv_transaction_asn_rec.primary_unit_of_measure
                               ,p_primary_res_quantity      => get_rcv_transaction_asn_rec.primary_quantity
                               --,p_action                    => l_action  it is never used. I remove it from procedure transfer_res
                              ,x_msg_count                 => x_msg_count
                              ,x_msg_data                  => x_msg_data
                              ,x_return_status             => l_return_status);
                            get_rcv_transaction_asn_rec.primary_quantity := 0;
                          ELSE
                            TRANSFER_RES
                              (p_from_reservation_id           => l_rsv_array(l_record_index).reservation_id
                               ,p_from_source_header_id     => get_rcv_transaction_asn_rec.po_header_id
                               ,p_from_source_line_id       => get_rcv_transaction_asn_rec.po_line_location_id
                               ,p_supply_source_type_id     => inv_reservation_global.g_source_type_po
                               ,p_to_supply_source_type_id  => inv_reservation_global.g_source_type_inv
                               ,p_subinventory_code         => get_rcv_transaction_asn_rec.subinventory
                               ,p_locator_id                => get_rcv_transaction_asn_rec.locator_id
                               ,p_lot_number                => NVL(get_rcv_lot_number_rec.lot_num, NULL)
                               ,p_revision                  => get_rcv_transaction_asn_rec.item_revision
                               ,p_lpn_id                    => get_rcv_transaction_asn_rec.lpn_id
                               ,p_primary_uom_code          => get_rcv_transaction_asn_rec.primary_unit_of_measure
                               ,p_primary_res_quantity      => l_rsv_array(l_record_index).primary_reservation_quantity
                               -- ,p_action                    IN VARCHAR2  DEFAULT NULL
                              ,x_msg_count                 => x_msg_count
                              ,x_msg_data                  => x_msg_data
                              ,x_return_status             => l_return_status);
                            get_rcv_transaction_asn_rec.primary_quantity := get_rcv_transaction_asn_rec.primary_quantity
                              - l_rsv_array(l_record_index).primary_reservation_quantity;
                         END IF;
                       ELSE
                         -- raise error: since received more qty than reserved qty ??
                         IF g_debug= C_Debug_Enabled THEN
                            l_Fnd_Log_Message := 'l_record_index > l_record_count. more received than reserved.
                            l_record_count :' || l_record_count || ' l_record_index: ' || l_record_index;
                            mydebug(l_Fnd_Log_Message, c_api_name,9);
                         END IF;
                         EXIT;
                      END IF;   -- res_qty > received_qty
                      l_record_index := l_record_index + 1;

                   END LOOP;
                  ELSE -- l_record_count = 0
                         -- there is no reservation existing
                         -- log messeage
                         IF g_debug= C_Debug_Enabled THEN
                               l_Fnd_Log_Message := 'l_return_status:'|| l_return_status;
                               mydebug(l_Fnd_Log_Message, c_api_name,9);
                         END IF;
                END IF;  -- l_record_count > 0
             END IF;  -- %FOUND
             CLOSE get_rcv_transaction_asn;
            END IF;

          ELSIF get_source_doc_code_rec.source_document_code = 'REQ' THEN
             IF g_debug= C_Debug_Enabled THEN
                mydebug( 'DTI. Requisition.', c_api_name,9);
             END IF;
             OPEN  get_rcv_txn_int_req(p_transaction_id);
             FETCH get_rcv_txn_int_req into get_rcv_txn_int_req_rec;
             --CLOSE get_rcv_txn_int_req;

             IF get_rcv_txn_int_req%FOUND THEN

                IF g_debug= C_Debug_Enabled THEN
                   mydebug( 'Item revision' || get_rcv_txn_int_req_rec.item_revision, c_api_name,9);
                END IF;
                IF get_rcv_txn_int_req_rec.item_revision is NULL then

                   BEGIN
                      SELECT    max(mir.revision)
                        INTO    l_item_revision
                        FROM    mtl_system_items msi
                        , mtl_item_revisions mir
                        WHERE    msi.inventory_item_id = get_rcv_txn_int_req_rec.item_id
                        AND    msi.organization_id = get_rcv_txn_int_req_rec.organization_id
                        AND    msi.revision_qty_control_code = 2
                        AND    mir.organization_id = msi.organization_id
                        AND    msi.inventory_item_id = msi.inventory_item_id
                        AND    mir.effectivity_date in
                        (SELECT   MAX(mir2.effectivity_date)
                         FROM   mtl_item_revisions mir2
                         WHERE   mir2.organization_id = get_rcv_txn_int_req_rec.organization_id
                         AND   mir2.inventory_item_id = get_rcv_txn_int_req_rec.item_id
                         AND   mir2.effectivity_date <= SYSDATE
                         AND   mir2.implementation_date is not NULL);


                         get_rcv_txn_int_req_rec.item_revision := l_item_revision;

                   EXCEPTION when others then
                      l_item_revision := NULL;
                   END;

                 ELSE
                      IF g_debug= C_Debug_Enabled THEN
                         mydebug( 'Inside rev not null', c_api_name,9);
                         mydebug( 'Item id :' || get_rcv_txn_int_req_rec.item_id, c_api_name,9);
                         mydebug( 'Org :' || get_rcv_txn_int_req_rec.organization_id, c_api_name,9);
                      END IF;
                      /* Begin Bug 3688014 : If the rcv_shipment_lines contains a item revision
                      for a non-revision controlled item, we should pass a NULL
                        item revision to inventory so that supply gets updated accordingly.
                        */
                        --Bug 5147013: Changed the cursor name to get the
                        -- item and org from the correct one.
                        BEGIN
                           SELECT msi.revision_qty_control_code
                             INTO l_revision_control_code
                             FROM mtl_system_items_b msi
                             WHERE msi.inventory_item_id = get_rcv_txn_int_req_rec.item_id
                             AND msi.organization_id = get_rcv_txn_int_req_rec.organization_id;

                           IF g_debug= C_Debug_Enabled THEN
                              mydebug( 'rev control is: ' || l_revision_control_code, c_api_name,9);
                           END IF;
                           IF  l_revision_control_code = 1 THEN
                              get_rcv_txn_int_req_rec.item_revision := NULL;
                           END IF;

                        EXCEPTION
                           WHEN no_data_found THEN
                              get_rcv_txn_int_req_rec.item_revision := NULL;
                           WHEN OTHERS THEN
                              get_rcv_txn_int_req_rec.item_revision := NULL;
                        END;

                        /* End Bug 3688014 */

                END IF;  --get_rcv_txn_req_rec.item_revision is NULL


               --Bug#3009495.If item is lot controlled then we will derive the lot number
                --from the rcv_lot_transactions.
                get_rcv_lot_number_rec.lot_num := NULL;
                --IF get_shipment_lines%FOUND THEN

                --Bug 7559682 Error performing deliver transaction for Direct Items in EAM workorder
                --having destination type as shop floor. Modified the code block to include MSI query
                BEGIN

                    IF g_debug= C_Debug_Enabled THEN
                        mydebug( 'Org_id = '||get_rcv_txn_int_req_rec.to_organization_id, c_api_name,9);
                        mydebug( 'Item_id = '||get_rcv_txn_int_req_rec.item_id, c_api_name,9);
                    END IF;

                    select nvl(lot_control_code,1)
                      into   l_lot_control_code
                      from   mtl_system_items
                     where  organization_id = get_rcv_txn_int_req_rec.to_organization_id
                       and  inventory_item_id = get_rcv_txn_int_req_rec.item_id ;

                    IF g_debug= C_Debug_Enabled THEN
                        mydebug( 'Lot Control Code = '||l_lot_control_code, c_api_name,9);
                    END IF;

                    IF (l_lot_control_code = 2) THEN
                       --Begin         --commented for bug 7559682
                          -- 5611560 New cursor is opened and fetched.

                          IF g_debug= C_Debug_Enabled THEN
                                mydebug( 'RSL_ID = '||get_rcv_txn_int_req_rec.shipment_line_id, c_api_name,9);
                          END IF;
                          OPEN  get_rcv_txn_lot_number(get_rcv_txn_int_req_rec.shipment_line_id,p_transaction_id);
                          FETCH get_rcv_txn_lot_number INTO get_rcv_lot_number_rec;
                    END IF;

                    IF g_debug= C_Debug_Enabled THEN
                        mydebug( 'get_rcv_lot_number_rec.lot_num = '||get_rcv_lot_number_rec.lot_num, c_api_name,9);
                    END IF;

                EXCEPTION
                  WHEN OTHERS THEN
                    IF g_debug= C_Debug_Enabled THEN
                        mydebug( 'Fetch Lot Control Code Exc: '||SQLERRM, c_api_name,9);
                    END IF;
                    get_rcv_lot_number_rec.lot_num := NULL;
                    l_lot_control_code := 1;
                      -- END;        --commented for bug 7559682

                    --End If;  --commented for bug 7559682
                END;
                -- End If; -- End Bug#3009495

                query_res
                  (p_supply_source_header_id  => get_rcv_txn_int_req_rec.requisition_header_id
                   ,p_supply_source_line_id    => get_rcv_txn_int_req_rec.requisition_line_id
                   ,p_supply_source_type_id    => inv_reservation_global.g_source_type_internal_req
                   ,p_project_id               => get_rcv_txn_int_req_rec.project_id
                   ,p_task_id                  => get_rcv_txn_int_req_rec.task_id
                   ,x_rsv_array                => l_rsv_array
                   ,x_record_count             => l_record_count
                   ,x_msg_count                => x_msg_count
                   ,x_msg_data                 => x_msg_data
                   ,x_return_status            => l_return_status);

                IF l_record_count > 0 THEN
                   IF (get_rcv_txn_int_req_rec.primary_unit_of_measure <> l_rsv_array(1).primary_uom_code) THEN
                      l_primary_quantity := inv_convert.inv_um_convert
                        (
                         item_id        => get_rcv_txn_int_req_rec.item_id,
                         precision      => NULL,
                         from_quantity  => get_rcv_txn_int_req_rec.primary_quantity,
                         from_unit      => get_rcv_txn_int_req_rec.primary_unit_of_measure,
                         to_unit        => l_rsv_array(1).primary_uom_code,
                         from_name      => NULL,
                         to_name        => NULL);

                      get_rcv_txn_int_req_rec.primary_quantity := l_primary_quantity;

                   END IF;

                   l_record_index := 1;

                   /* Fix for Bug#8673423. Populated secondary_uom_code from cache and
                      added secondary_uom_code and secondary_res_quantity in transfer_res
                   */

                   IF (get_rcv_txn_int_req_rec.secondary_unit_of_measure IS NOT NULL ) THEN
                     IF (INV_CACHE.set_item_rec(get_rcv_txn_int_req_rec.to_organization_id,
                                             get_rcv_txn_int_req_rec.item_id)) THEN
                        l_secondary_uom_code := INV_CACHE.item_rec.secondary_uom_code ;

                     END IF ;
                   END IF ;

                   LOOP

                     EXIT WHEN get_rcv_txn_int_req_rec.primary_quantity = 0;

                     IF l_record_index <= l_record_count THEN

                        IF l_rsv_array(l_record_index).primary_reservation_quantity > get_rcv_txn_int_req_rec.primary_quantity THEN

                           /* Fix for Bug#8673423. Added secondary_uom_code and secondary_res_quantity */

                           TRANSFER_RES
                             (p_from_reservation_id           => l_rsv_array(l_record_index).reservation_id
                              ,p_from_source_header_id     => get_rcv_txn_int_req_rec.requisition_header_id
                              ,p_from_source_line_id       => get_rcv_txn_int_req_rec.requisition_line_id
                              ,p_supply_source_type_id     => inv_reservation_global.g_source_type_internal_req
                              ,p_to_supply_source_type_id  => inv_reservation_global.g_source_type_inv
                              ,p_subinventory_code         => get_rcv_txn_int_req_rec.subinventory
                              ,p_locator_id                => get_rcv_txn_int_req_rec.locator_id
                              ,p_lot_number                => NVL(get_rcv_lot_number_rec.lot_num, NULL)
                              ,p_revision                  => get_rcv_txn_int_req_rec.item_revision
                              ,p_lpn_id                    => get_rcv_txn_int_req_rec.lpn_id
                              ,p_primary_uom_code          => get_rcv_txn_int_req_rec.primary_unit_of_measure
                                            ,p_primary_res_quantity      => get_rcv_txn_int_req_rec.primary_quantity
                              --,p_action                    => l_action  it is never used. I remove it from procedure transfer_res
                             ,p_secondary_uom_code          => l_secondary_uom_code
                             ,p_secondary_res_quantity   => NVL(get_rcv_lot_number_rec.secondary_quantity,
                                                                get_rcv_txn_int_req_rec.secondary_quantity)
                             ,x_msg_count                 => x_msg_count
                             ,x_msg_data                  => x_msg_data
                             ,x_return_status             => l_return_status);
                                  get_rcv_txn_int_req_rec.primary_quantity := 0;
                         ELSE
                           TRANSFER_RES
                             (p_from_reservation_id           => l_rsv_array(l_record_index).reservation_id
                              ,p_from_source_header_id     => get_rcv_txn_int_req_rec.requisition_header_id
                              ,p_from_source_line_id       => get_rcv_txn_int_req_rec.requisition_line_id
                                             ,p_supply_source_type_id     => inv_reservation_global.g_source_type_internal_req
                              ,p_to_supply_source_type_id  => inv_reservation_global.g_source_type_inv
                              ,p_subinventory_code         => get_rcv_txn_int_req_rec.subinventory
                              ,p_locator_id                => get_rcv_txn_int_req_rec.locator_id
                              ,p_lot_number                => NVL(get_rcv_lot_number_rec.lot_num, NULL)
                              ,p_revision                  => get_rcv_txn_int_req_rec.item_revision
                              ,p_lpn_id                    => get_rcv_txn_int_req_rec.lpn_id
                              ,p_primary_uom_code          => get_rcv_txn_int_req_rec.primary_unit_of_measure
                              ,p_primary_res_quantity      => l_rsv_array(l_record_index).primary_reservation_quantity
                              ,p_secondary_uom_code        => l_secondary_uom_code
                              ,p_secondary_res_quantity   => NVL(get_rcv_lot_number_rec.secondary_quantity,
                                                                get_rcv_txn_int_req_rec.secondary_quantity)
                             -- ,p_action                    IN VARCHAR2  DEFAULT NULL
                             ,x_msg_count                 => x_msg_count
                             ,x_msg_data                  => x_msg_data
                             ,x_return_status             => l_return_status);
                           get_rcv_txn_int_req_rec.primary_quantity := get_rcv_txn_int_req_rec.primary_quantity
                             - l_rsv_array(l_record_index).primary_reservation_quantity;
                        END IF;
                      ELSE
                        -- raise error: since received more qty than reserved qty ??
                        IF g_debug= C_Debug_Enabled THEN
                           l_Fnd_Log_Message := 'l_record_index > l_record_count. more received than reserved.
                              l_record_count :' || l_record_count || ' l_record_index: '|| l_record_index;
                           mydebug(l_Fnd_Log_Message, c_api_name,9);
                        END IF;
                        EXIT;
                     END IF;   -- res_qty > received_qty
                     l_record_index := l_record_index + 1;

                  END LOOP;
                 ELSE -- l_record_count = 0
                                -- there is no reservation existing
                                -- log messeage
                        IF g_debug= C_Debug_Enabled THEN
                           l_Fnd_Log_Message := 'l_return_status:'|| l_return_status;
                           mydebug(l_Fnd_Log_Message, c_api_name,9);
                        END IF;
                END IF;  -- l_record_count > 0
             END IF;  -- %FOUND
             CLOSE get_rcv_txn_int_req;
          ELSE
                   -- do nothing. DO not support reservations for In-transit shipments in inventory orgs
                   -- log message
                   IF g_debug= C_Debug_Enabled THEN
                      mydebug( 'Other source type. Do not support: ' || get_source_doc_code_rec.source_document_code, c_api_name,9);
                   END IF;
                   NULL;
         END IF;  -- if supply_type = 'PO'

      END IF;  -- if wms org


      -- 5611560
      IF get_rcv_txn_lot_number%ISOPEN THEN
         CLOSE get_rcv_txn_lot_number;
      END IF;

      IF get_rcv_lot_number%ISOPEN THEN
         CLOSE get_rcv_lot_number;
      END IF;

      IF get_rcv_transaction%ISOPEN THEN
         CLOSE get_rcv_transaction;
      END IF;

      IF get_source_doc_code%isopen THEN
         CLOSE get_source_doc_code;
      END IF;

   ELSIF upper(p_action) = 'APPROVE_BLANKET_RELEASE_SUPPLY'  THEN
      IF g_debug= C_Debug_Enabled THEN
         mydebug( 'Approve Blanket Release Supply.', c_api_name,9);
      END IF;

      OPEN get_po_shipment_for_release(p_header_id);
      LOOP
          FETCH get_po_shipment_for_release INTO get_po_shipment_rel_rec;
          EXIT WHEN get_po_shipment_for_release%NOTFOUND;

          IF g_debug= C_Debug_Enabled THEN
             mydebug( 'get_po_shipment_rel_rec.line_location_id: '||get_po_shipment_rel_rec.line_location_id, c_api_name,9);
          END IF;

          IF NOT EXISTS_RESERVATION(p_supply_source_line_id => get_po_shipment_rel_rec.line_location_id) THEN

             IF g_debug= C_Debug_Enabled THEN
                mydebug( 'No reservations exist for blanket release', c_api_name,9);
             END IF;

             OPEN get_req_line_of_po_shipment(get_po_shipment_rel_rec.line_location_id);
             LOOP
                 FETCH get_req_line_of_po_shipment INTO get_req_line_po_shipment_rec;
                 EXIT WHEN get_req_line_of_po_shipment%NOTFOUND;

                 IF g_debug= C_Debug_Enabled THEN
                    l_Fnd_Log_Message := 'Before get_req_line_po_shipment_rec.project_id: '||get_req_line_po_shipment_rec.project_id;
                    mydebug(l_Fnd_Log_Message, c_api_name,9);
                    l_Fnd_Log_Message := 'before get_req_line_po_shipment_rec.task_id: '||get_req_line_po_shipment_rec.task_id;
                    mydebug(l_Fnd_Log_Message, c_api_name,9);
                 END IF;

                 IF (get_req_line_po_shipment_rec.project_id = -99) THEN
                    get_req_line_po_shipment_rec.project_id := NULL;
                 END IF;
                 IF (get_req_line_po_shipment_rec.task_id = -99) THEN
                    get_req_line_po_shipment_rec.task_id := NULL;
                 END IF;

                 IF g_debug= C_Debug_Enabled THEN
                    l_Fnd_Log_Message := 'after get_req_line_po_shipment_rec.project_id: '||get_req_line_po_shipment_rec.project_id;
                    mydebug(l_Fnd_Log_Message, c_api_name,9);
                    l_Fnd_Log_Message := 'after get_req_line_po_shipment_rec.task_id: '||get_req_line_po_shipment_rec.task_id;
                    mydebug(l_Fnd_Log_Message, c_api_name,9);
                 END IF;

               --  IF   (get_req_line_po_shipment_rec.project_id IS NOT NULL
                 --   OR
                   --    get_req_line_po_shipment_rec.task_id IS NOT NULL) THEN

                 IF g_debug= C_Debug_Enabled THEN
                    l_Fnd_Log_Message := 'get_req_line_po_shipment_rec.project_id or task_id is not null. Calling availibitly API';
                    mydebug(l_Fnd_Log_Message, c_api_name,9);
                 END IF;

                 INV_RESERVATION_AVAIL_PVT.available_supply_to_reserve
                   (
                    x_return_status            =>l_return_status
                    , x_msg_count                =>x_msg_count
                    , x_msg_data                 =>x_msg_data
                    , p_organization_id          =>get_po_shipment_rel_rec.ship_to_organization_id
                    , p_item_id                  =>get_po_shipment_rel_rec.item_id
                    , p_supply_source_type_id    =>inv_reservation_global.g_source_type_po
                    , p_supply_source_header_id  =>get_po_shipment_rel_rec.po_header_id
                    , p_supply_source_line_id    =>get_po_shipment_rel_rec.line_location_id
                    , p_project_id               =>get_req_line_po_shipment_rec.project_id
                    , p_task_id                  =>get_req_line_po_shipment_rec.task_id
                    , x_qty_available_to_reserve =>l_qty_avail_to_reserve
                    , x_qty_available            =>l_qty_avail
                    );

                 IF g_debug= C_Debug_Enabled THEN
                    l_Fnd_Log_Message := 'l_qty_avail_to_reserve: '|| l_qty_avail_to_reserve;
                    mydebug(l_Fnd_Log_Message, c_api_name,9);
                    l_Fnd_Log_Message := 'l_qty_avail: '|| l_qty_avail;
                    mydebug(l_Fnd_Log_Message, c_api_name,9);
                 END IF;

                 get_req_line_res
                   ( p_req_line_id  =>get_req_line_po_shipment_rec.req_line_id
                     ,p_project_id  =>get_req_line_po_shipment_rec.project_id
                     ,p_task_id     =>get_req_line_po_shipment_rec.task_id
                     ,x_res_array   =>l_rsv_array
                     ,x_record_count =>l_record_count);

                 IF g_debug= C_Debug_Enabled THEN
                    l_Fnd_Log_Message := 'l_record_count: '|| l_record_count;
                    mydebug(l_Fnd_Log_Message, c_api_name,9);
                 END IF;

                 IF l_record_count > 0 THEN
                    l_rsv_rec := l_rsv_array(1);
                    /*
                    uom_conversion(l_rsv_rec.reservation_uom_code
                      ,l_rsv_rec.primary_uom_code
                      ,get_req_line_po_shipment_rec.quantity_ordered
                      ,get_po_shipment_rel_rec.po_line_id
                      ,l_reservation_quantity
                      ,l_po_primary_qty); */

                      IF (l_rsv_rec.primary_reservation_quantity > l_qty_avail_to_reserve)  THEN
                         update_res
                           (p_supply_source_header_id => l_rsv_rec.supply_source_header_id
                            ,p_supply_source_line_id  => l_rsv_rec.supply_source_line_id
                            ,p_supply_source_type_id  => inv_reservation_global.g_source_type_req
                            ,p_primary_reservation_quantity => l_qty_avail_to_reserve
                            ,p_project_id  => get_req_line_po_shipment_rec.project_id
                            ,p_task_id                      => get_req_line_po_shipment_rec.task_id
                            ,p_reservation_id               => l_rsv_rec.reservation_id
                            ,x_msg_count                    => x_msg_count
                            ,x_msg_data                     => x_msg_data
                            ,x_return_status                => l_return_status);
                      END IF;

                      --BUG#3497445.The l_po_primary_qty calculated from the UOM_conversion call is used below.

                      l_primary_res_quantity  := least(l_rsv_rec.primary_reservation_quantity, l_qty_avail_to_reserve);

                      IF g_debug= C_Debug_Enabled THEN
                         l_Fnd_Log_Message := 'l_primary_res_quantity: '|| l_primary_res_quantity;
                         mydebug(l_Fnd_Log_Message, c_api_name,9);
                      END IF;

                      IF g_debug= C_Debug_Enabled THEN
                         l_Fnd_Log_Message := 'calling transfer reservation for, From req line id: '|| l_rsv_rec.supply_source_line_id
                           || ' to po shipment line id: ' || get_po_shipment_rel_rec.line_location_id;
                         mydebug(l_Fnd_Log_Message, c_api_name,9);
                      END IF;

                      TRANSFER_RES
                        (p_from_reservation_id        =>l_rsv_rec.reservation_id
                         ,p_from_source_header_id     =>l_rsv_rec.supply_source_header_id
                         ,p_from_source_line_id       =>l_rsv_rec.supply_source_line_id
                         ,p_supply_source_type_id     =>inv_reservation_global.g_source_type_req
                         ,p_to_source_header_id       =>get_po_shipment_rel_rec.po_header_id
                         ,p_to_source_line_id         =>get_po_shipment_rel_rec.line_location_id
                         ,p_to_supply_source_type_id  =>inv_reservation_global.g_source_type_po
                         ,p_primary_uom_code          =>l_rsv_rec.primary_uom_code
                         ,p_primary_res_quantity      =>l_primary_res_quantity
                         ,x_msg_count                 =>x_msg_count
                         ,x_msg_data                  =>x_msg_data
                         ,x_return_status             =>l_return_status);
                      IF g_debug= C_Debug_Enabled THEN
                         l_Fnd_Log_Message := 'after calling transfer_res. The l_return_status : '|| l_return_status;
                         mydebug(l_Fnd_Log_Message, c_api_name,9);
                      END IF;

                  ELSE -- if did not have any req reservation existing
                    IF g_debug= C_Debug_Enabled THEN
                       FND_MESSAGE.SET_NAME('INV','INV_API_NO_RSV_EXIST');
                       FND_MSG_PUB.Add;
                       l_Fnd_Log_Message := 'l_record_count < 0';
                       mydebug(l_Fnd_Log_Message, c_api_name,9);
                    END IF;
                 END IF; -- record_count
             END LOOP;
             CLOSE get_req_line_of_po_shipment;

          ELSE
             -- Reservation exists for Blanket PO - update reservation if quantity
             -- is decreased on the PO
             -- get the existing reservation quantity and compare it with the quantity on the PO
                    --
             IF g_debug= C_Debug_Enabled THEN
                l_Fnd_Log_Message := 'Reservation existing for Blanket release  ';
                mydebug(l_Fnd_Log_Message, c_api_name,9);
             END IF;

             OPEN  get_pt_count_po_shipment(get_po_shipment_rel_rec.line_location_id);
             FETCH get_pt_count_po_shipment INTO get_pt_count_po_shipment_rec;
             CLOSE get_pt_count_po_shipment;

             IF g_debug= C_Debug_Enabled THEN
                l_Fnd_Log_Message := ' get_pt_count_po_shipment_rec.count : '||get_pt_count_po_shipment_rec.count;
                mydebug(l_Fnd_Log_Message, c_api_name,9);
             END IF;

             IF get_pt_count_po_shipment_rec.count > 1 THEN   -- multiple project/task

                IF g_debug= C_Debug_Enabled THEN
                   l_Fnd_Log_Message := 'Multiple project/task...  ';
                   l_Fnd_Log_Message := 'get_po_shipment_rel_rec.ship_to_org_id:'||get_po_shipment_rec.ship_to_organization_id;
                   mydebug(l_Fnd_Log_Message, c_api_name,9);
                END IF;

                 IF (inv_install.adv_inv_installed(get_po_shipment_rel_rec.ship_to_organization_id))  THEN
                    -- is wms org
                    -- delete all the reservations for this shipment
                    -- log message
                    -- Commenting out the delete reservation call.  Call
                    -- reduce reservations instead
                    -- DELETE_RES
                    --   (p_supply_source_header_id  => get_po_shipment_rel_rec.po_header_id
                    -- ,p_supply_source_line_id    => get_po_shipment_rel_rec.line_location_id
                    --,p_supply_source_type_id    => inv_reservation_global.g_source_type_po
                    -- ,x_msg_count                => x_msg_count
                    -- ,x_msg_data                 => x_msg_data
                    -- ,x_return_status            => l_return_status);
                    -- Call reduce reservations instead of delete
                   -- reservations
                   -- Call the reduce reservations API by setting the
                   -- delete_flag to yes. delete all reservations for that
                   -- supply line.
                   -- calling reduce_reservation API
                    l_delete_flag := 'Y';
                    l_sort_by_criteria := inv_reservation_global.g_query_demand_ship_date_desc;
                    l_mtl_maint_rsv_rec.action := 0;--supply is reduced
                    l_mtl_maint_rsv_rec.organization_id := get_po_shipment_rel_rec.ship_to_organization_id;
                    l_mtl_maint_rsv_rec.inventory_item_id := get_po_shipment_rel_rec.item_id;
                    l_mtl_maint_rsv_rec.supply_source_type_id:= inv_reservation_global.g_source_type_po;
                    l_mtl_maint_rsv_rec.supply_source_header_id := get_po_shipment_rel_rec.po_header_id;
                    l_mtl_maint_rsv_rec.supply_source_line_id := get_po_shipment_rel_rec.line_location_id;
                 --   l_mtl_maint_rsv_rec.supply_source_line_detail := NULL;

                    reduce_reservation
                      (
                        p_api_version_number     => 1.0
                        , p_init_msg_lst           => fnd_api.g_false
                        , x_return_status          => l_return_status
                        , x_msg_count              => x_msg_count
                        , x_msg_data               => x_msg_data
                        , p_mtl_maintain_rsv_rec   => l_mtl_maint_rsv_rec
                        , p_delete_flag            => l_delete_flag
                        , p_sort_by_criteria       => l_sort_by_criteria
                        , x_quantity_modified      => l_quantity_modified);
                    IF g_debug= C_Debug_Enabled THEN
                       mydebug ('Return Status after calling reduce reservations: '|| l_return_status, c_api_name,9);
                    END IF;

                    IF l_return_status = fnd_api.g_ret_sts_error THEN

                       IF g_debug= C_Debug_Enabled THEN
                          mydebug('Raising expected error'|| l_return_status, c_api_name,9);
                       END IF;
                       RAISE fnd_api.g_exc_error;

                     ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN

                       IF g_debug= C_Debug_Enabled THEN
                          mydebug('Rasing Unexpected error'|| l_return_status, c_api_name,9);
                       END IF;
                       RAISE fnd_api.g_exc_unexpected_error;

                    END IF;
                 END IF;
             END IF;
             -- ELSE   -- inv org
             -- working through each project and task
             OPEN get_proj_task_of_po_shipment(get_po_shipment_rel_rec.line_location_id);
             LOOP
                FETCH  get_proj_task_of_po_shipment INTO
                  get_pt_po_shipment_rec;

                EXIT WHEN  get_proj_task_of_po_shipment%NOTFOUND;

                IF g_debug= C_Debug_Enabled THEN
                   mydebug('Inside project/task loop', c_api_name,9);
                END IF;
                IF g_debug= C_Debug_Enabled THEN
                   mydebug('Project Id: '|| get_pt_po_shipment_rec.project_id, c_api_name,9);
                   mydebug('Task Id: '|| get_pt_po_shipment_rec.task_id, c_api_name,9);
                END IF;

                IF (get_pt_po_shipment_rec.project_id = -99) THEN
                   get_pt_po_shipment_rec.project_id := NULL;
                END IF;
                IF (get_pt_po_shipment_rec.task_id = -99) THEN
                   get_pt_po_shipment_rec.task_id := NULL;
                END IF;

                INV_RESERVATION_AVAIL_PVT.available_supply_to_reserve
                  (
                   x_return_status            => l_return_status    --OUT  NOCOPY VARCHAR2
                   , x_msg_count                => x_msg_count     --OUT     NOCOPY NUMBER
                   , x_msg_data                 => x_msg_data     --OUT     NOCOPY VARCHAR2
                   , p_organization_id          => get_po_shipment_rel_rec.ship_to_organization_id--IN  NUMBER default null
                   , p_item_id                  => get_po_shipment_rel_rec.item_id--IN  NUMBER default null
                   , p_supply_source_type_id    => inv_reservation_global.g_source_type_po --IN NUMBER
                   , p_supply_source_header_id  => get_po_shipment_rel_rec.po_header_id --IN NUMBER ?? how do we query for blank PO
                   , p_supply_source_line_id    => get_po_shipment_rel_rec.line_location_id --IN NUMBER
                   , p_project_id               => get_pt_po_shipment_rec.project_id--IN NUMBER default null
                   , p_task_id                  => get_pt_po_shipment_rec.task_id --IN NUMBER default null
                   , x_qty_available_to_reserve => l_qty_avail_to_reserve --OUT      NOCOPY NUMBER
                  , x_qty_available            => l_qty_avail  --OUT      NOCOPY NUMBER
                  );

                OPEN  get_po_res_qty
                  (get_po_shipment_rel_rec.po_header_id
                   ,get_po_shipment_rel_rec.line_location_id
                   ,get_pt_po_shipment_rec.project_id
                   ,get_pt_po_shipment_rec.task_id);
                FETCH get_po_res_qty INTO get_po_res_qty_rec ;
                CLOSE get_po_res_qty ;

                IF g_debug= C_Debug_Enabled THEN
                   mydebug('Qty available: '|| l_qty_avail, c_api_name,9);
                   mydebug('Qty available to reserve: '|| l_qty_avail_to_reserve, c_api_name,9);
                   mydebug('Qty reserved qty: '|| get_po_res_qty_rec.primary_reservation_quantity, c_api_name,9);
                END IF;

                IF  get_po_res_qty_rec.primary_reservation_quantity > 0 THEN
                   /* uom_conversion(get_po_res_qty_rec.reservation_uom_code
                   ,get_po_res_qty_rec.primary_uom_code
                     ,l_qty_avail_to_reserve
                     ,get_po_shipment_rel_rec.po_line_id
                     ,l_reservation_quantity
                     ,l_po_primary_qty);*/
                     IF (get_po_res_qty_rec.primary_reservation_quantity > l_qty_avail) THEN
                        -- calling reduce_reservation API get_pt_po_shipment_rec
                        l_mtl_maint_rsv_rec.action := 0;--supply is reduced
                        l_sort_by_criteria := inv_reservation_global.g_query_demand_ship_date_desc;
                        l_mtl_maint_rsv_rec.organization_id
                          := get_po_shipment_rel_rec.ship_to_organization_id;
                        l_mtl_maint_rsv_rec.inventory_item_id := get_po_shipment_rel_rec.item_id;

                        l_mtl_maint_rsv_rec.supply_source_type_id:= inv_reservation_global.g_source_type_po;
                        l_mtl_maint_rsv_rec.supply_source_header_id := get_po_shipment_rel_rec.po_header_id;
                        l_mtl_maint_rsv_rec.supply_source_line_id := get_po_shipment_rel_rec.line_location_id;
                        --        l_mtl_maint_rsv_rec.supply_source_line_detail := NULL;
                        --l_mtl_maint_rsv_rec.expected_quantity :=
                        --        get_po_res_qty_rec.primary_reservation_quantity - l_qty_avail_to_reserve;
                        l_mtl_maint_rsv_rec.expected_quantity := l_qty_avail;
                        l_mtl_maint_rsv_rec.expected_quantity_uom := get_po_res_qty_rec.primary_uom_code;
                        l_mtl_maint_rsv_rec.project_id := get_pt_po_shipment_rec.project_id;
                        l_mtl_maint_rsv_rec.task_id := get_pt_po_shipment_rec.task_id;

                        reduce_reservation
                          (
                            p_API_Version_Number  => 1.0
                            , p_Init_Msg_Lst        => fnd_api.g_false
                            , x_Return_Status       => l_return_status
                            , x_Msg_Count           => x_msg_count
                            , x_Msg_Data            => x_msg_data
                            , p_Mtl_Maintain_Rsv_rec=> l_mtl_maint_rsv_rec
                            , p_Delete_Flag         => 'N'
                            , p_Sort_By_Criteria    => NULL
                            , x_Quantity_Modified   => l_quantity_modified);

                        IF g_debug= C_Debug_Enabled THEN
                           mydebug ('Return Status after calling reduce reservations: '|| l_return_status, c_api_name,9);
                        END IF;

                        IF l_return_status = fnd_api.g_ret_sts_error THEN

                           IF g_debug= C_Debug_Enabled THEN
                              mydebug('Raising expected error'|| l_return_status, c_api_name,9);
                           END IF;
                           RAISE fnd_api.g_exc_error;

                         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN

                           IF g_debug= C_Debug_Enabled THEN
                              mydebug('Rasing Unexpected error'|| l_return_status, c_api_name,9);
                           END IF;
                           RAISE fnd_api.g_exc_unexpected_error;

                        END IF;

                     END IF;
                END IF;

             END LOOP;
             CLOSE  get_proj_task_of_po_shipment;
          END IF;
      END LOOP;
      CLOSE get_po_shipment_for_release;

   ELSIF upper(p_action) = 'REMOVE_REQ_SUPPLY' THEN
           OPEN get_req_hdr_lines (p_header_id);
           --
           IF g_debug= C_Debug_Enabled THEN
              mydebug ('Remove req supply. req header:'|| p_header_id ,c_api_name,9);
           END IF;
           LOOP
              --
              FETCH get_req_hdr_lines INTO get_req_hdr_lines_rec;
              EXIT WHEN get_req_hdr_lines%NOTFOUND;

              IF g_debug= C_Debug_Enabled THEN
                 mydebug ('Removing req supply for req line :'|| get_req_hdr_lines_rec.requisition_line_id , c_api_name,9);
              END IF;

              IF Upper(get_req_hdr_lines_rec.source_type_code) = 'INVENTORY' THEN
                 l_supply_source_type_id := inv_reservation_global.g_source_type_internal_req;
               else
                 l_supply_source_type_id := inv_reservation_global.g_source_type_req;
              END IF;

              IF EXISTS_RESERVATION(p_supply_source_header_id        => p_header_id,
                                 p_supply_source_line_id        => get_req_hdr_lines_rec.requisition_line_id,
                                 p_supply_source_type_id        => l_supply_source_type_id) THEN
                DELETE_RES
                (p_supply_source_header_id  => p_header_id
                 ,p_supply_source_line_id    => get_req_hdr_lines_rec.requisition_line_id
                 ,p_supply_source_type_id    => l_supply_source_type_id
                 ,x_msg_count                => x_msg_count
                 ,x_msg_data                 => x_msg_data
                 ,x_return_status            => l_return_status);
              END IF;
           END LOOP; --get_req_hdr_lines

    ELSIF upper(p_action) = 'REMOVE_REQ_LINE_SUPPLY' THEN
                 --delete the reservation on the req
                 --
           IF g_debug= C_Debug_Enabled THEN
              mydebug ('Remove req line supply. req line:'|| p_line_id ,c_api_name,9);
           END IF;

           BEGIN
              SELECT source_type_code INTO l_source_type_code FROM
                po_requisition_lines_all WHERE requisition_line_id = p_line_id;

           EXCEPTION
              WHEN no_data_found THEN
                 IF g_debug= C_Debug_Enabled THEN
                    mydebug ('Cannot find the source type code for req line' || p_line_id,c_api_name,9);
                 END IF;
           END;


           IF Upper(l_source_type_code) = 'INVENTORY' THEN
              l_supply_source_type_id := inv_reservation_global.g_source_type_internal_req;
            else
              l_supply_source_type_id := inv_reservation_global.g_source_type_req;
           END IF;

           IF EXISTS_RESERVATION(p_supply_source_line_id          => p_line_id,
                                 p_supply_source_type_id          => l_supply_source_type_id) THEN
             DELETE_RES
             (p_supply_source_line_id   => p_line_id
              ,p_supply_source_type_id   => l_supply_source_type_id
              ,x_msg_count               => x_msg_count
              ,x_msg_data                => x_msg_data
              ,x_return_status           => l_return_status);
           END IF;

   ELSIF upper(p_action) = 'CANCEL_PO_SUPPLY' THEN

                 -- If Reservation Exists, then delete them and never transfer back to requistion
                 -- since when PO is cancelled, associated req got
                 -- cancelled too.
        IF g_debug= C_Debug_Enabled THEN
           mydebug ('Cancel PO supply. Supply header: '|| p_header_id ,c_api_name,9);
        END IF;
        IF EXISTS_RESERVATION(p_supply_source_header_id          => p_header_id) THEN

            --reservation should be deleted
            OPEN get_po_shipment(p_header_id);
            LOOP

              FETCH get_po_shipment INTO get_po_shipment_rec;
              EXIT WHEN get_po_shipment%NOTFOUND;

              --DELETE_RES (p_supply_source_header_id => p_header_id
              --        ,p_supply_source_line_id   => get_po_shipment_rec.line_location_id
              --        ,p_supply_source_type_id   => inv_reservation_global.g_source_type_po
              --           ,x_msg_count               => x_msg_count
              --           ,x_msg_data                => x_msg_data
              --           ,x_return_status           => l_return_status);
              IF g_debug= C_Debug_Enabled THEN
                 mydebug ('Removing po line location. po line loc.:'|| get_po_shipment_rec.line_location_id,c_api_name,9);
              END IF;
              l_delete_flag := 'Y';
              l_sort_by_criteria := inv_reservation_global.g_query_demand_ship_date_desc;
              l_mtl_maint_rsv_rec.action := 0;--supply is reduced
              l_mtl_maint_rsv_rec.organization_id :=
                get_po_shipment_rec.ship_to_organization_id;
              l_mtl_maint_rsv_rec.inventory_item_id :=
                get_po_shipment_rec.item_id;
              l_mtl_maint_rsv_rec.supply_source_type_id:= inv_reservation_global.g_source_type_po;
              l_mtl_maint_rsv_rec.supply_source_header_id := p_header_id;
              l_mtl_maint_rsv_rec.supply_source_line_id :=
                get_po_shipment_rec.line_location_id;
             -- l_mtl_maint_rsv_rec.supply_source_line_detail := NULL;

              reduce_reservation
                (
                  p_api_version_number     => 1.0
                  , p_init_msg_lst           => fnd_api.g_false
                  , x_return_status          => l_return_status
                  , x_msg_count              => x_msg_count
                  , x_msg_data               => x_msg_data
                  , p_mtl_maintain_rsv_rec   => l_mtl_maint_rsv_rec
                  , p_delete_flag            => l_delete_flag
                  , p_sort_by_criteria       => l_sort_by_criteria
                  , x_quantity_modified      => l_quantity_modified);
              IF g_debug= C_Debug_Enabled THEN
                 mydebug ('Return Status after calling reduce reservations: '|| l_return_status, c_api_name,9);
              END IF;

              IF l_return_status = fnd_api.g_ret_sts_error THEN

                 IF g_debug= C_Debug_Enabled THEN
                    mydebug('Raising expected error'|| l_return_status, c_api_name,9);
                 END IF;
                 RAISE fnd_api.g_exc_error;

               ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN

                 IF g_debug= C_Debug_Enabled THEN
                    mydebug('Rasing Unexpected error'|| l_return_status, c_api_name,9);
                 END IF;
                 RAISE fnd_api.g_exc_unexpected_error;

              END IF;
            END LOOP; --get_distr

       END IF; --Reservation Exists

   ELSIF upper(p_action) = 'CANCEL_PO_LINE' THEN
       OPEN  get_po_header_id_line (p_line_id);
       FETCH get_po_header_id_line INTO l_po_header_id;
       CLOSE get_po_header_id_line;

       IF g_debug= C_Debug_Enabled THEN
          mydebug ('Cancel PO line. PO line.: '|| p_line_id,c_api_name,9);
       END IF;
       -- If Reservation Exists for the PO, then proceed to check whether
       -- the existing Reservation needs to be transferred to Requisition
       -- Since Reservation is on the PO and PO Distribution, PO Reservation is
       -- checked even when the Line is Cancelled
       IF EXISTS_RESERVATION(p_supply_source_header_id        => l_po_header_id) THEN

           --delete the reservation
           OPEN get_line_loc_for_po_line(p_line_id);
           LOOP
               FETCH get_line_loc_for_po_line INTO get_line_loc_rec;
               EXIT WHEN get_line_loc_for_po_line%NOTFOUND;

               --    DELETE_RES (p_supply_source_header_id => l_po_header_id
               --             ,p_supply_source_line_id   => get_distr_rec.line_location_id
               --           ,p_supply_source_type_id   => inv_reservation_global.g_source_type_po
               --         ,x_msg_count               => x_msg_count
               --       ,x_msg_data                => x_msg_data
               --     ,x_return_status           => l_return_status);
               IF g_debug= C_Debug_Enabled THEN
                  mydebug ('Cancel line.Removing po line location. po line loc.:'|| get_line_loc_rec.line_location_id,c_api_name,9);
               END IF;

               l_delete_flag := 'Y';
               l_sort_by_criteria := inv_reservation_global.g_query_demand_ship_date_desc;
               l_mtl_maint_rsv_rec.action := 0;--supply is reduced
               l_mtl_maint_rsv_rec.organization_id :=
                 get_line_loc_rec.ship_to_organization_id;
               l_mtl_maint_rsv_rec.inventory_item_id :=
                 get_line_loc_rec.item_id;
               l_mtl_maint_rsv_rec.supply_source_type_id:= inv_reservation_global.g_source_type_po;
               l_mtl_maint_rsv_rec.supply_source_header_id := l_po_header_id;
               l_mtl_maint_rsv_rec.supply_source_line_id :=
                 get_line_loc_rec.line_location_id;
               -- l_mtl_maint_rsv_rec.supply_source_line_detail := NULL;

               reduce_reservation
                 (
                   p_api_version_number     => 1.0
                   , p_init_msg_lst           => fnd_api.g_false
                   , x_return_status          => l_return_status
                   , x_msg_count              => x_msg_count
                   , x_msg_data               => x_msg_data
                   , p_mtl_maintain_rsv_rec   => l_mtl_maint_rsv_rec
                   , p_delete_flag            => l_delete_flag
                   , p_sort_by_criteria       => l_sort_by_criteria
                   , x_quantity_modified      => l_quantity_modified);
               IF g_debug= C_Debug_Enabled THEN
                  mydebug ('Return Status after calling reduce reservations: '|| l_return_status, c_api_name,9);
               END IF;

               IF l_return_status = fnd_api.g_ret_sts_error THEN

                  IF g_debug= C_Debug_Enabled THEN
                     mydebug('Raising expected error'|| l_return_status, c_api_name,9);
                  END IF;
                  RAISE fnd_api.g_exc_error;

                ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN

                  IF g_debug= C_Debug_Enabled THEN
                     mydebug('Rasing Unexpected error'|| l_return_status, c_api_name,9);
                  END IF;
                  RAISE fnd_api.g_exc_unexpected_error;

               END IF;
           END LOOP;
       END IF; --Reservation Exists

   ELSIF upper(p_action) = 'CANCEL_PO_SHIPMENT' THEN
      --OPEN  get_po_header_id_shipment(p_line_location_id);
      --FETCH get_po_header_id_shipment INTO l_po_header_id;
      --CLOSE get_po_header_id_shipment;

     IF g_debug= C_Debug_Enabled THEN
        mydebug ('Cancel PO Shipment.Removing po line location. po line loc.:'|| p_line_location_id,c_api_name,9);
     END IF;
     -- If Reservation Exists for the PO, then proceed to check whether
     -- the existing Reservation needs to be transferred to Requisition
     -- Since Reservation is on the PO and PO Distribution, PO Reservation is
     -- checked even when the Line is Cancelled
     IF exists_reservation(p_supply_source_line_id => p_line_location_id) THEN

        -- OPEN get_distr_for_po_shipment(p_line_location_id);
        --
        --  LOOP
        --      FETCH get_distr_for_po_shipment INTO get_distr_rec;
        --      EXIT WHEN get_distr_for_po_shipment%NOTFOUND;
        --
        --      DELETE_RES (p_supply_source_header_id  => l_po_header_id
        --                 ,p_supply_source_line_id    => get_distr_rec.line_location_id
        --                 ,p_supply_source_type_id    => inv_reservation_global.g_source_type_po--
        --                 ,x_msg_count                => x_msg_count
        ----                 ,x_msg_data                 => x_msg_data
        --                 ,x_return_status            => l_return_status);
        --
         --  END LOOP; -- get_distr

        OPEN get_line_loc_for_po_shipment(p_line_location_id);
        FETCH get_line_loc_for_po_shipment INTO get_line_loc_rec;
        CLOSE get_line_loc_for_po_shipment;

        l_delete_flag := 'Y';
        l_sort_by_criteria := inv_reservation_global.g_query_demand_ship_date_desc;
        l_mtl_maint_rsv_rec.action := 0;--supply is reduced
        l_mtl_maint_rsv_rec.organization_id := get_line_loc_rec.ship_to_organization_id;
        l_mtl_maint_rsv_rec.inventory_item_id := get_line_loc_rec.item_id;
        l_mtl_maint_rsv_rec.supply_source_type_id:= inv_reservation_global.g_source_type_po;
        l_mtl_maint_rsv_rec.supply_source_header_id := get_line_loc_rec.po_header_id;
        l_mtl_maint_rsv_rec.supply_source_line_id := p_line_location_id;
        -- l_mtl_maint_rsv_rec.supply_source_line_detail := NULL;

        reduce_reservation
          (
            p_api_version_number     => 1.0
            , p_init_msg_lst           => fnd_api.g_false
            , x_return_status          => l_return_status
            , x_msg_count              => x_msg_count
            , x_msg_data               => x_msg_data
            , p_mtl_maintain_rsv_rec   => l_mtl_maint_rsv_rec
            , p_delete_flag            => l_delete_flag
            , p_sort_by_criteria       => l_sort_by_criteria
            , x_quantity_modified      => l_quantity_modified);
        IF g_debug= C_Debug_Enabled THEN
           mydebug ('Return Status after calling reduce reservations: '|| l_return_status, c_api_name,9);
        END IF;

        IF l_return_status = fnd_api.g_ret_sts_error THEN

           IF g_debug= C_Debug_Enabled THEN
              mydebug('Raising expected error'|| l_return_status, c_api_name,9);
           END IF;
           RAISE fnd_api.g_exc_error;

         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN

           IF g_debug= C_Debug_Enabled THEN
              mydebug('Rasing Unexpected error'|| l_return_status, c_api_name,9);
           END IF;
           RAISE fnd_api.g_exc_unexpected_error;

        END IF;

     END IF; --Reservation Exists

   ELSIF upper(p_action) = 'CANCEL_BLANKET_RELEASE' THEN
       OPEN  get_po_header_id_release(p_header_id); -- p_header_id is po_release_id
       FETCH get_po_header_id_release INTO l_po_header_id;
       CLOSE get_po_header_id_release;

       IF g_debug= C_Debug_Enabled THEN
          mydebug ('Cancel Blanket Release. po header id. :'|| l_po_header_id,c_api_name,9);
       END IF;
       -- If Reservation Exists for the PO, then proceed to check whether
       -- the existing Reservation needs to be transferred to Requisition
       -- Since Reservation is on the PO and PO Distribution, PO Reservation is
       -- checked even when the Release is Cancelled
       --
       IF exists_reservation(p_supply_source_header_id  => l_po_header_id) THEN

          --delete the reservation
          -- OPEN get_distr_for_po_release(p_header_id);
          --LOOP
          --  FETCH get_distr_for_po_release INTO get_distr_rec;
          -- EXIT WHEN get_distr_for_po_release%NOTFOUND;

          --      DELETE_RES ( p_supply_source_header_id => l_po_header_id
          --                ,p_supply_source_line_id   => get_distr_rec.line_location_id
          --              ,p_supply_source_type_id   => inv_reservation_global.g_source_type_po
          --            ,x_msg_count               => x_msg_count
          --          ,x_msg_data                => x_msg_data
          --        ,x_return_status           => l_return_status);

          --END LOOP; --get_distr_for_po_release

          --reservation should be deleted
          --bug8578392 change get_po_shipment to get_po_shipment_for_release
          OPEN get_po_shipment_for_release(p_header_id);
          LOOP
               FETCH get_po_shipment_for_release INTO get_po_shipment_rel_rec;
               EXIT WHEN get_po_shipment_for_release%NOTFOUND;

               --DELETE_RES (p_supply_source_header_id => p_header_id
               --        ,p_supply_source_line_id   => get_po_shipment_rec.line_location_id
               --        ,p_supply_source_type_id   => inv_reservation_global.g_source_type_po
               --           ,x_msg_count               => x_msg_count
               --           ,x_msg_data                => x_msg_data
               --           ,x_return_status           => l_return_status);
               IF g_debug= C_Debug_Enabled THEN
                  mydebug ('Removing po line location. po line loc.:'|| get_po_shipment_rel_rec.line_location_id,c_api_name,9);
               END IF;

              l_delete_flag := 'Y';
              l_sort_by_criteria := inv_reservation_global.g_query_demand_ship_date_desc;
              l_mtl_maint_rsv_rec.action := 0;--supply is reduced
              --bug8578392 change get_po_shipment_rec.ship_to_organization_id to get_po_shipment_rel_rec.ship_to_organization_id
              l_mtl_maint_rsv_rec.organization_id := get_po_shipment_rel_rec.ship_to_organization_id;
              --bug8578392 change get_po_shipment_rec.item_id to get_po_shipment_rel_rec.item_id
              l_mtl_maint_rsv_rec.inventory_item_id := get_po_shipment_rel_rec.item_id;
              l_mtl_maint_rsv_rec.supply_source_type_id:= inv_reservation_global.g_source_type_po;
              l_mtl_maint_rsv_rec.supply_source_header_id := l_po_header_id;
              --bug8578392 change get_po_shipment_rec.line_location_id to get_po_shipment_rel_rec.line_location_id
              l_mtl_maint_rsv_rec.supply_source_line_id := get_po_shipment_rel_rec.line_location_id;
              -- l_mtl_maint_rsv_rec.supply_source_line_detail := NULL;

              reduce_reservation
                (
                  p_api_version_number     => 1.0
                  , p_init_msg_lst           => fnd_api.g_false
                  , x_return_status          => l_return_status
                  , x_msg_count              => x_msg_count
                  , x_msg_data               => x_msg_data
                  , p_mtl_maintain_rsv_rec   => l_mtl_maint_rsv_rec
                  , p_delete_flag            => l_delete_flag
                  , p_sort_by_criteria       => l_sort_by_criteria
                  , x_quantity_modified      => l_quantity_modified);
              IF g_debug= C_Debug_Enabled THEN
                 mydebug ('Return Status after calling reduce reservations: '|| l_return_status, c_api_name,9);
              END IF;

              IF l_return_status = fnd_api.g_ret_sts_error THEN

                 IF g_debug= C_Debug_Enabled THEN
                    mydebug('Raising expected error'|| l_return_status, c_api_name,9);
                 END IF;
                 RAISE fnd_api.g_exc_error;

               ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN

                 IF g_debug= C_Debug_Enabled THEN
                    mydebug('Rasing Unexpected error'|| l_return_status, c_api_name,9);
                 END IF;
                 RAISE fnd_api.g_exc_unexpected_error;

              END IF;
            END LOOP; --get_distr

       END IF; --Reservation Exists
--
   ELSIF upper(p_action) = 'CANCEL_BLANKET_SHIPMENT' THEN

      -- OPEN  get_po_header_id_shipment(p_line_location_id);
      -- FETCH get_po_header_id_shipment INTO l_po_header_id;
      -- CLOSE get_po_header_id_shipment;

      -- If Reservation Exists for the PO, then proceed to check whether
      -- the existing Reservation needs to be transferred to Requisition
      -- Since Reservation is on the PO and PO Distribution, PO Reservation is
      -- checked even when the Line is Cancelled
     IF g_debug= C_Debug_Enabled THEN
        mydebug ('Cancel Blanket Shipment. po line location id. :'|| p_line_location_id,c_api_name,9);
     END IF;

     IF exists_reservation(p_supply_source_line_id => p_line_location_id)  THEN

        --        OPEN get_distr_for_po_shipment(p_line_location_id);
        --        LOOP
        --           FETCH get_distr_for_po_shipment INTO get_distr_rec;
        --               EXIT WHEN get_distr_for_po_shipment%NOTFOUND;

        --               DELETE_RES (p_supply_source_header_id  => l_po_header_id
        --                          ,p_supply_source_line_id    => get_distr_rec.line_location_id
        --                          ,p_supply_source_type_id    => inv_reservation_global.g_source_type_po
        --                          ,x_msg_count                => x_msg_count
        --                          ,x_msg_data                 => x_msg_data
        --                          ,x_return_status            => l_return_status);
        --
        --           END LOOP; -- get_distr

        OPEN get_line_loc_for_po_shipment(p_line_location_id);
        FETCH get_line_loc_for_po_shipment INTO get_line_loc_rec;
        CLOSE get_line_loc_for_po_shipment;

        l_delete_flag := 'Y';
        l_sort_by_criteria := inv_reservation_global.g_query_demand_ship_date_desc;
        l_mtl_maint_rsv_rec.action := 0;--supply is reduced
        l_mtl_maint_rsv_rec.organization_id :=
          get_line_loc_rec.ship_to_organization_id;
        l_mtl_maint_rsv_rec.inventory_item_id :=
          get_line_loc_rec.item_id;
        l_mtl_maint_rsv_rec.supply_source_type_id:= inv_reservation_global.g_source_type_po;
        l_mtl_maint_rsv_rec.supply_source_header_id := get_line_loc_rec.po_header_id;
        l_mtl_maint_rsv_rec.supply_source_line_id := p_line_location_id;
        -- l_mtl_maint_rsv_rec.supply_source_line_detail := NULL;

        reduce_reservation
          (
            p_api_version_number     => 1.0
            , p_init_msg_lst           => fnd_api.g_false
            , x_return_status          => l_return_status
            , x_msg_count              => x_msg_count
            , x_msg_data               => x_msg_data
            , p_mtl_maintain_rsv_rec   => l_mtl_maint_rsv_rec
            , p_delete_flag            => l_delete_flag
            , p_sort_by_criteria       => l_sort_by_criteria
            , x_quantity_modified      => l_quantity_modified);
        IF g_debug= C_Debug_Enabled THEN
           mydebug ('Return Status after calling reduce reservations: '|| l_return_status, c_api_name,9);
        END IF;

        IF l_return_status = fnd_api.g_ret_sts_error THEN

           IF g_debug= C_Debug_Enabled THEN
              mydebug('Raising expected error'|| l_return_status, c_api_name,9);
           END IF;
           RAISE fnd_api.g_exc_error;

         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN

           IF g_debug= C_Debug_Enabled THEN
              mydebug('Rasing Unexpected error'|| l_return_status, c_api_name,9);
           END IF;
           RAISE fnd_api.g_exc_unexpected_error;

        END IF;

     END IF; --Reservation Exists

     -- Bug 5253916: For update so quantity

   ELSIF upper(p_action) = 'UPDATE_SO_QUANTITY' THEN
     --reduce the reservation on the req by the ordered quantity
      IF g_debug= C_Debug_Enabled THEN
         mydebug ('Inside update so qty. req line:'|| p_line_id ,c_api_name,9);
      END IF;

      -- Check to see if there are any reservations for this requsition
      -- line.

      BEGIN
         SELECT Nvl(SUM(primary_reservation_quantity),0) INTO
           l_primary_res_qty FROM mtl_reservations
           WHERE supply_source_type_id =
           inv_reservation_global.g_source_type_internal_req AND
           supply_source_header_id = p_header_id AND
           supply_source_line_id = p_line_id;
      EXCEPTION
         WHEN no_data_found THEN
        IF g_debug= C_Debug_Enabled THEN
           mydebug ('No reservation records found for req line id. req line:'|| p_line_id ,c_api_name,9);
        END IF;
      END;

      IF l_primary_res_qty > 0 THEN
           -- reservations found
           -- get the req line information.
           BEGIN
             --bug #5498904 replaced org_id with destination_organization_id
              SELECT destination_organization_id, item_id, unit_meas_lookup_code, quantity INTO
            l_organization_id,
            l_inventory_item_id,
            l_req_unit_meas, l_req_qty  FROM
            po_requisition_lines_all WHERE requisition_line_id = p_line_id;
           EXCEPTION
              WHEN no_data_found THEN
                IF g_debug= C_Debug_Enabled THEN
                    mydebug ('No records found for req line id. req line:'|| p_line_id ,c_api_name,9);
                END IF;
           END;

           IF (p_ordered_quantity = 0) THEN
              -- delete all reservations for that req line
              -- calling reduce_reservation API
              l_delete_flag := 'Y';
              l_sort_by_criteria := inv_reservation_global.g_query_demand_ship_date_desc;
              l_mtl_maint_rsv_rec.action := 0;--supply is reduced
              l_mtl_maint_rsv_rec.organization_id := l_organization_id;
              l_mtl_maint_rsv_rec.inventory_item_id := l_inventory_item_id;
             --bug #5498904 populated l_mtl_maint_rsv_rec.supply_source_type_id
              l_mtl_maint_rsv_rec.supply_source_type_id := inv_reservation_global.g_source_type_internal_req;
              l_supply_source_type_id := inv_reservation_global.g_source_type_internal_req;
              l_mtl_maint_rsv_rec.supply_source_header_id := p_header_id;
              l_mtl_maint_rsv_rec.supply_source_line_id := p_line_id;
              -- l_mtl_maint_rsv_rec.supply_source_line_detail := NULL;

              reduce_reservation
                (
                  p_api_version_number       => 1.0
                  , p_init_msg_lst           => fnd_api.g_false
                  , x_return_status          => l_return_status
                  , x_msg_count              => x_msg_count
                  , x_msg_data               => x_msg_data
                  , p_mtl_maintain_rsv_rec   => l_mtl_maint_rsv_rec
                  , p_delete_flag            => l_delete_flag
                  , p_sort_by_criteria       => l_sort_by_criteria
                  , x_quantity_modified      => l_quantity_modified);
              IF g_debug= C_Debug_Enabled THEN
                 mydebug ('Return Status after calling reduce reservations: '|| l_return_status, c_api_name,9);
                 mydebug ('Expected qty: '|| p_ordered_quantity, c_api_name,9);
                 mydebug ('Modified qty: '|| l_quantity_modified, c_api_name,9);
              END IF;

              IF l_return_status = fnd_api.g_ret_sts_error THEN

                 IF g_debug= C_Debug_Enabled THEN
                    mydebug('Raising expected error'|| l_return_status, c_api_name,9);
                 END IF;
                 RAISE fnd_api.g_exc_error;

              ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN

                 IF g_debug= C_Debug_Enabled THEN
                    mydebug('Rasing Unexpected error'|| l_return_status, c_api_name,9);
                 END IF;
                 RAISE fnd_api.g_exc_unexpected_error;

              END IF;

           ELSE
              -- reduce the reservations to the ordered qty
              -- Set the source type as internal req

              l_mtl_maint_rsv_rec.action := 0;--supply is reduced
              l_sort_by_criteria := inv_reservation_global.g_query_demand_ship_date_desc;
              l_mtl_maint_rsv_rec.organization_id := l_organization_id;
              l_mtl_maint_rsv_rec.inventory_item_id := l_inventory_item_id;
              --bug #5498904 populated l_mtl_maint_rsv_rec.supply_source_type_id
              l_mtl_maint_rsv_rec.supply_source_type_id := inv_reservation_global.g_source_type_internal_req;
              l_supply_source_type_id := inv_reservation_global.g_source_type_internal_req;
              l_mtl_maint_rsv_rec.supply_source_header_id := p_header_id;
              l_mtl_maint_rsv_rec.supply_source_line_id := p_line_id;
              -- l_mtl_maint_rsv_rec.supply_source_line_detail := NULL;
              l_mtl_maint_rsv_rec.expected_quantity := p_ordered_quantity;
              l_mtl_maint_rsv_rec.expected_quantity_uom := p_ordered_uom;

              reduce_reservation
                (
                  p_api_version_number     => 1.0
                  , p_init_msg_lst           => fnd_api.g_false
                  , x_return_status          => l_return_status
                  , x_msg_count              => x_msg_count
                  , x_msg_data               => x_msg_data
                  , p_mtl_maintain_rsv_rec   => l_mtl_maint_rsv_rec
                  , p_delete_flag            => 'N'
                  , p_sort_by_criteria       => l_sort_by_criteria
                  , x_quantity_modified      => l_quantity_modified);

              IF g_debug= C_Debug_Enabled THEN
                 mydebug ('Return Status after calling reduce reservations: '|| l_return_status, c_api_name,9);
                 mydebug ('Expected qty: '|| p_ordered_quantity, c_api_name,9);
                   mydebug ('Modified qty: '|| l_quantity_modified, c_api_name,9);
              END IF;

              IF l_return_status = fnd_api.g_ret_sts_error THEN

                 IF g_debug= C_Debug_Enabled THEN
                    mydebug('Raising expected error'|| l_return_status, c_api_name,9);
                 END IF;
                 RAISE fnd_api.g_exc_error;

               ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN

                 IF g_debug= C_Debug_Enabled THEN
                    mydebug('Rasing Unexpected error'|| l_return_status, c_api_name,9);
                 END IF;
                 RAISE fnd_api.g_exc_unexpected_error;

              END IF;
           END IF; -- ordered qty

      END IF; -- reservation records found
    ELSE
          -- all other actions do nothing ....for now
          NULL;

   END IF;


   If g_debug= C_Debug_Enabled Then
          l_Fnd_Log_Message := 'l_return_status: '|| l_return_status;
          mydebug(l_Fnd_Log_Message,c_api_name,9);
   End If;

   x_return_status := l_return_status;

   If x_return_status = fnd_api.g_ret_sts_success THEN
      l_Fnd_Log_message := 'Calling maintain_reservation API was successful ';
      -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );
      IF G_debug= C_Debug_Enabled THEN
         mydebug(l_Fnd_Log_Message, c_api_name,9);
      END IF;
   else
      l_Fnd_Log_message := 'Error while calling maintain_reservation API ';
      -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );
      IF G_debug= C_Debug_Enabled THEN
         mydebug(l_Fnd_Log_Message, c_api_name,9);
      END IF;
   end if;

   -- Call fnd_log api at the end of the API
   l_Fnd_Log_message := 'At the end of procedure :';
   -- Fnd_Log_Debug(Fnd_Log.Level_Procedure,C_Module_name, l_Fnd_Log_Message );

   IF G_debug= C_Debug_Enabled THEN
        mydebug(l_Fnd_Log_Message, c_api_name,9);
   END IF;

--
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
       x_return_status := fnd_api.g_ret_sts_error;

       --  Get message count and data
       fnd_msg_pub.count_and_get
         (  p_count => x_msg_count
          , p_data  => x_msg_data
          );

        -- Call fnd_log api at the end of the API
        l_Fnd_Log_message := 'When Expected exception raised for procedure :' ;
        -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );

        -- Log message in trace file
        IF G_debug= C_Debug_Enabled THEN
            mydebug(l_Fnd_Log_Message,c_api_name,9);
        END IF;

        -- Get messages from stack and log them in fnd tables
        If X_Msg_Count = 1 Then
           -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, X_Msg_Data );
           -- Log message in trace file
           If G_debug= C_Debug_Enabled THEN
             mydebug(l_Fnd_Log_Message,c_api_name,9);
           End If;
        Elsif x_msg_count > 1 Then
            For I In 1..X_Msg_Count Loop
              FND_MSG_PUB.Get
               (p_msg_index     => i,
                p_encoded       => 'F',
                p_data          => l_Fnd_Log_Message,
                p_msg_index_out => l_msg_index_out );

               -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );

               -- Log message in trace file
               IF G_debug= C_Debug_Enabled THEN
                   mydebug(l_Fnd_Log_Message,c_api_name,9);
               END IF;
            End Loop ;
        End If;

    WHEN fnd_api.g_exc_unexpected_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         --  Get message count and data
         fnd_msg_pub.count_and_get
           (  p_count  => x_msg_count
            , p_data   => x_msg_data
             );
         -- Call fnd_log api at the end of the API
         l_Fnd_Log_message := 'When unexpected exception raised for procedure :';
         -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );

         -- Log message in trace file
         IF G_debug= C_Debug_Enabled THEN
             mydebug(l_Fnd_Log_Message,c_api_name,9);
         END IF;

         -- Get messages from stack and log them in fnd tables
         If X_Msg_Count = 1 Then
           -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, X_Msg_Data );

           -- Log message in trace file
           IF G_debug= C_Debug_Enabled THEN
             mydebug(l_Fnd_Log_Message,c_api_name,9);
           END IF;
         Elsif X_Msg_Count > 1 Then
            For I In 1..X_Msg_Count Loop
              FND_MSG_PUB.Get
               (p_msg_index     => i,
                p_encoded       => 'F',
                p_data          => l_Fnd_Log_Message,
                p_msg_index_out => l_msg_index_out );

               -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );

               -- Log message in trace file
               IF G_debug= C_Debug_Enabled THEN
                   mydebug(l_Fnd_Log_Message,c_api_name,9);
               END IF;
            End Loop ;
         End If;

  WHEN OTHERS THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error ;

       IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
          fnd_msg_pub.add_exc_msg
            (  g_pkg_name
             , c_api_name
             );
       END IF;

       --  Get message count and data
       fnd_msg_pub.count_and_get
         (  p_count  => x_msg_count
          , p_data   => x_msg_data
          );

       -- Call fnd_log api at the end of the API
       l_Fnd_Log_message := 'When Others exception raised for procedure :' || G_Pkg_Name || '.' || C_API_Name ;
       -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );

       -- Log message in trace file
       IF G_debug= C_Debug_Enabled THEN
           mydebug(l_Fnd_Log_Message,c_api_name,9);
       END IF;

       -- Get messages from stack and log them in fnd tables
       If X_Msg_Count = 1 Then
         -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, X_Msg_Data );

         -- Log message in trace file
         If G_debug= C_Debug_Enabled Then
            mydebug(l_Fnd_Log_Message,c_api_name,9);
          End If;
       Elsif X_Msg_Count > 1 Then
           For I In 1..X_Msg_Count Loop
             FND_MSG_PUB.Get
              (p_msg_index     => i,
               p_encoded       => 'F',
               p_data          => l_Fnd_Log_Message,
               p_msg_index_out => l_msg_index_out );

              -- Fnd_Log_Debug(fnd_log.Level_Error,C_Module_name, l_Fnd_Log_Message );

              -- Log message in trace file
              IF G_debug= C_Debug_Enabled THEN
                  mydebug(l_Fnd_Log_Message,c_api_name,9);
              END IF;
           End Loop ;
      End If;

END MAINTAIN_RESERVATION;


END INV_MAINTAIN_RESERVATION_PUB;

/
