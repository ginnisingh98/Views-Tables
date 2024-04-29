--------------------------------------------------------
--  DDL for Package Body GML_BATCH_OM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_BATCH_OM_UTIL" AS
/*  $Header: GMLOUTLB.pls 120.0 2005/05/25 16:44:49 appldev noship $
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIURSVS.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains private utilities  relating to OPM            |
 |     reservation.                                                        |
 |                                                                         |
 |                                                                         |
 | HISTORY                                                                 |
 |     Aug-18-2003  Liping Gao Created                                     |
 +=========================================================================+
  API Name  : GML_BATCH_OM_UTIL
  Type      : Private
  Function  : This package contains Private Utilities procedures used to
              OPM reservation for a batch.
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

*/
 G_PKG_NAME      CONSTANT  VARCHAR2(30):='GML_BATCH_OM_UTIL';

 PROCEDURE query_reservation
 (
    P_So_line_rec            IN    GML_BATCH_OM_UTIL.so_line_rec
  , P_Batch_line_rec         IN    GML_BATCH_OM_UTIL.batch_line_rec
  , P_Gme_om_reservation_rec IN    OUT NOCOPY GML_BATCH_OM_UTIL.gme_om_reservation_rec
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 ) IS
  l_res_rec gml_batch_so_reservations%rowtype;
 BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   GMI_RESERVATION_UTIL.Println(' In query reservation');
   GMI_RESERVATION_UTIL.Println(' In query reservation, so_line_id '|| p_so_line_rec.so_line_id);
   GMI_RESERVATION_UTIL.Println(' In query reservation, batch_line_id '|| p_batch_line_rec.batch_line_id);
   GMI_RESERVATION_UTIL.Println(' In query reservation, batch_res '|| p_gme_om_reservation_rec.batch_res_id);
   IF p_so_line_rec.so_line_id is not null AND p_batch_line_rec.batch_line_id is not null THEN
     Select *
     Into l_res_rec
     From gml_batch_so_reservations
     Where so_line_id = p_so_line_rec.so_line_id
       and batch_line_id = p_batch_line_rec.batch_line_id;
   END IF;
   IF p_so_line_rec.so_line_id is not null AND p_batch_line_rec.batch_line_id is null THEN
     Select *
     Into l_res_rec
     From gml_batch_so_reservations
     Where so_line_id = p_so_line_rec.so_line_id;
   END IF;
   IF p_so_line_rec.so_line_id is null AND p_batch_line_rec.batch_line_id is not null THEN
     Select *
     Into l_res_rec
     From gml_batch_so_reservations
     Where batch_line_id = p_batch_line_rec.batch_line_id;
   END IF;
   IF p_gme_om_reservation_rec.batch_res_id is not null THEN
     Select *
     Into l_res_rec
     From gml_batch_so_reservations
     Where batch_res_id = p_gme_om_reservation_rec.batch_res_id;
   END IF;
   p_gme_om_reservation_rec.batch_id           := l_res_rec.batch_id;
   p_gme_om_reservation_rec.batch_line_id      := l_res_rec.batch_line_id;
   p_gme_om_reservation_rec.so_line_id         := l_res_rec.so_line_id;
   p_gme_om_reservation_rec.order_id           := l_res_rec.order_id;
   p_gme_om_reservation_rec.delivery_detail_id := l_res_rec.delivery_detail_id;
   p_gme_om_reservation_rec.mo_line_id         := l_res_rec.mo_line_id;
   p_gme_om_reservation_rec.reserved_qty       := l_res_rec.reserved_qty;
   p_gme_om_reservation_rec.reserved_qty2      := l_res_rec.reserved_qty2;
   p_gme_om_reservation_rec.uom1               := l_res_rec.qty_uom;
   p_gme_om_reservation_rec.uom2               := l_res_rec.qty2_uom;
   p_gme_om_reservation_rec.whse_code          := l_res_rec.whse_code;
   p_gme_om_reservation_rec.organization_id    := l_res_rec.organization_id;
   p_gme_om_reservation_rec.batch_type         := l_res_rec.batch_type;

 END query_reservation;

 PROCEDURE insert_reservation
 (
    P_Gme_om_reservation_rec IN    GML_BATCH_OM_UTIL.gme_om_reservation_rec
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 ) IS
 l_batch_res_id        NUMBER;
 BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  GMI_RESERVATION_UTIL.Println(' In insert reservations');
  /* insert gme_om_reservation_rec into gml_batch_so_reservations table */
  select gml_so_reservation_s.nextval
  into l_batch_res_id
  from dual;
  Insert Into gml_batch_so_reservations
  (
        batch_res_id
      , batch_id
      , batch_line_id
      , so_line_id
      , order_id
      , rule_id
      , delivery_detail_id
      , mo_line_id
      , item_id
      , reserved_qty
      , reserved_qty2
      , qty_uom
      , qty2_uom
      , whse_code
      , organization_id
      , allocated_ind
      , batch_type
      , delete_mark
      , created_by
      , creation_date
      , last_updated_by
      , last_update_date
  )
  Values
  (
        l_batch_res_id
      , p_gme_om_reservation_rec.batch_id
      , p_gme_om_reservation_rec.batch_line_id
      , p_gme_om_reservation_rec.so_line_id
      , p_gme_om_reservation_rec.order_id
      , p_gme_om_reservation_rec.rule_id
      , p_gme_om_reservation_rec.delivery_detail_id
      , p_gme_om_reservation_rec.mo_line_id
      , p_gme_om_reservation_rec.item_id
      , p_gme_om_reservation_rec.reserved_qty
      , p_gme_om_reservation_rec.reserved_qty2
      , p_gme_om_reservation_rec.uom1
      , p_gme_om_reservation_rec.uom2
      , p_gme_om_reservation_rec.whse_code
      , p_gme_om_reservation_rec.organization_id
      , 0
      , p_gme_om_reservation_rec.batch_type
      , 0
      , fnd_global.user_id
      , sysdate
      , fnd_global.user_id
      , sysdate
  );
  GMI_RESERVATION_UTIL.Println(' In insert reservations, new batch_res_id '||l_batch_res_id);
 EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    /*   Get message count and data*/
    FND_MSG_PUB.count_and_get
     (   p_count  => x_msg_cont
       , p_data  => x_msg_data
     );
    GMI_RESERVATION_UTIL.println('sqlerror'|| SUBSTRB(SQLERRM, 1, 100));
  WHEN OTHERS THEN
      --FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
      --                         , 'check_reservations'
      --                        );
      --/*   Get message count and data*/
      --FND_MSG_PUB.count_and_get
      -- (   p_count  => x_msg_cont
      --   , p_data  => x_msg_data
      -- );
      GMI_RESERVATION_UTIL.println('sqlerror'|| SUBSTRB(SQLERRM, 1, 100));

 END insert_reservation;

 PROCEDURE update_reservation
 (
    P_Gme_om_reservation_rec IN    GML_BATCH_OM_UTIL.gme_om_reservation_rec
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 ) IS
 BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  update gml_batch_so_reservations
  Set
        batch_id                = p_gme_om_reservation_rec.batch_id
      , batch_line_id           = p_gme_om_reservation_rec.batch_line_id
      , so_line_id              = p_gme_om_reservation_rec.so_line_id
      , order_id                = p_gme_om_reservation_rec.order_id
      , delivery_detail_id      = p_gme_om_reservation_rec.delivery_detail_id
      , mo_line_id              = p_gme_om_reservation_rec.mo_line_id
      , reserved_qty            = p_gme_om_reservation_rec.reserved_qty
      , reserved_qty2           = p_gme_om_reservation_rec.reserved_qty2
      , qty_uom                 = p_gme_om_reservation_rec.uom1
      , qty2_uom                = p_gme_om_reservation_rec.uom2
      , whse_code               = p_gme_om_reservation_rec.whse_code
      , organization_id         = p_gme_om_reservation_rec.organization_id
      , batch_type              = p_gme_om_reservation_rec.batch_type
      , delete_mark             = p_gme_om_reservation_rec.delete_mark
      , last_updated_by         = fnd_global.user_id
      , last_update_date        = sysdate
  Where batch_res_id = p_gme_om_reservation_rec.batch_res_id;
 END update_reservation;

 PROCEDURE delete_reservation
 (
    P_Batch_res_id           IN    NUMBER default null
  , P_Batch_line_id          IN    NUMBER default null
  , P_Batch_id               IN    NUMBER default null
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 ) IS
 BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF p_batch_res_id is not null Then
     update gml_batch_so_reservations
     set delete_mark = 1
     Where batch_res_id = p_batch_res_id;
   END IF;
   IF p_batch_line_id is not null Then
     update gml_batch_so_reservations
     set delete_mark = 1
     Where batch_line_id = p_batch_line_id;
   END IF;
   IF p_batch_id is not null Then
     update gml_batch_so_reservations
     set delete_mark = 1
     Where batch_id = p_batch_id;
   END IF;
 END delete_reservation;

 PROCEDURE query_alloc_history
 (
    P_alloc_history_rec      IN  OUT NOCOPY GML_BATCH_OM_UTIL.alloc_history_rec
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 ) IS
 l_alloc_rec_id        NUMBER;
 l_history_row         gml_batch_so_alloc_history%rowtype;
 l_history_rec         GML_BATCH_OM_UTIL.alloc_history_rec;
 BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF p_alloc_history_rec.alloc_rec_id is not null THEN
     Select *
     Into l_history_row
     from gml_batch_so_alloc_history
     Where alloc_rec_id = p_alloc_history_rec.alloc_rec_id;
  END IF;
  l_history_rec.Batch_id            := l_history_row.batch_id;
  l_history_rec.Batch_line_id       := l_history_row.batch_line_id;
  l_history_rec.So_line_id          := l_history_row.line_id;
  l_history_rec.Batch_res_id        := l_history_row.batch_res_id;
  l_history_rec.Batch_trans_id      := l_history_row.batch_trans_id;
  l_history_rec.trans_id            := l_history_row.trans_id;
  l_history_rec.Whse_code           := l_history_row.whse_code;
  l_history_rec.Reserved_qty        := l_history_row.reserved_qty;
  l_history_rec.Reserved_qty2       := l_history_row.reserved_qty2;
  l_history_rec.Trans_um            := l_history_row.trans_um;
  l_history_rec.Trans_um2           := l_history_row.trans_um2;
  l_history_rec.rule_id             := l_history_row.rule_id;
  l_history_rec.failure_reason      := l_history_row.failure_reason;
  l_history_rec.lot_id              := l_history_row.lot_id;
  l_history_rec.location            := l_history_row.location;

  p_alloc_history_rec := l_history_rec;

 END query_alloc_history;

 PROCEDURE insert_alloc_history
 (
    P_alloc_history_rec      IN    GML_BATCH_OM_UTIL.alloc_history_rec
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 ) IS
 l_alloc_rec_id        NUMBER;
 BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  /* insert gme_om_reservation_rec into gml_batch_so_reservations table */
  GMI_RESERVATION_UTIL.println('inserting alloc history');
  select gml_so_alloc_history_s.nextval
  into l_alloc_rec_id
  from dual;
  Insert Into gml_batch_so_alloc_history
  (   Alloc_rec_id
    , Batch_res_id
    , Batch_id
    , Trans_id
    , line_id
    , Lot_id
    , Location
    , Whse_code
    , Rule_id
    , Failure_reason
    , batch_trans_id
    , batch_line_id
    , delete_mark
    , CREATION_DATE
    , CREATED_BY
    , LAST_UPDATED_DATE
    , LAST_UPDATED_BY
   )
  Values
  (
        l_alloc_rec_id
      , p_alloc_history_rec.batch_res_id
      , p_alloc_history_rec.batch_id
      , p_alloc_history_rec.trans_id
      , p_alloc_history_rec.so_line_id
      , p_alloc_history_rec.lot_id
      , p_alloc_history_rec.location
      , p_alloc_history_rec.whse_code
      , p_alloc_history_rec.rule_id
      , p_alloc_history_rec.failure_reason
      , p_alloc_history_rec.batch_trans_id
      , p_alloc_history_rec.batch_line_id
      , 0
      , sysdate
      , fnd_global.user_id
      , sysdate
      , fnd_global.user_id
  );
  GMI_RESERVATION_UTIL.println(' alloc_rec_id '|| l_alloc_rec_id);

 EXCEPTION
  WHEN OTHERS THEN
     GMI_RESERVATION_UTIL.println('sqlerror'|| SUBSTRB(SQLERRM, 1, 100));

 END insert_alloc_history;

 FUNCTION check_reservation
 (
    P_Batch_res_id           IN    NUMBER default null
  , P_Batch_line_id          IN    NUMBER default null
  , P_Batch_id               IN    NUMBER default null
  , P_so_line_id             IN    NUMBER default null
  , P_delivery_detail_id     IN    NUMBER default null
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 ) RETURN BOOLEAN IS

 l_exist      Number; --  default := 0;

 BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  GMI_reservation_Util.PrintLn('Check reservation ');
  GMI_reservation_Util.PrintLn('  p_batch_res_id '||p_batch_res_id);
  GMI_reservation_Util.PrintLn('  p_batch_line_id '||p_batch_line_id);
  GMI_reservation_Util.PrintLn('  p_batch_id '||p_batch_id);
  GMI_reservation_Util.PrintLn('  p_so_line_id '||p_so_line_id);

  l_exist := 0;
  IF p_batch_id is not null then
     Select count(*)
     Into l_exist
     From gml_batch_so_reservations
     Where batch_id = p_batch_id
      and  delete_mark = 0
      and  (reserved_qty > 0 or allocated_ind = 1)
      ;
     IF SQL%NOTFOUND or (sqlcode=1403) or l_exist = 0 THEN
        --GMI_RESERVATION_UTIL.println('sqlerror'|| SUBSTRB(SQLERRM, 1, 100));
        return false;
     END IF;
  End if;
  IF p_batch_line_id is not null then
     Select count(*)
     Into l_exist
     From gml_batch_so_reservations
     Where batch_line_id = p_batch_line_id
      and  delete_mark = 0
      and  (reserved_qty > 0 or allocated_ind = 1)
      ;
     GMI_reservation_Util.PrintLn('  exist ? '||l_exist);
     IF SQL%NOTFOUND or (sqlcode=1403) or l_exist = 0 THEN
        return false;
     END IF;
  End if;
  IF p_so_line_id is not null then
     Select count(*)
     Into l_exist
     From gml_batch_so_reservations
     Where so_line_id = p_so_line_id
      and  delete_mark = 0
      and  (reserved_qty > 0 or allocated_ind = 1)
      ;
     IF SQL%NOTFOUND or (sqlcode=1403) or l_exist = 0 THEN
        return false;
     END IF;
  End if;
  IF p_delivery_detail_id is not null then
     Select count(*)
     Into l_exist
     From gml_batch_so_reservations
     Where delivery_detail_id = p_delivery_detail_id
      and  delete_mark = 0
      and  (reserved_qty > 0 or allocated_ind = 1)
      ;
     IF SQL%NOTFOUND or (sqlcode=1403) or l_exist = 0 THEN
        return false;
     END IF;
  End if;

  return true;

 EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    /*   Get message count and data*/
    FND_MSG_PUB.count_and_get
     (   p_count  => x_msg_cont
       , p_data  => x_msg_data
     );
    GMI_reservation_Util.PrintLn('(opm_dbg) in PVT u EXCEPTION: Expected');
  WHEN OTHERS THEN
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , 'check_reservations'
                              );
      /*   Get message count and data*/
      --FND_MSG_PUB.count_and_get
      -- (   p_count  => x_msg_cont
      --   , p_data  => x_msg_data
      -- );
      GMI_RESERVATION_UTIL.println('sqlerror'|| SUBSTRB(SQLERRM, 1, 100));
      return false;
 END check_reservation;

 PROCEDURE check_rules
 (
    P_Gme_om_config_assign   IN    GML_BATCH_OM_UTIL.gme_om_config_assign
  , X_count                  OUT   NOCOPY NUMBER
  , X_rule_id                OUT   NOCOPY NUMBER
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 ) IS

  l_rule_id               NUMBER;
  l_rule_count            NUMBER;
  l_rule_assign_id        NUMBER;
  l_where_clause          VARCHAR2(500);

  Cursor get_the_rule IS
  Select  decode(site_use_id, null, 0, site_use_id) site_use_id
       ,  decode(customer_id, null, 0, customer_id) customer_id
       ,  decode(item_id, null, 0, item_id)         item_id
       ,  decode(allocation_class, null, ' ', allocation_class) allocation_class
       ,  rule_assign_id
       ,  rule_id
  From gml_batch_so_rule_assignments
  Where whse_code = p_gme_om_config_assign.whse_code
    and (item_id = p_gme_om_config_assign.item_id
         or item_id is null )
    and (allocation_class = p_gme_om_config_assign.allocation_class
         or allocation_class is null)
    and (customer_id = p_gme_om_config_assign.customer_id
         or customer_id is null)
    and (site_use_id = p_gme_om_config_assign.site_use_id
         or site_use_id is null)
    and delete_mark = 0
  Order by
    1 desc
  , 2 desc
  , 3 desc
  , 4 desc
  ;

  l_rule_assign_rec       get_the_rule%rowtype;

  TYPE rc IS REF CURSOR;
  check_rule_assign rc;

 BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  /* get the most suitable rule first */
  GMI_reservation_Util.PrintLn('IN check Rule');
  Open get_the_rule;
  Fetch get_the_rule
  Into l_rule_assign_rec.site_use_id
    ,  l_rule_assign_rec.customer_id
    ,  l_rule_assign_rec.item_id
    ,  l_rule_assign_rec.allocation_class
    ,  l_rule_assign_id
    ,  l_rule_id
    ;
  Close get_the_rule;

  /*Select  rule_id
       ,  rule_assign_id
  Into l_rule_id
    ,  l_rule_assign_id
    ,  nvl(item_id, 0)
    ,  nvl(allocation_class, '0')
    ,  nvl(customer_id, 0)
    ,  nvl(site_use_id, 0)
  From gml_batch_so_rule_assignments
  Where whse_code = p_gme_om_config_assign.whse_code
    and (item_id = nvl(p_gme_om_config_assign.item_id,0)
         or item_id is null )
    and (allocation_class = nvl(p_gme_om_config_assign.allocation_class,'0')
         or allocation_class is null)
    and (customer_id = nvl(p_gme_om_config_assign.customer_id,0)
         or customer_id is null)
    and (site_use_id = nvl(p_gme_om_config_assign.site_use_id,0)
         or site_use_id is null)
    and delete_mark = 0
  Order by
    site_use_id desc
  , customer_id desc
  , item_id desc
  , allocation_class desc
  ;*/

  GMI_reservation_Util.PrintLn('check Rule, rule_id '||l_rule_id);
  /*IF get_the_rule%Notfound Then
     GMI_reservation_Util.PrintLn('Rule is not found');
     x_count := 0;
     x_rule_id := null;
     return;
  END IF;*/

  /* get this record from the assignment table */
  /*Select item_id
     ,   allocation_class
     ,   customer_id
     ,   site_use_id
  Into l_rule_assign_rec.item_id
     , l_rule_assign_rec.allocation_class
     , l_rule_assign_rec.customer_id
     , l_rule_assign_rec.site_use_id
  From gml_batch_so_rule_assignments
  Where rule_assign_id = l_rule_assign_id;
  */

  /* check the uniqueness
   * construct the where clause
   */
  l_where_clause := 'delete_mark = 0 and whse_code = ';
  l_where_clause := l_where_clause || '''';
  l_where_clause := l_where_clause || p_gme_om_config_assign.whse_code;
  l_where_clause := l_where_clause || '''';

  If nvl(l_rule_assign_rec.item_id, 0) <> 0 THEN
     l_where_clause := l_where_clause || ' And item_id = '|| l_rule_assign_rec.item_id ;
  else
     l_where_clause := l_where_clause || ' And item_id is null ';
  End If;
  If nvl(l_rule_assign_rec.allocation_class, ' ') <> ' ' THEN
     l_where_clause := l_where_clause || ' And allocation_class = ';
     l_where_clause := l_where_clause || '''';
     l_where_clause := l_where_clause || l_rule_assign_rec.allocation_class ;
     l_where_clause := l_where_clause || '''';
  else
     l_where_clause := l_where_clause || ' And allocation_class is null ';
  End If;
  If nvl(l_rule_assign_rec.customer_id, 0) <> 0 THEN
     l_where_clause := l_where_clause || ' And customer_id = '||l_rule_assign_rec.customer_id ;
  else
     l_where_clause := l_where_clause || ' And customer_id is null ';
  End If;
  If nvl(l_rule_assign_rec.site_use_id, 0) <> 0 THEN
     l_where_clause := l_where_clause || ' And site_use_id = '||l_rule_assign_rec.site_use_id ;
  else
     l_where_clause := l_where_clause || ' And site_use_id is null ';
  End If;

  GMI_reservation_Util.PrintLn('check Rule, to check_rule_assign');
  GMI_reservation_Util.PrintLn('check Rule,where clause '||l_where_clause);
  OPEN check_rule_assign for
      'SELECT count(*) FROM gml_batch_so_rule_assignments WHERE '
      || l_where_clause ;
  Fetch check_rule_assign Into l_rule_count;
  Close check_rule_assign;

  GMI_reservation_Util.PrintLn('check Rule, l_rule_count '||l_rule_count);
  x_count := l_rule_count;
  x_rule_id := l_rule_id;

 END check_rules;

 PROCEDURE get_rule
 (
    P_so_line_rec            IN    GML_BATCH_OM_UTIL.so_line_rec
  , P_batch_line_rec         IN    GML_BATCH_OM_UTIL.batch_line_rec
  , X_gme_om_rule_rec        OUT   NOCOPY GML_BATCH_OM_UTIL.gme_om_rule_rec
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 ) IS
 l_rule_count             NUMBER ; -- default := 0 ;
 l_rule_id                NUMBER ;
 l_inventory_item_id      NUMBER ;
 l_organization_id        NUMBER ;
 l_so_line_id             NUMBER ;
 i                        NUMBER ;
 j                        NUMBER ;
 l_rule_rec               gml_batch_so_rules%rowtype;
 l_Gme_om_config_assign   GML_BATCH_OM_UTIL.gme_om_config_assign;
 l_cust_site              so_lineTabTyp ;
 l_so_line_rec            GML_BATCH_OM_UTIL.so_line_rec;
 l_cust_diff              NUMBER ;
 l_site_diff              NUMBER ;
 l_org_diff               NUMBER ;

 Cursor get_so_line_ids (p_batch_line_id in NUMBER) is
 Select distinct so_line_id
 From gml_batch_so_reservations
 Where batch_line_id = p_batch_line_id;

 Cursor get_line_info (p_so_line_id IN NUMBER) is
 Select sold_to_org_id
   ,    ship_to_org_id
   ,    inventory_item_id
   ,    ship_from_org_id
 From oe_order_lines_all
 Where line_id = p_so_line_id;

 Cursor get_alloc_class
            ( p_inv_item_id IN NUMBER
            , p_org_id     IN NUMBER)
            IS
 Select ic.alloc_class
    ,   ic.item_id
 From ic_item_mst ic
    , mtl_system_items mtl
 Where ic.item_no = mtl.segment1
   and mtl.inventory_item_id = p_inv_item_id
   and mtl.organization_id = p_org_id;

 Cursor get_whse_code (p_org_id IN NUMBER) IS
 Select whse_code
 From ic_whse_mst
 Where mtl_organization_id = p_org_id;

 BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_so_line_rec  := p_so_line_rec;

  /* assign the gme_om_config_assign record */
  /* if batch line is passed
   * check all the orders reserved against the batch line
   * if conflict, go to next level of hierarchy
   * inventory item id would be the same
   */
  l_cust_site.delete;
  IF p_batch_line_rec.batch_line_id is not null THEN -- batch line is passed
     /* get all the so_line_id from batch reservation record */
     GMI_reservation_Util.PrintLn('get_rule: batch line passed');
     i:= 1;
     for so_line_ids in get_so_line_ids (p_batch_line_rec.batch_line_id ) loop
        l_so_line_id := so_line_ids.so_line_id;
        GMI_reservation_Util.PrintLn('get_rule: so_line_id '||l_so_line_id);
        Open get_line_info(l_so_line_id) ;
        Fetch get_line_info
        Into
           l_cust_site(i).customer_id
         , l_cust_site(i).site_use_id
         , l_inventory_item_id
         , l_cust_site(i).organization_id
          ;
        Close get_line_info;
        GMI_reservation_Util.PrintLn('get_rule: batch line customer_id '||l_cust_site(i).customer_id);
        i := i+1;
     end loop;
     i :=1;
     j := 1;
     l_cust_diff := 0;
     l_site_diff := 0;
     l_org_diff  := 0;
     GMI_reservation_Util.PrintLn('get_rule: cust_site count '|| l_cust_site.count);
     for i in 1..l_cust_site.count Loop
        for j in (i+1)..l_cust_site.count Loop
           GMI_reservation_Util.PrintLn('get_rule: j '|| j);
           if nvl(l_cust_site(i).customer_id,0) <> nvl(l_cust_site(j).customer_id,0) Then
              l_cust_diff := 1;
           END IF;
           if l_cust_site(i).site_use_id <> l_cust_site(j).site_use_id Then
              l_site_diff := 1;
           END IF;
           if l_cust_site(i).organization_id <> l_cust_site(j).organization_id Then
              l_org_diff := 1;
           END IF;
        end loop;
     end loop;
     IF l_site_diff = 1 THEN
       l_gme_om_config_assign.site_use_id := null;
     END IF;
     IF l_cust_diff = 1 THEN
       l_gme_om_config_assign.customer_id := null;
     END IF;
     IF l_org_diff = 1 THEN
        null;
        /* GMI_reservation_Util.PrintLn('org is different ');
         */
     END IF;
     l_gme_om_config_assign.customer_id := l_cust_site(1).customer_id;
     l_gme_om_config_assign.site_use_id := l_cust_site(1).site_use_id;
     l_organization_id := l_cust_site(1).organization_id;
  END IF;

  /* if so line is passed, use this so line */
  IF p_so_line_rec.so_line_id is not null  THEN
     GMI_reservation_Util.PrintLn('get_rule: so_line_rec so_line_id is not null '||p_so_line_rec.so_line_id);
     l_so_line_id := p_so_line_rec.so_line_id;
     Open get_line_info(l_so_line_id);
     Fetch get_line_info
     Into l_gme_om_config_assign.customer_id
      ,   l_gme_om_config_assign.site_use_id
      ,   l_so_line_rec.inventory_item_id
      ,   l_so_line_rec.ship_from_org_id
      ;
     Close get_line_info ;
  END IF;
  /* assign l_org_id from the passed value, this way, caller can specify whse
   * even with batch_line only passed*/
  IF p_so_line_rec.ship_from_org_id is not null  THEN
     l_so_line_rec.ship_from_org_id := p_so_line_rec.ship_from_org_id;
  END IF;
  IF l_so_line_rec.ship_from_org_id is not null  THEN
     l_organization_id := l_so_line_rec.ship_from_org_id;
  END IF;
  IF l_so_line_rec.inventory_item_id is not null  THEN
     l_inventory_item_id := l_so_line_rec.inventory_item_id;
  END IF;

  GMI_reservation_Util.PrintLn('get_rule: customer_id '||l_gme_om_config_assign.customer_id);
  GMI_reservation_Util.PrintLn('get_rule: site_use_id '||l_gme_om_config_assign.site_use_id);
  GMI_reservation_Util.PrintLn('get_rule: l_organization_id '||l_organization_id);
  GMI_reservation_Util.PrintLn('get_rule: l_inventory_item_id '||l_inventory_item_id);

  Open get_alloc_class(l_inventory_item_id
                    , l_organization_id)
                    ;
  Fetch get_alloc_class
  Into l_gme_om_config_assign.allocation_class
     , l_gme_om_config_assign.item_id;
  Close get_alloc_class;
  IF l_so_line_rec.whse_code is null THEN
     Open get_whse_code (l_organization_id);
     Fetch get_whse_code Into l_gme_om_config_assign.whse_code;
     Close get_whse_code;
  ELSE
     l_gme_om_config_assign.whse_code := l_so_line_rec.whse_code;
  END IF;
  GMI_reservation_Util.PrintLn('get_rule: allocation_class '||l_gme_om_config_assign.allocation_class);
  GMI_reservation_Util.PrintLn('get_rule: item_id '||l_gme_om_config_assign.item_id);
  GMI_reservation_Util.PrintLn('get_rule: whse_code '||l_gme_om_config_assign.whse_code);

  /* check rules first to see the uniqueness, if not, error */
  GML_BATCH_OM_UTIL.check_rules
     (
       P_Gme_om_config_assign   => l_gme_om_config_assign
     , X_count                  => l_rule_count
     , X_rule_id                => l_rule_id
     , X_return_status          => x_return_status
     , X_msg_cont               => x_msg_cont
     , X_msg_data               => x_msg_data
     );

  IF x_return_status <> fnd_api.g_ret_sts_success Then
     GMI_reservation_Util.PrintLn('OM_UTIL, checking rule failure');
     --FND_MESSAGE.SET_NAME('GMI','GMI_QTY_RSV_NOT_FOUND');
     --FND_MESSAGE.Set_Token('WHERE', 'Check rules');
     --FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
  END IF;
  IF l_rule_count = 0 Then
     GMI_reservation_Util.PrintLn('OM_UTIL, No rule found');
     --FND_MESSAGE.SET_NAME('GMI','GMI_QTY_RSV_NOT_FOUND');
     --FND_MESSAGE.Set_Token('WHERE', 'Check rules');
     --FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
  END IF;
  IF l_rule_count > 1 Then
     GMI_reservation_Util.PrintLn('OM_UTIL, Multiple rules found');
     --FND_MESSAGE.SET_NAME('GMI','GMI_QTY_RSV_NOT_FOUND');
     --FND_MESSAGE.Set_Token('WHERE', 'Check rules');
     --FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
  END IF;
  /* get the rule rec if it is unique */
  Select *
  Into l_rule_rec
  From gml_batch_so_rules
  Where rule_id = l_rule_id;
  /* fill in the rec type */
  x_gme_om_rule_rec.Rule_id                := l_rule_rec.rule_id;
  x_gme_om_rule_rec.Rule_name              := l_rule_rec.rule_name;
  x_gme_om_rule_rec.DAYS_BEFORE_SHIP_DATE  := l_rule_rec.days_before_ship_date;
  x_gme_om_rule_rec.DAYS_AFTER_SHIP_DATE   := l_rule_rec.days_after_ship_date;
  x_gme_om_rule_rec.BATCH_STATUS           := l_rule_rec.batch_status;
  x_gme_om_rule_rec.ALLOCATION_TOLERANCE   := l_rule_rec.allocation_tolerance;
  x_gme_om_rule_rec.ALLOCATION_PRIORITY    := l_rule_rec.allocation_priority;
  x_gme_om_rule_rec.AUTO_PICK_CONFIRM      := l_rule_rec.auto_pick_confirm;
  x_gme_om_rule_rec.BATCH_NOTIFICATION     := l_rule_rec.batch_notification;
  x_gme_om_rule_rec.ORDER_NOTIFICATION     := l_rule_rec.order_notification;
  x_gme_om_rule_rec.Enable_FPO             := l_rule_rec.enable_fpo;
  x_gme_om_rule_rec.rule_type		   := l_rule_rec.rule_type;
  x_gme_om_rule_rec.batch_type_to_create   := l_rule_rec.batch_type_to_create;
  x_gme_om_rule_rec.batch_creation_user    := l_rule_rec.batch_creation_user;
  x_gme_om_rule_rec.check_availability     := l_rule_rec.check_availability;
  x_gme_om_rule_rec.auto_lot_generation    := l_rule_rec.auto_lot_generation;
  x_gme_om_rule_rec.firmed_ind    	   := l_rule_rec.firmed_ind;
  x_gme_om_rule_rec.reserve_max_tolerance  := l_rule_rec.reserve_max_tolerance;
  x_gme_om_rule_rec.copy_attachments  	   := l_rule_rec.copy_attachments;
  x_gme_om_rule_rec.sales_order_attachment := l_rule_rec.sales_order_attachment;
  x_gme_om_rule_rec.batch_attachment 	   := l_rule_rec.batch_attachment;
  x_gme_om_rule_rec.batch_creation_notification := l_rule_rec.batch_creation_notification;
  GMI_reservation_Util.PrintLn('get_rule: rule name '|| x_gme_om_rule_rec.rule_name);

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

 EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    /*   Get message count and data*/
    FND_MSG_PUB.count_and_get
     (   p_count  => x_msg_cont
       , p_data  => x_msg_data
     );
    GMI_reservation_Util.PrintLn('(opm_dbg) in PVT u EXCEPTION: Expected');
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , 'get_rule'
                              );
      /*   Get message count and data*/
      FND_MSG_PUB.count_and_get
       (   p_count  => x_msg_cont
         , p_data  => x_msg_data
       );
      GMI_reservation_Util.PrintLn('(opm_dbg) in PVT u EXCEPTION: Others');
      GMI_RESERVATION_UTIL.println('sqlerror'|| SUBSTRB(SQLERRM, 1, 100));

 END get_Rule;

END GML_BATCH_OM_UTIL;

/
