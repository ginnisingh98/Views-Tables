--------------------------------------------------------
--  DDL for Package Body WMS_OTM_DOCK_SYNC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_OTM_DOCK_SYNC" AS
/* $Header: WMSOTDDB.pls 120.0 2007/12/22 04:13:09 dramamoo noship $ */

--Global variable to hold the package name
G_PKG_NAME CONSTANT VARCHAR2(30) := 'WMS_OTM_DOCK_SYNC';

--Global variable used in print_debug utility
G_VERSION_PRINTED   BOOLEAN      := FALSE;

G_debug NUMBER  :=  NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);

PROCEDURE print_debug
  (
   p_err_msg   VARCHAR2
   , p_level   NUMBER
  ) IS
  BEGIN
    IF (g_debug = 1) THEN
      IF(G_VERSION_PRINTED = FALSE ) THEN
        inv_log_util.trace (
          p_message   =>  '$Header: WMSOTDDB.pls 120.0 2007/12/22 04:13:09 dramamoo noship $'
        , p_module    =>  G_PKG_NAME
        , p_level     =>  9);
        G_VERSION_PRINTED :=TRUE;
      END IF;
      inv_log_util.trace (
        p_message   =>  p_err_msg
      , p_module    =>  G_PKG_NAME
      , p_level     =>  p_level);
    END IF;
END print_debug;


PROCEDURE Send_Dock_Doors (
                            p_entity_in_rec     IN WSH_OTM_ENTITY_REC_TYPE,
                            x_username          OUT NOCOPY VARCHAR2,
                            x_password          OUT NOCOPY VARCHAR2,
                            x_org_dock_tbl      OUT NOCOPY WMS_ORG_DOCK_TBL_TYPE,
                            x_return_status     OUT NOCOPY VARCHAR2,
                            x_msg_data          OUT NOCOPY VARCHAR2 )
IS
    --  Cursor to get the Location XID for the Organization
    CURSOR l_org_loc_csr(l_organization_id NUMBER) IS
    SELECT 'ORG-' || ORGANIZATION_ID ||'-'|| LOCATION_ID LOCATION_XID
    FROM   WSH_SHIP_FROM_ORGS_V
    WHERE  ORGANIZATION_ID = l_organization_id;

    --  Cursor to get the Location XID for the Organization
    --  NVL function added for Description since OTM always expects a Dock Name
    CURSOR l_dock_info_csr(l_organization_id NUMBER) IS
    SELECT 'DOCK-' || inventory_location_id LOCATION_RES_XID,
           NVL(description, 'DOCK-' || inventory_location_id||' Name') LOCATION_RES_NAME
    FROM   mtl_item_locations
    WHERE  organization_id = l_organization_id
    AND    inventory_location_type = 1;

    l_domain_name  VARCHAR2(100);
    l_location_xid VARCHAR2(50);
    i              NUMBER;
    j              NUMBER;
    l_msg_count    NUMBER;
BEGIN
  IF g_debug = 1 THEN
     print_debug('In Send_Dock_Doors API ', 4);
  END IF;
  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_entity_in_rec.entity_id_tbl.count > 0 AND p_entity_in_rec.ENTITY_TYPE = 'ORG_LOC' THEN --{

     FND_PROFILE.Get('WSH_OTM_DOMAIN_NAME', l_domain_name);
     FND_PROFILE.Get('WSH_OTM_USER_ID', x_username);
     FND_PROFILE.Get('WSH_OTM_PASSWORD', x_password);

     IF g_debug = 1 THEN
        print_debug('OTM Domain : ' || l_domain_name || ' , OTM User : ' || x_username
                 || ' , OTM Password : ' || x_password
                 || ' , Number of Organizations : '||p_entity_in_rec.entity_id_tbl.count, 4);
     END IF;

     x_org_dock_tbl := WMS_ORG_DOCK_TBL_TYPE();

     FOR i in p_entity_in_rec.entity_id_tbl.first..p_entity_in_rec.entity_id_tbl.last LOOP --{

         x_org_dock_tbl.extend;
         x_org_dock_tbl(i) := WMS_ORG_DOCK_REC_TYPE
                              ( NULL,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                WMS_DOCK_DOOR_TBL_TYPE()
                              );

         OPEN l_org_loc_csr(p_entity_in_rec.entity_id_tbl(i));
         FETCH l_org_loc_csr INTO l_location_xid;
         CLOSE l_org_loc_csr;

         x_org_dock_tbl(i).LOCATION_XID    := l_location_xid;
         x_org_dock_tbl(i).LOCATION_DN     := l_domain_name;
         x_org_dock_tbl(i).RESOURCE_TYPE   := 'DOCK DOOR';
         x_org_dock_tbl(i).CALENDAR_DN     := NULL;
         x_org_dock_tbl(i).CALENDAR_XID    := NULL;
         x_org_dock_tbl(i).CONSTRAINT_APPT := NULL;

         IF g_debug = 1 THEN
            print_debug('Organization XID : '||l_location_xid, 4);
         END IF;

         j := 1;
         FOR l_dock_info IN l_dock_info_csr(p_entity_in_rec.entity_id_tbl(i)) LOOP --{
             x_org_dock_tbl(i).DOCK_DOOR_TBL.extend;
             x_org_dock_tbl(i).DOCK_DOOR_TBL(j) := WMS_DOCK_DOOR_REC_TYPE(NULL, NULL, NULL);
             x_org_dock_tbl(i).DOCK_DOOR_TBL(j).LOCATION_RES_XID  := l_dock_info.LOCATION_RES_XID;
             x_org_dock_tbl(i).DOCK_DOOR_TBL(j).LOCATION_RES_NAME := l_dock_info.LOCATION_RES_NAME;
             x_org_dock_tbl(i).DOCK_DOOR_TBL(j).LOCATION_RES_DN   := l_domain_name;
             IF g_debug = 1 THEN
                print_debug('Location Res XID :  '||l_dock_info.LOCATION_RES_XID, 4);
                print_debug('Location Res Name : '||l_dock_info.LOCATION_RES_NAME, 4);
             END IF;
             j := j + 1;
         END LOOP; --}
         IF g_debug = 1 THEN
            print_debug('Number of Dock Doors sent : '||x_org_dock_tbl(i).DOCK_DOOR_TBL.count, 4);
         END IF;
     END LOOP; --}
  END IF; --}
  IF g_debug = 1 THEN
     print_debug('Exiting Send_Dock_Doors API ', 4);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
       IF g_debug = 1 THEN
          print_debug('Unexpected error in Send_Dock_Doors API ', 4);
          print_debug(SQLERRM, 4);
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MESSAGE.SET_NAME('WMS','WMS_DOCK_DOOR_SYNC');
       FND_MSG_PUB.ADD;
       FND_MSG_PUB.Count_And_Get
       (p_count => l_msg_count,
        p_data  => x_msg_data);
END;

-- Get FND Security details.
-- Create New if doesn't exist
-- Return existing if valid.
-- If expired, delete existing and create new
PROCEDURE get_secure_ticket_details( p_op_code          IN         VARCHAR2,
                                     p_argument         IN         VARCHAR2,
                                     x_ticket           OUT NOCOPY RAW,
                                     x_return_status    OUT NOCOPY VARCHAR2
                                   )
IS
  l_ticket        RAW(16);
  l_ticket_string VARCHAR2(1000);
  l_operation     VARCHAR2(255);
  l_argument      VARCHAR2(4000);
  l_end_date      VARCHAR2(100);
  l_edate         TimeStamp;
  l_sysdate       TimeStamp;

  CURSOR c_get_ticket_details (c_operation VARCHAR2, c_argument VARCHAR2) IS
  SELECT ticket, operation, argument, end_date
  FROM   FND_HTTP_TICKETS
  WHERE  operation = c_operation
  AND    argument  = c_argument;

  CURSOR c_get_sysdate IS
  SELECT SYSDATE FROM DUAL;

BEGIN
  IF g_debug = 1 THEN
     print_debug('In Get_Secure_Ticket_Details API ', 4);
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN c_get_ticket_details (p_op_code,p_argument);
  FETCH c_get_ticket_details INTO l_ticket,l_operation, l_argument, l_edate;
  CLOSE c_get_ticket_details;

  -- Ticket Exists. Valid and not expired
  -- return the existing ticket
  OPEN c_get_sysdate;
  FETCH c_get_sysdate INTO l_sysdate;
  CLOSE c_get_sysdate;

  IF ( l_edate IS NOT NULL) AND ( l_edate > SYSDATE) THEN
     IF g_debug = 1 THEN
        print_debug('Tickets Exists. Valid and not expired', 4);
     END IF;
    -- l_ticket is actual ticket. Do Nothing.
    -- Ticket Exists but expired.Delete existing
  ELSIF ( l_edate IS NOT NULL) AND ( l_edate < SYSDATE) THEN
     IF g_debug = 1 THEN
        print_debug('Tickets Exists but expired. Delete existing', 4);
     END IF;
     FND_HTTP_TICKET.DESTROY_TICKET(l_ticket);

     IF g_debug = 1 THEN
        print_debug('Creating new ticket ...', 4);
     END IF;
     l_ticket := FND_HTTP_TICKET.CREATE_TICKET(p_op_code
                                              ,p_argument
                                              ,36000 --10 hrs
                                              );
  ELSE
     IF g_debug = 1 THEN
        print_debug('ticket does not exist. Create a new ticket', 4);
     END IF;
     l_ticket := FND_HTTP_TICKET.CREATE_TICKET(p_op_code
                                              ,p_argument
                                              ,36000 --10 hrs
                                              );
  END IF;

  x_ticket := l_ticket;

  IF g_debug = 1 THEN
     print_debug('l_ticket  : '||x_ticket, 4);
     print_debug('Exiting Get_Secure_Ticket_Details API ', 4);
  END IF;

EXCEPTION
  WHEN others THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF g_debug = 1 THEN
       print_debug('Unexpected error has occured in Get_Secure_Ticket_Details API ', 4);
       print_debug(sqlerrm, 4);
    END IF;
END get_secure_ticket_details;
END;

/
