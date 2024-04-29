--------------------------------------------------------
--  DDL for Package Body BOM_RTG_EAM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_RTG_EAM_UTIL" AS
/* $Header: BOMREAMB.pls 115.6 2004/03/19 12:39:30 earumuga ship $ */
/****************************************************************************
--
--  Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--     BOMREAMB.pls
--
--  DESCRIPTION
--
--      Body of package Bom_Rtg_Eam_Util : eAM utility for routing  package
--
--  NOTES
--
--  HISTORY
--
--  12-AUG-01 Masanori Kimizuka Initial Creation
--
****************************************************************************/

G_Pkg_Name      VARCHAR2(30) := 'Bom_Rtg_Eam_Util';

/*******************************************************************
* Procedure     : CheckNwkExists
* Parameters IN : routing_sequence_id
* Parameters OUT: None
* Purpose       : Procedure will return True if valid Rtg Network exists.
*********************************************************************/
FUNCTION CheckNwkExists( p_routing_sequence_id IN NUMBER )
RETURN BOOLEAN
IS

    CURSOR  c_Nwk_Exists IS
        SELECT 'Valid Nwk Exists'
        FROM BOM_OPERATION_NETWORKS bon
        WHERE exists  ( SELECT operation_sequence_id
                        FROM bom_operation_sequences bos
                        WHERE bos.operation_sequence_id = bon.from_op_seq_id
                        AND   bos.routing_sequence_id = p_routing_sequence_id
                        AND   bos.effectivity_date <= SYSDATE
                        AND   nvl(bos.disable_date,SYSDATE+2) > SYSDATE
                       )
        AND   exists  ( SELECT operation_sequence_id
                        FROM bom_operation_sequences bos2
                        WHERE bos2.operation_sequence_id = bon.to_op_seq_id
                        AND   bos2.routing_sequence_id = p_routing_sequence_id
                        AND   bos2.effectivity_date <= SYSDATE
                        AND   nvl(bos2.disable_date,SYSDATE+2) > SYSDATE
                        )
        AND  nvl(bon.disable_date,SYSDATE+2) > SYSDATE ;

BEGIN

    FOR x_Nwk IN c_Nwk_Exists
    LOOP
        RETURN TRUE ;
    END LOOP ;

    RETURN FALSE ;

END CheckNwkExists ;

/*******************************************************************
* Procedure     : Get_All_Links
* Parameters IN : routing_sequence_id
* Parameters OUT: x_network_link_tbl
* Purpose       : Procedure will return a PL/SQL table of
*                 Op_Nwk_Link_Tbl_Type type as OUT parameter
*                 that includes a list of all operation links for
*                 the routing network of eAM Maintenace Routing.
*********************************************************************/
PROCEDURE Get_All_Links
(   p_routing_sequence_id   IN  NUMBER
 ,  x_network_link_tbl      IN OUT NOCOPY Op_Nwk_Link_Tbl_Type
)
IS

    i INTEGER := 1;

    CURSOR c_All_Nwk_Links  IS
        SELECT   bon.from_op_seq_id     from_op_seq_id
               , bos1.operation_seq_num from_op_seq_num
               , bon.to_op_seq_id       to_op_seq_id
               , bos2.operation_seq_num to_op_seq_num
               , bon.transition_type    transition_type
               , bon.planning_pct       planning_pct
        FROM     BOM_OPERATION_NETWORKS bon
               , BOM_OPERATION_SEQUENCES bos1
               , BOM_OPERATION_SEQUENCES bos2
        WHERE nvl(bon.disable_date,SYSDATE+2) > SYSDATE
        AND   bon.transition_type <> 3
        AND   bos2.effectivity_date <= SYSDATE
        AND   nvl(bos2.disable_date,SYSDATE+2) > SYSDATE
        AND   bos2.routing_sequence_id = p_routing_sequence_id
        AND   bos2.operation_sequence_id = bon.to_op_seq_id
        AND   bos1.effectivity_date <= SYSDATE
        AND   nvl(bos1.disable_date,SYSDATE+2) > SYSDATE
        AND   bos1.routing_sequence_id = p_routing_sequence_id
        AND   bos1.operation_sequence_id = bon.from_op_seq_id
        ORDER BY from_op_seq_num ;


BEGIN
    -- Op_Nwk_Link_Rec_Type columns
    -- from_op_seq_id       NUMBER
    -- from_op_seq_num      NUMBER
    -- to_op_seq_Id         NUMBER
    -- transition_type      NUMBER
    -- planning_pct         NUMBER
    -- network_seq_num      NUMBER
    -- process_flag         VARCHAR2

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug( 'Getting All Links  . . .'  ) ;
END IF ;

    FOR all_links_rec IN c_All_Nwk_Links LOOP
        x_network_link_tbl(i).from_op_seq_id  := all_links_rec.from_op_seq_id;
        x_network_link_tbl(i).from_op_seq_num := all_links_rec.from_op_seq_num;
        x_network_link_tbl(i).to_op_seq_id    := all_links_rec.to_op_seq_id;
        x_network_link_tbl(i).to_op_seq_num   := all_links_rec.to_op_seq_num;
        x_network_link_tbl(i).transition_type := all_links_rec.to_op_seq_id;
        x_network_link_tbl(i).planning_pct    := all_links_rec.to_op_seq_id;
        x_network_link_tbl(i).network_seq_num := 0 ;
        x_network_link_tbl(i).process_flag    := 'C';



IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug( 'Row#'||to_char(i)  || '  FROM :  '
                               ||  to_char(x_network_link_tbl(i).from_op_seq_num)
                               ||  ' - '
                               ||  to_char(x_network_link_tbl(i).from_op_seq_id)
                               ||  ' TO :  '
                               ||  to_char(x_network_link_tbl(i).to_op_seq_num)
                               ||  ' - '
                               ||  to_char(x_network_link_tbl(i).to_op_seq_id)
                               ||  ' Process : '
                               ||  x_network_link_tbl(i).process_flag
                              );

END IF  ;

        i := i + 1;
    END LOOP;
END Get_All_Links ;

/*******************************************************************
* Procedure     : Get_All_Start_Nodes
* Parameters IN : routing_sequence_id
* Parameters OUT: x_network_link_tbl
* Purpose       : Procedure will return a PL/SQL table of
*                 Op_Nwk_Link_Tbl_Type type as OUT parameter
*                 that includes a list of all starting nodes for
*                 the routing network of eAM Maintenace Routing.
*********************************************************************/
PROCEDURE Get_All_Start_Nodes
(   p_routing_sequence_id   IN  NUMBER
 ,  x_start_op_tbl          IN OUT NOCOPY Op_Nwk_Link_Tbl_Type
)
IS

    i INTEGER := 1;

    CURSOR c_All_Start_Nodes IS
        SELECT   bon.from_op_seq_id     from_op_seq_id
               , bos1.operation_seq_num from_op_seq_num
               , bon.to_op_seq_id       to_op_seq_id
               , bos2.operation_seq_num to_op_seq_num
               , bon.transition_type    transition_type
               , bon.planning_pct       planning_pct
        FROM     BOM_OPERATION_NETWORKS bon
               , BOM_OPERATION_SEQUENCES bos1
               , BOM_OPERATION_SEQUENCES bos2
        WHERE NOT EXISTS ( SELECT NULL
                           FROM   BOM_OPERATION_NETWORKS bon2
                           WHERE  bon2.to_op_seq_id = bon.from_op_seq_id
                         )
        AND   nvl(bon.disable_date,SYSDATE+2) > SYSDATE
        AND   bon.transition_type <> 3
        AND   bos2.effectivity_date <= SYSDATE
        AND   nvl(bos2.disable_date,SYSDATE+2) > SYSDATE
        AND   bos2.routing_sequence_id = p_routing_sequence_id
        AND   bos2.operation_sequence_id = bon.to_op_seq_id
        AND   bos1.effectivity_date <= SYSDATE
        AND   nvl(bos1.disable_date,SYSDATE+2) > SYSDATE
        AND   bos1.routing_sequence_id = p_routing_sequence_id
        AND   bos1.operation_sequence_id = bon.from_op_seq_id
        ORDER BY from_op_seq_num ;


BEGIN
    -- Op_Nwk_Link_Rec_Type columns
    -- from_op_seq_id       NUMBER
    -- from_op_seq_num      NUMBER
    -- to_op_seq_id         NUMBER
    -- to_op_seq_num        NUMBER
    -- transition_type      NUMBER
    -- planning_pct         NUMBER
    -- network_seq_num      NUMBER
    -- process_flag         VARCHAR2

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug( 'Getting All start nodes . . .'  ) ;
END IF ;

    FOR all_start_nodes_rec IN c_All_Start_Nodes LOOP
        x_start_op_tbl(i).from_op_seq_id  := all_start_nodes_rec.from_op_seq_id ;
        x_start_op_tbl(i).from_op_seq_num := all_start_nodes_rec.from_op_seq_num ;
        x_start_op_tbl(i).to_op_seq_id    := all_start_nodes_rec.to_op_seq_id ;
        x_start_op_tbl(i).to_op_seq_num   := all_start_nodes_rec.to_op_seq_num ;
        x_start_op_tbl(i).transition_type := all_start_nodes_rec.transition_type ;
        x_start_op_tbl(i).planning_pct    := all_start_nodes_rec.planning_pct ;
        x_start_op_tbl(i).network_seq_num := i ;
        x_start_op_tbl(i).process_flag    := 'C';


IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug( 'Row#'||to_char(i)  || '  FROM :  '
                               ||  to_char(x_start_op_tbl(i).from_op_seq_num)
                               ||  ' - '
                               ||  to_char(x_start_op_tbl(i).from_op_seq_id)
                               ||  ' TO :  '
                               ||  to_char(x_start_op_tbl(i).to_op_seq_num)
                               ||  ' - '
                               ||  to_char(x_start_op_tbl(i).to_op_seq_id)
                               ||  ' Process : '
                               ||  x_start_op_tbl(i).process_flag
                              );

END IF  ;

        i := i + 1;
    END LOOP;
END Get_All_Start_Nodes ;


/*******************************************************************
* Procedure     : Create_Connected_Op_List
* Parameters IN : Form Op Seq Id
*                 From Op Seq Num
* Parameters OUT: Connected nodes for eAM routing network
* Purpose       : Procedure will return a PL/SQL table of
*                 Op_Nwk_Link_Tbl_Type type as OUT parameter
*                 that includes a list of all nodes for
*                 the routing network of eAM Maintenace Routing.
*********************************************************************/
FUNCTION Create_Connected_Op_List
( p_from_op_seq_id    IN  NUMBER
, p_from_op_seq_hum   IN  NUMBER
, p_network_seq_num   IN  NUMBER
, x_connected_op_tbl  IN OUT NOCOPY Op_Nwk_Link_Tbl_Type
)
RETURN BOOLEAN
IS


  i INTEGER := 2 ;
  l_from_op_seq_num NUMBER ;
  l_to_op_seq_num   NUMBER ;


  CURSOR all_connected_ops  IS
    SELECT   from_op_seq_id
           , to_op_seq_id
           , transition_type
           , planning_pct
    FROM   BOM_OPERATION_NETWORKS
    START WITH from_op_seq_id = p_from_op_seq_id
    AND    transition_type <> 3
    CONNECT BY PRIOR to_op_seq_id = from_op_seq_id
    AND    transition_type <> 3;

BEGIN
    -- create a list of connected nodes starting from the start node
    -- add the start node


    x_connected_op_tbl(1).from_op_seq_id  :=  p_from_op_seq_id ;
    x_connected_op_tbl(1).from_op_seq_num :=  p_from_op_seq_hum ;
    x_connected_op_tbl(1).process_flag    := 'S' ;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Connected op list : Start Node '
                               ||  to_char(x_connected_op_tbl(1).from_op_seq_num)
                               ||  ' - '
                               ||  to_char(x_connected_op_tbl(1).from_op_seq_id)
                              );

END IF  ;

    FOR all_connected_op_rec IN all_connected_ops LOOP
        BEGIN
            SELECT operation_seq_num
            INTO   l_from_op_seq_num
            FROM   bom_operation_sequences
            WHERE  operation_sequence_id =
                       all_connected_op_rec.from_op_seq_id ;

            SELECT operation_seq_num
            INTO   l_to_op_seq_num
            FROM   bom_operation_sequences
            WHERE  operation_sequence_id =
                       all_connected_op_rec.to_op_seq_id ;


         END ;

         x_connected_op_tbl(i).from_op_seq_id  := all_connected_op_rec.from_op_seq_id;
         x_connected_op_tbl(i).from_op_seq_num := l_from_op_seq_num ;
         x_connected_op_tbl(i).to_op_seq_id    := all_connected_op_rec.to_op_seq_id;
         x_connected_op_tbl(i).to_op_seq_num   := l_to_op_seq_num ;
         x_connected_op_tbl(i).transition_type := all_connected_op_rec.transition_type;
         x_connected_op_tbl(i).planning_pct    := all_connected_op_rec.planning_pct ;
         x_connected_op_tbl(i).network_seq_num := p_network_seq_num ;
         x_connected_op_tbl(i).process_flag    := 'C' ;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug( 'Row#'||to_char(i)  || '  FROM :  '
                               ||  to_char(x_connected_op_tbl(i).from_op_seq_num)
                               ||  ' - '
                               ||  to_char(x_connected_op_tbl(i).from_op_seq_id)
                               ||  ' TO :  '
                               ||  to_char(x_connected_op_tbl(i).to_op_seq_num)
                               ||  ' - '
                               ||  to_char(x_connected_op_tbl(i).to_op_seq_id)
                              );

END IF  ;

         i := i + 1;

    END LOOP;


    RETURN TRUE ;

EXCEPTION
    WHEN NO_DATA_FOUND THEN

         RETURN TRUE ;

    WHEN OTHERS THEN
         IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
           Error_Handler.Write_Debug
              ( 'When creating connected op list, Some unknown error in Check Access. . .' || SQLERRM  ) ;
         END IF  ;

         --  RETURN FALSE ;
         --  This error can be catched in following processes.

         RETURN TRUE ;

END Create_Connected_Op_List ;


/*******************************************************************
* Fucntion      : IsConnected
* Return        : BOOLEAN
* Parameters IN : Connected Op Tbl
*                 Master Op Tbl
* Parameters OUT: None
* Purpose       : Function to to see if there are any rows common
*                 in the two tables.
*                 i.e. if the two tables are connected.
*                 TRUE, if connected table is connected to master tble;
*                 FALSE, otherwise.
*********************************************************************/
FUNCTION IsConnected
( p_connected_op_tbl  IN Op_Nwk_Link_Tbl_Type
, p_master_op_tbl     IN Op_Nwk_Link_Tbl_Type
)
RETURN BOOLEAN
IS
  i NUMBER ;
  j NUMBER ;

BEGIN

    FOR i IN 1..p_master_op_tbl.COUNT LOOP
        FOR j IN 1..p_connected_op_tbl.COUNT LOOP
            IF    p_master_op_tbl(i).from_op_seq_num
                        = p_connected_op_tbl(j).from_op_seq_num
            AND   p_connected_op_tbl(j).process_flag = 'C'
            THEN
                RETURN (TRUE);
            END IF;
        END LOOP;
     END LOOP;

     RETURN (FALSE);

END IsConnected ;


/*******************************************************************
* Fucntion      : CheckOpNwkNodeExists
* Parameters IN :
*                 Master Op Tbl
* Parameters OUT: None
* Purpose       : This procedure appends Connected Op Tbl to
*                 Master OP tbl making sure that there is no redundancy,
*                 and then return the master list of the connected nodes
*********************************************************************/
FUNCTION CheckOpNwkNodeExists
( p_from_op_seq_num  IN  NUMBER
, p_to_op_seq_num    IN  NUMBER
, p_op_nwk_tbl       IN  Op_Nwk_Link_Tbl_Type
) RETURN BOOLEAN
IS

    i NUMBER ;

BEGIN
    FOR i IN 1..p_op_nwk_tbl.COUNT LOOP
        IF   p_op_nwk_tbl(i).from_op_seq_num = p_from_op_seq_num
        AND  p_op_nwk_tbl(i).to_op_seq_num = p_to_op_seq_num
        THEN
               RETURN (TRUE);
        END IF;
    END LOOP;

    RETURN (FALSE);

END CheckOpNwkNodeExists ;



/*******************************************************************
* Procedure     : AppendToMasterList
* Parameters IN : Connected Op Tbl
*                 Master Op Tbl
* Parameters OUT: None
* Purpose       : This procedure appends Connected Op Tbl to
*                 Master OP tbl making sure that there is no redundancy,
*                 and then return the master list of the connected nodes
*********************************************************************/
PROCEDURE AppendToMasterList
( p_connected_op_tbl  IN   Op_Nwk_Link_Tbl_Type
, p_master_op_tbl     IN   Op_Nwk_Link_Tbl_Type
, x_master_op_tbl     IN OUT NOCOPY Op_Nwk_Link_Tbl_Type
)
IS

  i     NUMBER ;
  mst_c NUMBER ;

BEGIN
    x_master_op_tbl := p_master_op_tbl ;
    mst_c := x_master_op_tbl.COUNT + 1 ;


IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Appending an op link to master op list . .' );
END IF  ;


    FOR i IN 1..p_connected_op_tbl.COUNT LOOP

        IF NOT CheckOpNwkNodeExists
               ( p_from_op_seq_num => p_connected_op_tbl(i).from_op_seq_num
               , p_to_op_seq_num   => p_connected_op_tbl(i).to_op_seq_num
               , p_op_nwk_tbl      => x_master_op_tbl
               )
        AND    p_connected_op_tbl(i).process_flag <> 'S'
        THEN
            x_master_op_tbl(mst_c).from_op_seq_id :=
                  p_connected_op_tbl(i).from_op_seq_id  ;
            x_master_op_tbl(mst_c).from_op_seq_num :=
                  p_connected_op_tbl(i).from_op_seq_num ;
            x_master_op_tbl(mst_c).to_op_seq_id :=
                  p_connected_op_tbl(i).to_op_seq_id ;
            x_master_op_tbl(mst_c).to_op_seq_num :=
                  p_connected_op_tbl(i).to_op_seq_num ;
            x_master_op_tbl(mst_c).transition_type :=
                  p_connected_op_tbl(i).transition_type ;
            x_master_op_tbl(mst_c).planning_pct :=
                  p_connected_op_tbl(i).planning_pct ;
            x_master_op_tbl(mst_c).network_seq_num :=
                  p_connected_op_tbl(i).network_seq_num ;
            x_master_op_tbl(mst_c).process_flag :=
                  p_connected_op_tbl(i).process_flag ;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug( 'Row#'||to_char(mst_c)  || '  FROM :  '
                               ||  to_char(x_master_op_tbl(mst_c).from_op_seq_num)
                               ||  ' - '
                               ||  to_char(x_master_op_tbl(mst_c).from_op_seq_id)
                               ||  ' TO :  '
                               ||  to_char(x_master_op_tbl(mst_c).to_op_seq_num)
                               ||  ' - '
                               ||  to_char(x_master_op_tbl(mst_c).to_op_seq_id)
                               ||  ' Process : '
                               ||  x_master_op_tbl(mst_c).process_flag
                               ||  ' Nwk Seq : '
                               ||  to_char(x_master_op_tbl(mst_c).network_seq_num)
                              );

END IF  ;


           mst_c := mst_c + 1;
        END IF;
    END LOOP;

END AppendToMasterList ;




/*******************************************************************
* Function      : GetTopRefPointer
* Parameters IN : Op Nwk Link tbl
* Parameters OUT: None
* Purpose       : This function will get the reference position
*                 which is the first row from the top of the table
*                 with flag = 'C'.
*                 Then It will return reference, if there exists
*                 rows with flag = 'C';  otherwise -1.
*********************************************************************/
FUNCTION GetTopRefPointer
( p_network_link_tbl  IN   Op_Nwk_Link_Tbl_Type )
RETURN NUMBER
IS

BEGIN
     FOR i IN 1..p_network_link_tbl.COUNT LOOP
         IF p_network_link_tbl(i).process_flag = 'C' THEN
            RETURN (i);
         END IF;
     END LOOP;
     RETURN (-1);
END GetTopRefPointer ;


/*******************************************************************
* Function      : GetBottomRefPointer
* Parameters IN : Op Nwk Link tbl
* Parameters OUT: None
* Purpose       : This function will get the reference position
*                 which is the first row from the bottom of the table
*                 with flag = 'C'.
*                 Then It will return reference, if there exists
*                 rows with flag = 'C';  otherwise -1.
*********************************************************************/
FUNCTION GetBottomRefPointer
( p_network_link_tbl  IN   Op_Nwk_Link_Tbl_Type )
RETURN NUMBER
IS

BEGIN
     FOR i IN REVERSE 1..p_network_link_tbl.COUNT LOOP
         IF p_network_link_tbl(i).process_flag = 'C' THEN
            RETURN (i);
         END IF;
     END LOOP;
     RETURN (-1);
END GetBottomRefPointer ;

/*******************************************************************
* Procedure     : CheckLoopNwk
* Parameters IN : Op Network Tbl Tbl
*                 Master Op Tbl
* Parameters OUT: None
* Purpose       : This procedure will check if loop exists.
*********************************************************************/
FUNCTION CheckLoopNwk
( p_network_link_tbl  IN   Op_Nwk_Link_Tbl_Type )
RETURN BOOLEAN
IS
    l_network_link_tbl Op_Nwk_Link_Tbl_Type  ;
    l_top_ptr      NUMBER ;
    l_bot_ptr      NUMBER ;
    l_connected    NUMBER ;
    l_flag_changed NUMBER ;

BEGIN
    l_network_link_tbl := p_network_link_tbl ;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Within CheckLoopAPI . . .');
END IF;

    -- Get the top and bottom reference pointers
    l_top_ptr :=  GetTopRefPointer( l_network_link_tbl ) ;
    l_bot_ptr :=  GetBottomRefPointer( l_network_link_tbl ) ;


IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Get op network node. top_ptr: '
                              || to_char(l_top_ptr)
                              || ' - '  ||  'bot_ptr: '|| to_char(l_bot_ptr));
END IF;

    -- Initialize chang flag
    l_flag_changed := 1 ;

    -- While there are rows with flag='C'
    WHILE (l_top_ptr <> -1 and l_bot_ptr <> -1 and l_flag_changed = 1) LOOP
        l_flag_changed := 0;
        FOR i IN 1..l_network_link_tbl.COUNT LOOP
            IF l_network_link_tbl(i).process_flag = 'C' THEN
                l_connected := 0;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('in loop1 :'||to_char(i)||' time');
END IF;

                FOR j IN 1..l_network_link_tbl.COUNT LOOP
                    IF l_network_link_tbl(i).from_op_seq_id
                           = l_network_link_tbl(j).to_op_seq_id
                    AND l_network_link_tbl(j).process_flag = 'C'
                    THEN
                        l_connected := 1 ;
                   END IF;
                END LOOP;

                IF (l_connected = 0) THEN
                    l_network_link_tbl(i).process_flag := 'D';
                    l_flag_changed := 1;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Changing row#'||to_char(i)||' '||'flag to D');
END IF;

                END IF;
            END IF;
        END LOOP;

        -- Get the top and bottom reference pointers
        l_top_ptr :=  GetTopRefPointer( l_network_link_tbl ) ;
        l_bot_ptr :=  GetBottomRefPointer( l_network_link_tbl ) ;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('top_ptr:'|| to_char(l_top_ptr));
    Error_Handler.Write_Debug('bot_ptr:'|| to_char(l_bot_ptr));
END IF;


        l_flag_changed := 0;
        IF (l_top_ptr <> -1 and l_bot_ptr <> -1) THEN
            FOR i IN REVERSE l_top_ptr..l_bot_ptr LOOP
                IF l_network_link_tbl(i).process_flag = 'C' THEN
                    l_connected := 0;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('in loop2 :'||to_char(i)||' time');
END IF;


                    FOR j IN REVERSE l_top_ptr..l_bot_ptr LOOP
                        IF  l_network_link_tbl(i).to_op_seq_id
                              = l_network_link_tbl(j).from_op_seq_id
                        AND l_network_link_tbl(j).process_flag = 'C'
                        THEN
                            l_connected := 1;
                        END IF;
                    END LOOP;

                    IF (l_connected = 0) THEN
                        l_network_link_tbl(i).process_flag := 'D';
                        l_flag_changed := 1;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Changing row#'||to_char(i)||' '||'flag to D');
END IF;
                    END IF;
                END IF;
            END LOOP;
        END IF;

        -- Get the top and bottom reference pointers
        l_top_ptr :=  GetTopRefPointer( l_network_link_tbl ) ;
        l_bot_ptr :=  GetBottomRefPointer( l_network_link_tbl ) ;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('top_ptr:'|| to_char(l_top_ptr));
    Error_Handler.Write_Debug('bot_ptr:'|| to_char(l_bot_ptr));
END IF;

   END LOOP; -- while

   IF (l_top_ptr <> -1 or l_bot_ptr <> -1) THEN

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Error. A loop has been detected');
END IF;

       RETURN FALSE ;
   END IF;

   RETURN TRUE ;

END CheckLoopNwk ;



/*******************************************************************
* Procedure     : Check_Eam_Rtg_Network
* Parameters IN : Routing Sequence_id
* Parameters OUT: Error Code
*                 Return Status
* Purpose       : Procedure will validate for eAM Rtg Network.
*                 This procedure is called by Routing BO and BOMFDONW form
*********************************************************************/
PROCEDURE Check_Eam_Rtg_Network
( p_routing_sequence_id IN  NUMBER
, x_err_msg             IN OUT NOCOPY VARCHAR2
, x_return_status       IN OUT NOCOPY VARCHAR2
 )
IS
    l_network_link_tbl  Op_Nwk_Link_Tbl_Type ;
    l_each_nwk_link_tbl Op_Nwk_Link_Tbl_Type ;
    l_start_op_tbl      Op_Nwk_Link_Tbl_Type ;
    l_connected_op_tbl  Op_Nwk_Link_Tbl_Type ;
    l_master_op_tbl     Op_Nwk_Link_Tbl_Type ;
    l_LoopIndex         NUMBER ;
    nwk_c               NUMBER ;
    l_mst_c             NUMBER ;
    l_seq_num           NUMBER ;
    l_connected_flag    BOOLEAN ;

BEGIN

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Within eAM Rtg Network validation API. . . ');
END IF;


    -- Return Status
    -- Success : FND_API.G_RET_STS_SUCCESS
    -- Error   : FND_API.G_RET_STS_ERROR
    -- Unexpected Error : G_RET_STS_UNEXP_ERROR

    x_return_status := FND_API.G_RET_STS_SUCCESS ;

    -- Check if valid eAM routing network exists
    IF NOT CheckNwkExists( p_routing_sequence_id => p_routing_sequence_id )
    THEN
        FND_MESSAGE.SET_NAME('BOM','BOM_EAM_NO_NETWORK_EXIST');
        x_err_msg:= FND_MESSAGE.GET;
        -- Commented as part of bug#3460975. This is not an error. It should be treated as warning
        -- because a routing may or may not have a link.
        -- x_return_status := FND_API.G_RET_STS_ERROR ;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Check if Op Network exists. . . ' || x_return_status );
END IF;

        -- Commented as part of bug#3460975. Since this is a warning don't return.
        -- RETURN ;
    END IF;


IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Get network info and import the data into the PL/SQL table . . . ' );
END IF;

    Get_All_Links
    (   p_routing_sequence_id  => p_routing_sequence_id
     ,  x_network_link_tbl     => l_network_link_tbl
    ) ;

    Get_All_Start_Nodes
    (  p_routing_sequence_id  => p_routing_sequence_id
     , x_start_op_tbl         => l_start_op_tbl
    ) ;


    -- Check for BROKEN LINKS
IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Check for broken links. . . ' );
END IF;

    -- In each start node, get the nodes connected to,then compare with
    -- the master list to see if there is any common node i.e. connected.
    -- if there is, add the nodes to the master list. if there is none,
    -- this is the broken link; print the broken link.

    FOR i IN 1..l_start_op_tbl.COUNT LOOP

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Creating connected op list : '
                               || to_char(l_start_op_tbl(i).from_op_seq_num)
                               ||  ' - '
                               || to_char(l_start_op_tbl(i).from_op_seq_id)
                              );

END IF  ;

         -- add the starting node into the Master list
         IF NOT CheckOpNwkNodeExists
               ( p_from_op_seq_num => l_start_op_tbl(i).from_op_seq_num
               , p_to_op_seq_num   => l_start_op_tbl(i).to_op_seq_num
               , p_op_nwk_tbl      => l_master_op_tbl
               )
         THEN
                l_mst_c := l_master_op_tbl.COUNT + 1 ;
                l_master_op_tbl(l_mst_c).from_op_seq_id  := l_start_op_tbl(i).from_op_seq_id;
                l_master_op_tbl(l_mst_c).from_op_seq_num := l_start_op_tbl(i).from_op_seq_num;
                l_master_op_tbl(l_mst_c).process_flag      := 'S' ;
                l_master_op_tbl(l_mst_c).network_seq_num   := i ;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Added start node to Master Op Nwk Tbl . . . ' );
    Error_Handler.Write_Debug('Mst : Row# ' || to_char(l_mst_c) || ' = '
                                            || to_char(l_master_op_tbl(l_mst_c).from_op_seq_num)
                                            ||  ' - ' || to_char(l_master_op_tbl(l_mst_c).from_op_seq_id)
                              );
END IF;


         END IF;


        l_connected_flag :=
        Create_Connected_Op_List
        (   p_from_op_seq_id   => l_start_op_tbl(i).from_op_seq_id
          , p_from_op_seq_hum  => l_start_op_tbl(i).from_op_seq_num
          , p_network_seq_num  => i
          , x_connected_op_tbl => l_connected_op_tbl
        ) ;

        IF NOT l_connected_flag THEN

            FND_MESSAGE.SET_NAME('BOM','BOM_EAM_RTG_INVALID_LINK_EXIST');
            x_err_msg:= FND_MESSAGE.GET;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            RETURN ;

        END IF ;

        IF IsConnected(l_connected_op_tbl, l_master_op_tbl) THEN

            -- add the nodes to the master list
            AppendToMasterList
            ( p_connected_op_tbl  => l_connected_op_tbl
            , p_master_op_tbl     => l_master_op_tbl
            , x_master_op_tbl     => l_master_op_tbl
            ) ;

            -- delete the connected list for re-use
            l_connected_op_tbl.DELETE;

        ELSE
            FND_MESSAGE.SET_NAME('BOM','BOM_RTG_NTWK_BROKEN_LINK_EXIST');
            x_err_msg:= FND_MESSAGE.GET;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            RETURN ;
        END IF;
    END LOOP;


IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Check all links in l_network_link_tbl exists in Master Op Tbl. . . ' );
END IF;

    -- Check all links in l_network_link_tbl exists in Master Op Tbl
    FOR i IN 1..l_network_link_tbl.COUNT
    LOOP

        IF NOT CheckOpNwkNodeExists
               ( p_from_op_seq_num => l_network_link_tbl(i).from_op_seq_num
               , p_to_op_seq_num   => l_network_link_tbl(i).to_op_seq_num
               , p_op_nwk_tbl      => l_master_op_tbl
               )
        THEN

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Error Broken Link exists on Nwk Row#  '
                             ||  to_char(i) || ' - FROM : '
                             ||  to_char(l_network_link_tbl(i).from_op_seq_num)
                             ||  ' TO : '
                             ||  to_char(l_network_link_tbl(i).to_op_seq_num)
                              );
END IF;

            FND_MESSAGE.SET_NAME('BOM','BOM_EAM_RTG_INVALID_LINK_EXIST');
            x_err_msg:= FND_MESSAGE.GET;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            RETURN ;
        END IF ;
    END LOOP ;


IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Check all connected links in Master Op tbl exists in all links. . . ' );
END IF;

    -- Check all connected links in Master Op tbl exists in all links
    FOR i IN 1..l_master_op_tbl.COUNT
    LOOP

        IF NOT CheckOpNwkNodeExists
               ( p_from_op_seq_num => l_master_op_tbl(i).from_op_seq_num
               , p_to_op_seq_num   => l_master_op_tbl(i).to_op_seq_num
               , p_op_nwk_tbl      => l_network_link_tbl
               )
        AND  l_master_op_tbl(i).process_flag <> 'S'
        THEN

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Error Broken Link exists on Master Row#  '
                             ||  to_char(i) || ' - '
                             ||  to_char(l_master_op_tbl(i).from_op_seq_num)
                              );
END IF;

            FND_MESSAGE.SET_NAME('BOM','BOM_EAM_RTG_INVALID_LINK_EXIST');
            x_err_msg:= FND_MESSAGE.GET;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            RETURN ;
        END IF ;
    END LOOP ;


    -- Check for Loops
IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Check for loops. . . ' );
END IF;


    -- get a group of network links from master op tbl for multiple start node.
    -- Initialize flag
    nwk_c := 1 ;
    l_seq_num := 1 ;

    -- Check for Loops
IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Get a group of network links from master op tbl for multiple start node. . . ' );
END IF;


    FOR  i IN 1..l_master_op_tbl.COUNT
    LOOP


        -- When Nwk Seq num is chanaged, check loop.
        IF  l_seq_num <> l_master_op_tbl(i).network_seq_num
        AND l_master_op_tbl(i).process_flag <> 'S'
        THEN
            -- Check loop

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('When nwk seq is changed, Check Loop for Network Link Seq Num ' || to_char(l_seq_num)  );
END IF;
            IF CheckLoopNwk (p_network_link_tbl => l_each_nwk_link_tbl)
            THEN
                -- Initialize nwk_c counter and l_each_nwk_link_tbl
                nwk_c := 1 ;
                l_each_nwk_link_tbl.DELETE ;

            ELSE


IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Loop exists in operation network : seq =  ' || to_char(l_seq_num)  );
END IF;

                FND_MESSAGE.SET_NAME('BOM','BOM_RTG_NTWK_LOOP_EXISTS');
                x_err_msg:= FND_MESSAGE.GET;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                RETURN ;
            END IF ;

        END IF ;


        IF  l_master_op_tbl(i).process_flag <> 'S'
        THEN

            l_each_nwk_link_tbl(nwk_c).from_op_seq_id :=
                  l_master_op_tbl(i).from_op_seq_id  ;
            l_each_nwk_link_tbl(nwk_c).from_op_seq_num :=
                  l_master_op_tbl(i).from_op_seq_num ;
            l_each_nwk_link_tbl(nwk_c).to_op_seq_id :=
                  l_master_op_tbl(i).to_op_seq_id ;
            l_each_nwk_link_tbl(nwk_c).to_op_seq_num :=
                  l_master_op_tbl(i).to_op_seq_num ;
            l_each_nwk_link_tbl(nwk_c).transition_type :=
                  l_master_op_tbl(i).transition_type ;
            l_each_nwk_link_tbl(nwk_c).planning_pct :=
                  l_master_op_tbl(i).planning_pct ;
            l_each_nwk_link_tbl(nwk_c).network_seq_num :=
                  l_master_op_tbl(i).network_seq_num ;
            l_each_nwk_link_tbl(nwk_c).process_flag :=
                  l_master_op_tbl(i).process_flag ;

            l_seq_num := l_master_op_tbl(i).network_seq_num ;
            nwk_c := nwk_c + 1 ;
        END IF ;

    END LOOP ;

    -- Check Loop
IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('At the end of loop validation, Check loops for rest of network : seq = '
                              || to_char(l_seq_num)  );
END IF ;

    IF CheckLoopNwk (p_network_link_tbl => l_each_nwk_link_tbl)
    THEN
         l_each_nwk_link_tbl.DELETE ;

    ELSE

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Loop exists in operation network : seq =  '
                              || to_char(l_seq_num)  );
END IF ;

         FND_MESSAGE.SET_NAME('BOM','BOM_RTG_NTWK_LOOP_EXISTS');
         x_err_msg:= FND_MESSAGE.GET;
         x_return_status := FND_API.G_RET_STS_ERROR ;
         RETURN ;
    END IF ;



END Check_Eam_Rtg_Network ;


/*******************************************************************
* Procedure     : Check_Eam_Rtg_Network
* Parameters IN : Operation Network Exposed Record
*                 Operation Network Unexposed Record
*                 Old Operation Network exposed Record
*                 Old Operation Network Unexposed Record
*                 Mesg Token Table
* Parameters OUT: Mesg Token Table
*                 Return Status
* Purpose       : Procedure will validate for eAM Rtg Network.
*                 This procedure is called by Routing BO and BOMFDONW form
*********************************************************************/
PROCEDURE Check_Eam_Rtg_Network
(  p_op_network_rec       IN  Bom_Rtg_Pub.Op_Network_Rec_Type
 , p_op_network_unexp_rec IN  Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
 , p_old_op_network_rec   IN  Bom_Rtg_Pub.Op_Network_Rec_Type
 , p_old_op_network_unexp_rec IN  Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
 , p_mesg_token_tbl       IN  Error_Handler.Mesg_Token_Tbl_Type
 , x_mesg_token_tbl       IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status        IN OUT NOCOPY VARCHAR2
 )
IS

    l_token_tbl      Error_Handler.Token_Tbl_Type;
    l_mesg_token_tbl Error_Handler.Mesg_Token_Tbl_Type;
    l_return_status  VARCHAR2(1);
    l_cfm_flag       NUMBER ;

BEGIN

NULL ;

END Check_Eam_Rtg_Network ;




/*******************************************************************
* Procedure     : Check_Eam_Nwk_FromOp
* Parameters IN : From Op Seq Num
*                 From Op Seq Id
*                 To Op Seq Num
*                 To Op Seq Id
* Parameters OUT: Error Code
*                 Return Status
* Purpose       : Procedure will validate for from operation in eAM Rtg Network.
*********************************************************************/
PROCEDURE Check_Eam_Nwk_FromOp
( p_from_op_seq_num     IN  NUMBER
, p_from_op_seq_id      IN  NUMBER
, p_to_op_seq_num       IN  NUMBER
, p_to_op_seq_id        IN  NUMBER
, x_err_msg             IN OUT NOCOPY VARCHAR2
, x_return_status       IN OUT NOCOPY VARCHAR2
 )
IS

        Cursor c_op_network  (  P_From_Op_Seq_Id number
                              , P_To_Op_Seq_Id number)
        IS
        SELECT 'x' dummy
        FROM DUAL
        WHERE EXISTS
        ( SELECT NULL
          FROM   bom_operation_networks a
          WHERE  a.from_op_seq_id = P_From_Op_Seq_Id
          AND    a.to_op_seq_id   <>   P_To_Op_Seq_Id
          AND    a.transition_type = 1
        );

BEGIN

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Within eAM Rtg Network from operation validation API. . . ');
END IF;


    -- Return Status
    -- Success : FND_API.G_RET_STS_SUCCESS
    -- Error   : FND_API.G_RET_STS_ERROR
    -- Unexpected Error : G_RET_STS_UNEXP_ERROR

    x_return_status := FND_API.G_RET_STS_SUCCESS ;

    FOR l_opnet_rec in c_op_network
        ( P_From_Op_Seq_Id => p_from_op_seq_id,
          P_To_Op_Seq_Id   => p_to_op_seq_id
        )
    LOOP


IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('from operation is duplicate in operation network : seq =  '
                              || to_char(p_from_op_seq_num)  );
END IF ;

         FND_MESSAGE.SET_NAME('BOM','BOM_OP_NWK_PMOP_NOTUNIQUE');
         FND_MESSAGE.SET_TOKEN('FROM_OP_SEQ_NUMBER', p_from_op_seq_num) ;
         x_err_msg:= FND_MESSAGE.GET;
         x_return_status := FND_API.G_RET_STS_ERROR ;

    END LOOP ;



END Check_Eam_Nwk_FromOp ;


/***************************************************************************
* Function      : OrgIsEamEnabled
* Returns       : VARCHAR2
* Parameters IN : p_org_id
* Parameters OUT: None
* Purpose       : Function will return the value of 'Y' or 'N'
*                 to check if organization is eAM enabled.
*****************************************************************************/
FUNCTION OrgIsEamEnabled(p_org_id NUMBER) RETURN VARCHAR2
IS

    CURSOR GetEamEnabledFlag IS
     SELECT NVL(eam_enabled_flag, 'N') eam_enabled_flag
     FROM   mtl_parameters
     WHERE  organization_id = p_org_id ;


     x_eam_enabled_flag VARCHAR2(1) ;

BEGIN

   FOR X_Eam in GetEamEnabledFlag LOOP
      x_eam_enabled_flag := X_Eam.eam_enabled_flag ;
   END LOOP;

   RETURN x_eam_enabled_flag ;

END OrgIsEamEnabled  ;

/***************************************************************************
* Function      : CheckShutdownType
* Returns       : BOOLEAN
* Parameters IN : p_shutdown_type
* Parameters OUT: None
* Purpose       : Function will return the value of True or False
*                 to check if ShutdownType is valid.
*****************************************************************************/
FUNCTION CheckShutdownType(p_shutdown_type IN VARCHAR2 )
RETURN BOOLEAN
IS

    CURSOR CheckShutdownTypeCode IS
     SELECT 'Valid'
     FROM   MFG_LOOKUPS
     WHERE  lookup_code = TO_NUMBER(p_shutdown_type)
     AND    lookup_type =  'BOM_EAM_SHUTDOWN_TYPE' ;



BEGIN

   FOR X_Shutdown in CheckShutdownTypeCode LOOP
      RETURN TRUE ;
   END LOOP;

   RETURN FALSE ;

END CheckShutdownType ;


/***************************************************************************
* Function      : Check_UpdateDept
* Returns       : BOOLEAN
* Parameters IN : p_op_seq_id, p_org_id, p_dept_id
* Parameters OUT: None
* Purpose       : Function will return the value of True or False
*                 to check if user can update the department for this operation.
*****************************************************************************/
FUNCTION Check_UpdateDept
( p_op_seq_id     IN   NUMBER
, p_org_id        IN   NUMBER
, p_dept_id       IN   NUMBER
)
RETURN BOOLEAN
IS

    CURSOR  Check_DeptResource IS
       SELECT 'This dept is updatable'
       FROM  BOM_DEPARTMENTS bd
       WHERE trunc(nvl(bd.disable_date, sysdate + 1)) > trunc(sysdate)
       AND   bd.department_id   = p_dept_id
       AND   bd.organization_id = p_org_id
       AND   (
               -- (NOT EXISTS (SELECT NULL
               --             FROM BOM_OPERATION_RESOURCES bor
               --             WHERE bor.operation_sequence_id = NVL(p_op_seq_id, -1)
               --         )
              --  ) OR
              ( NOT EXISTS ( SELECT  'Dept Invalid'
                             FROM   BOM_OPERATION_RESOURCES bor2
                             WHERE  bor2.operation_sequence_id = NVL(p_op_seq_id,-1)
                             AND    NOT EXISTS (SELECT 'x'
                                                FROM    BOM_DEPARTMENT_RESOURCES bdr
                                                WHERE   bdr.department_id = bd.department_id
                                                AND     bdr.resource_id   =  bor2.resource_id)
                           )
               )
             ) ;

BEGIN

   FOR X_EamDept  IN Check_DeptResource LOOP
      RETURN TRUE ;
   END LOOP;

   RETURN FALSE ;

END Check_UpdateDept ;


/******************************************************************
* Procedure     : Op_Node_Check_Existence
* Parameters IN : Operation node record
* Parameters OUT: Old operation node record
*                 Return Mesg
*                 Return Status
* Purpose       : Op_Node_Check_Existence will query using the primary key
*                 information and return a success if the operation is
*                 CREATE and the record EXISTS or will return an
*                 error if the operation is UPDATE and record DOES NOT
*                 EXIST.
*                 In case of UPDATE if record exists, then the procedure
*                 will return old record in the old entity parameters
*                 with a success status.
*********************************************************************/
PROCEDURE Op_Node_Check_Existence
(  p_op_node_rec           IN  Bom_Rtg_Eam_Util.Op_Node_Rec_Type
,  x_old_op_node_rec       IN OUT NOCOPY Bom_Rtg_Eam_Util.Op_Node_Rec_Type
,  x_return_mesg           IN OUT NOCOPY VARCHAR2
,  x_return_status         IN OUT NOCOPY VARCHAR2
)
IS
   l_return_mesg    VARCHAR2(2000) ;
   l_return_status  VARCHAR2(1);


   /* Define Cursor */
   Cursor op_node_csr( p_operation_sequence_id NUMBER )
   IS
   SELECT  X_COORDINATE
         , Y_COORDINATE
   FROM BOM_OPERATION_SEQUENCES
   WHERE  operation_sequence_id = p_operation_sequence_id ;

   op_node_rec  op_node_csr%ROWTYPE ;

BEGIN

   --  Init local table variables.
   x_return_status    := FND_API.G_RET_STS_SUCCESS ;
   l_return_status    := FND_API.G_RET_STS_SUCCESS ;


IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug
      ('Querying an operation sequence record : Seq ID '
                 || to_char(p_op_node_rec.operation_sequence_id ) || '. . . ' ) ;
END IF ;

   -- Query Operation Row
   IF NOT op_node_csr%ISOPEN
   THEN
      OPEN op_node_csr( p_operation_sequence_id
                       => p_op_node_rec.operation_sequence_id ) ;
   END IF ;

   FETCH op_node_csr INTO op_node_rec ;

   IF op_node_csr%FOUND
   THEN
      -- SetQueried Record to Op Node Recourd
      x_old_op_node_rec.X_Coordinate := op_node_rec.X_Coordinate ;
      x_old_op_node_rec.Y_Coordinate := op_node_rec.Y_Coordinate ;


IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Finished querying and assigning operation node record . . .') ;
END IF  ;

      l_return_status     := BOM_Rtg_Globals.G_RECORD_FOUND ;

   ELSE

      l_return_status     := BOM_Rtg_Globals.G_RECORD_NOT_FOUND ;

   END IF ;

   IF op_node_csr%ISOPEN
   THEN
      CLOSE op_node_csr ;
   END IF ;


   IF l_return_status = BOM_Rtg_Globals.G_RECORD_FOUND AND
          p_op_node_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
   THEN
          l_return_mesg :=  'BOM_OP_ALREADY_EXISTS' ;
          l_return_status := FND_API.G_RET_STS_ERROR ;

   ELSIF l_return_status = BOM_Rtg_Globals.G_RECORD_NOT_FOUND AND
             p_op_node_rec.transaction_type IN
             (BOM_Rtg_Globals.G_OPR_UPDATE,
              BOM_Rtg_Globals.G_OPR_DELETE )
   THEN
          l_return_mesg :=  'BOM_OP_DOESNOT_EXIST' ;
          l_return_status := FND_API.G_RET_STS_ERROR ;

   ELSE
          l_return_status := FND_API.G_RET_STS_SUCCESS;

   END IF ;


    x_return_status  := l_return_status;
    x_return_mesg    := l_return_mesg ;

EXCEPTION
   WHEN OTHERS THEN
      x_return_mesg := G_PKG_NAME || ' Operation Node Check Existence '
                                 || substrb(SQLERRM,1,200);

--    dbms_output.put_line('Unexpected Error: '||l_err_text);

      x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR ;


END Op_Node_Check_Existence ;


/*******************************************************************
* Procedure : Op_Node_Populate_Null_Columns
* Parameters IN : Operation Node column record
*                 Old Operation Node column record
* Parameters OUT: Operation Node column record after populating null columns
* Purpose   : Complete record will compare the database record with
*             the user given record and will complete the user
*             record with values from the database record, for all
*             columns that the user has left NULL.
********************************************************************/
PROCEDURE Op_Node_Populate_Null_Columns
(  p_op_node_rec           IN  Bom_Rtg_Eam_Util.Op_Node_Rec_Type
,  p_old_op_node_rec       IN  Bom_Rtg_Eam_Util.Op_Node_Rec_Type
,  x_op_node_rec           IN OUT NOCOPY Bom_Rtg_Eam_Util.Op_Node_Rec_Type
)
IS


BEGIN


     IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
         ('Within the Operation Node Populate null columns...') ;
     END IF ;

     --  Initialize operation exp and unexp record
     x_op_node_rec  := p_op_node_rec ;


     IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
                 ('Populate null exposed columns......') ;
     END IF ;


     IF x_op_node_rec.X_Coordinate IS NULL
     THEN
         x_op_node_rec.X_Coordinate := p_old_op_node_rec.X_Coordinate ;
     END IF ;

     IF x_op_node_rec.Y_Coordinate IS NULL
     THEN
         x_op_node_rec.Y_Coordinate := p_old_op_node_rec.Y_Coordinate ;
     END IF ;

END Op_Node_Populate_Null_Columns ;


/********************************************************************
* Procedure : Op_Node_Entity_Defaulting
* Parameters IN : Operation Node column record
* Parameters OUT: Operation Node column record after defaulting
*                 Return Message
*                 Return Status
* Purpose   : Entity defaulting proc. defualts columns to
*             appropriate values.
*********************************************************************/
PROCEDURE Op_Node_Entity_Defaulting
(  p_op_node_rec           IN  Bom_Rtg_Eam_Util.Op_Node_Rec_Type
,  x_op_node_rec           IN OUT NOCOPY Bom_Rtg_Eam_Util.Op_Node_Rec_Type
,  x_return_mesg           IN OUT NOCOPY VARCHAR2
,  x_return_status         IN OUT NOCOPY VARCHAR2
)
IS


BEGIN

        IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
            ('Within the Operation Node Entity Defaulting...') ;
        END IF ;

        x_op_node_rec   := p_op_node_rec ;
        x_return_status := FND_API.G_RET_STS_SUCCESS ;


        IF x_op_node_rec.X_Coordinate = FND_API.G_MISS_NUM
        THEN
            x_op_node_rec.X_Coordinate := NULL ;
        END IF ;

        IF x_op_node_rec.Y_Coordinate = FND_API.G_MISS_NUM
        THEN
            x_op_node_rec.Y_Coordinate := NULL ;
        END IF ;


EXCEPTION
    WHEN OTHERS THEN
          IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Some unknown error in Op Node Entity Defaulting . . .' || SQLERRM );
          END IF ;


          x_return_mesg := G_PKG_NAME || ' Defaulting (Op Node Entity Defaulting) '
                                || substrb(SQLERRM,1,200);
          -- dbms_output.put_line('Unexpected Error: '||l_err_text);

          -- Return the status and message table.
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Op_Node_Entity_Defaulting ;


/******************************************************************
* Procedure : Op_Node_Check_Entity
* Parameters IN : Operation Node column record
*                 Old Operation Node column record
* Parameters OUT: Return Message
*                 Return Status
* Purpose   :     Check_Entity validate the entity for the correct
*                 business logic. It will verify the values by running
*                 checks on inter-dependent columns.
*                 It will also verify that changes in one column value
*                 does not invalidate some other columns.
**********************************************************************/
PROCEDURE Op_Node_Check_Entity
(  p_op_node_rec           IN  Bom_Rtg_Eam_Util.Op_Node_Rec_Type
,  p_old_op_node_rec       IN  Bom_Rtg_Eam_Util.Op_Node_Rec_Type
,  x_op_node_rec           IN OUT NOCOPY Bom_Rtg_Eam_Util.Op_Node_Rec_Type
,  x_return_mesg           IN OUT NOCOPY VARCHAR2
,  x_return_status         IN OUT NOCOPY VARCHAR2
)
IS

BEGIN

       --
       -- Initialize Op Node Record and Status
       --
       x_op_node_rec   := p_op_node_rec ;
       x_return_status := FND_API.G_RET_STS_SUCCESS ;


       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
           ('Performing Operation Check Entitity Validation . . .') ;
       END IF ;

       -- There is no validation in current release.


EXCEPTION
       WHEN OTHERS THEN
          IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Some unknown error in Op Node Entity Validation . . .' || SQLERRM );
          END IF ;


          x_return_mesg  := G_PKG_NAME || ' Validation (Op Node Entity Validation) '
                                || substrb(SQLERRM,1,200);

          -- dbms_output.put_line('Unexpected Error: '||l_err_text);

          -- Return the status and message table.
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


END Op_Node_Check_Entity ;

/*********************************************************************
* Procedure : Op_Node_Perform_Writes
* Parameters IN : Operation Node column record
* Parameters OUT: Return Message
*                 Return Status
* Purpose   : Perform any insert/update/deletes to the
*             Operation Sequences table.
*********************************************************************/
PROCEDURE Op_Node_Perform_Writes
(  p_op_node_rec           IN  Bom_Rtg_Eam_Util.Op_Node_Rec_Type
,  x_return_mesg           IN OUT NOCOPY VARCHAR2
,  x_return_status         IN OUT NOCOPY VARCHAR2
)
IS

BEGIN

   --
   -- Initialize Status
   --
   x_return_status      := FND_API.G_RET_STS_SUCCESS ;

   IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
        ('Performing Database Writes . . .') ;
   END IF ;


   IF p_op_node_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE THEN
      IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
      ('Operation Sequence: Executing Insert Row. . . ') ;
      END IF;

      NULL ;

   ELSIF p_op_node_rec.transaction_type = BOM_Rtg_Globals.G_OPR_UPDATE
   THEN
      IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
      ('Operatin Sequence: Executing Update Row. . . ') ;
      END IF ;


      UPDATE BOM_OPERATION_SEQUENCES
      SET  X_Coordinate = p_op_node_rec.x_coordinate
      ,    Y_Coordinate = p_op_node_rec.y_coordinate
      ,    last_update_date            = SYSDATE                      /* Last Update Date */
      ,    last_updated_by             = BOM_Rtg_Globals.Get_User_Id  /* Last Updated By */
      ,    last_update_login           = BOM_Rtg_Globals.Get_Login_Id /* Last Update Login */
      ,    program_application_id      = BOM_Rtg_Globals.Get_Prog_AppId /* Application Id */
      ,    program_id                  = BOM_Rtg_Globals.Get_Prog_Id    /* Program Id */
      ,    program_update_date         = SYSDATE                    /* program_update_date */
      WHERE operation_sequence_id = p_op_node_rec.operation_sequence_id ;


   ELSIF p_op_node_rec.transaction_type = BOM_Rtg_Globals.G_OPR_DELETE
   THEN

      IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
      ('Operatin Sequence: Executing Delete Row. . . ') ;
      END IF ;

      NULL ;

   END IF ;


EXCEPTION
   WHEN OTHERS THEN
      IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
      ('Some unknown error in Op Node Perform Writes . . .' || SQLERRM );
      END IF ;

      x_return_mesg := G_PKG_NAME || ' Utility (Op Node Perform Writes) '
                                || substrb(SQLERRM,1,200);

      -- dbms_output.put_line('Unexpected Error: '||l_err_text);

      -- Return the status and message table.
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Op_Node_Perform_Writes ;



/****************************************************************************
* Procedure : Operation_Nodes
* Parameters IN   : Operation Node Table
* Parameters OUT  : Operatin Node Table and Return Status and Messages
* Purpose   : This procedure will process all the Operation Nodes records.
*
*****************************************************************************/
PROCEDURE Operation_Nodes
(   p_op_node_tbl             IN  Bom_Rtg_Eam_Util.Op_Node_Tbl_Type
,   x_op_node_tbl             IN OUT NOCOPY Bom_Rtg_Eam_Util.Op_Node_Tbl_Type
,   x_return_mesg             IN OUT NOCOPY VARCHAR2
,   x_return_status           IN OUT NOCOPY VARCHAR2
)
IS

l_op_node_tbl         Bom_Rtg_Eam_Util.Op_Node_Tbl_Type ;
l_op_node_rec         Bom_Rtg_Eam_Util.Op_Node_Rec_Type ;
l_old_op_node_rec     Bom_Rtg_Eam_Util.Op_Node_Rec_Type ;

l_return_status       VARCHAR2(1) ;
l_return_mesg         VARCHAR2(2000) ;

l_mesg_token_tbl              Error_Handler.Mesg_Token_Tbl_Type;


EXC_SEV_QUIT_OBJECT     EXCEPTION ;
EXC_UNEXP_SKIP_OBJECT   EXCEPTION ;


BEGIN

-- Return Status
-- Success : FND_API.G_RET_STS_SUCCESS
-- Error   : FND_API.G_RET_STS_ERROR
-- Unexpected Error : FND_API.G_RET_STS_UNEXP_ERROR


IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
    ('Processing Operation Nodes . . .' ) ;
END IF ;



   --  Init local table variables.
   SAVEPOINT init_operation_nodes ;
   x_return_status    := FND_API.G_RET_STS_SUCCESS ;
   l_return_status    := FND_API.G_RET_STS_SUCCESS ;
   l_op_node_tbl      := p_op_node_tbl ;

   -- Load environment information into the SYSTEM_INFORMATION record
   -- (USER_ID, LOGIN_ID, PROG_APPID, PROG_ID)

   BOM_Rtg_Globals.Init_System_Info_Rec
   (   x_mesg_token_tbl => l_mesg_token_tbl
    ,  x_return_status  => l_return_status
   );


   FOR I IN 1..l_op_node_tbl.COUNT LOOP
   BEGIN

        --  Load local records
        l_op_node_rec := l_op_node_tbl(I) ;

        l_op_node_rec.transaction_type :=
        UPPER(l_op_node_rec.transaction_type) ;


        IF (l_op_node_rec.return_status IS NULL OR
            l_op_node_rec.return_status  = FND_API.G_MISS_CHAR)

        THEN

            l_return_status := FND_API.G_RET_STS_SUCCESS;
            l_op_node_rec.return_status := FND_API.G_RET_STS_SUCCESS;


            -- Check Transaction Type
            -- Transaction Type should be UPDATE only.

            IF l_op_node_rec.transaction_type <>  BOM_Rtg_Globals.G_OPR_UPDATE
            THEN
               /* Error Handling */
               FND_MESSAGE.SET_NAME('BOM','BOM_OPNODE_TRANS_TYPE_INVALID');
               FND_MESSAGE.SET_TOKEN('OP_SEQ_NUMBER', l_op_node_rec.operation_sequence_number) ;
               l_return_mesg   := FND_MESSAGE.GET ;
               l_return_status := FND_API.G_RET_STS_ERROR ;
               RAISE EXC_SEV_QUIT_OBJECT ;

            END IF ;

            -- Process Flow step : Check user unique index : Operation_Sequence_Id
            IF l_op_node_rec.operation_sequence_id is NULL OR
               l_op_node_rec.operation_sequence_id =  FND_API.G_MISS_NUM
            THEN

               /* Error Handling */
               FND_MESSAGE.SET_NAME('BOM','BOM_OPNODE_SEQ_ID_NULL');
               FND_MESSAGE.SET_TOKEN('OP_SEQ_NUMBER', l_op_node_rec.operation_sequence_number) ;
               l_return_mesg   := FND_MESSAGE.GET ;
               l_return_status := FND_API.G_RET_STS_ERROR ;
               RAISE EXC_SEV_QUIT_OBJECT ;


            END IF;

            -- Process Flow step : Verify Operation 's existence
            --
            Bom_Rtg_Eam_Util.Op_Node_Check_Existence
                (  p_op_node_rec           => l_op_node_rec
                ,  x_old_op_node_rec       => l_old_op_node_rec
                ,  x_return_mesg           => l_return_mesg
                ,  x_return_status         => l_return_status
                );

            IF l_return_status =  FND_API.G_RET_STS_ERROR
            THEN

               /* Error Handling */
               RAISE EXC_SEV_QUIT_OBJECT ;

            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
            THEN

               /* Error Handling */
               RAISE EXC_UNEXP_SKIP_OBJECT ;

            END IF;

            -- Process Flow step : Check required fields exist
            -- Nothing special

            -- Process Flow step : Attribute Validation for CREATE and UPDATE
            -- Nothing special

            IF l_op_node_rec.transaction_type IN
               (BOM_Rtg_Globals.G_OPR_UPDATE, BOM_Rtg_Globals.G_OPR_DELETE)
            THEN

                --
                -- Process flow step : Populate NULL columns for Update and Delete
                --

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
     Error_Handler.Write_Debug('Populate NULL columns') ;
END IF ;

                Bom_Rtg_Eam_Util.Op_Node_Populate_Null_Columns
                (  p_op_node_rec           => l_op_node_rec
                ,  p_old_op_node_rec       => l_old_op_node_rec
                ,  x_op_node_rec           => l_op_node_rec
                );


            ELSIF l_op_node_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
            THEN
                --
                -- Process Flow step : Default missing values for Op Nodes (CREATE)

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Attribute Defaulting') ;
END IF ;

            END IF ;

            --
            -- Process Flow step : Entity defaulting for CREATE and UPDATE
            --
            IF l_op_node_rec.transaction_type IN ( BOM_Rtg_Globals.G_OPR_CREATE
                                                 , BOM_Rtg_Globals.G_OPR_UPDATE )
            THEN

               Bom_Rtg_Eam_Util.Op_Node_Entity_Defaulting
              (   p_op_node_rec   => l_op_node_rec
              ,   x_op_node_rec   => l_op_node_rec
              ,   x_return_mesg   => l_return_mesg
              ,   x_return_status => l_return_status
              ) ;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug ('Entity defaulting completed with return_status: ' || l_return_status) ;
END IF ;


                IF l_return_status =  FND_API.G_RET_STS_ERROR
                THEN

                   /* Error Handling */
                   RAISE EXC_SEV_QUIT_OBJECT ;

                ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
                THEN

                   /* Error Handling */
                   RAISE EXC_UNEXP_SKIP_OBJECT ;

                END IF;

            END IF ;

            --
            -- Process Flow step :  Entity Level Validation
            -- Call Bom_Validate_Op_Res.Check_Entity
            --
            Bom_Rtg_Eam_Util.Op_Node_Check_Entity
              (   p_op_node_rec   => l_op_node_rec
              ,   p_old_op_node_rec   => l_old_op_node_rec
              ,   x_op_node_rec   => l_op_node_rec
              ,   x_return_mesg   => l_return_mesg
              ,   x_return_status => l_return_status
              ) ;


            IF l_return_status =  FND_API.G_RET_STS_ERROR
            THEN

               /* Error Handling */
               RAISE EXC_SEV_QUIT_OBJECT ;

            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
            THEN

               /* Error Handling */
               RAISE EXC_UNEXP_SKIP_OBJECT ;

            END IF;



IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Entity validation completed with '
             || l_return_Status || ' proceeding for database writes . . . ') ;
END IF;

            --
            -- Process Flow step 16 : Database Writes
            --
            Bom_Rtg_Eam_Util.Op_Node_Perform_Writes
              (   p_op_node_rec   => l_op_node_rec
              ,   x_return_mesg   => l_return_mesg
              ,   x_return_status => l_return_status
              ) ;


            IF l_return_status =  FND_API.G_RET_STS_ERROR
            THEN

               /* Error Handling */
               RAISE EXC_SEV_QUIT_OBJECT ;

            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
            THEN

               /* Error Handling */
               RAISE EXC_UNEXP_SKIP_OBJECT ;

            END IF;


       END IF ;   -- END IF statement that checks RETURN STATUS

       --  Load tables.
       l_op_node_tbl(I)          := l_op_node_rec;


   EXCEPTION

      WHEN EXC_SEV_QUIT_OBJECT THEN
         l_return_status       := FND_API.G_RET_STS_ERROR ;

      WHEN EXC_UNEXP_SKIP_OBJECT THEN
         l_return_status       := FND_API.G_RET_STS_UNEXP_ERROR ;

   END ; -- END block



   IF l_return_status IN ( FND_API.G_RET_STS_ERROR
                         , FND_API.G_RET_STS_UNEXP_ERROR)
   THEN
      x_return_status := l_return_status ;
      ROLLBACK TO init_operation_nodes ;
      RETURN ;
   END IF;


   END LOOP ; -- End of l_op_node_tbl loop


   --  Load OUT parameters
   IF NVL(l_return_status, FND_API.G_RET_STS_SUCCESS )
       <> FND_API.G_RET_STS_SUCCESS
   THEN
      x_return_status    := l_return_status ;
   END IF;

   x_return_mesg   := l_return_mesg ;

END Operation_Nodes ;


PROCEDURE Create_OpNwkTbl_From_OpLinkTbl
(   p_op_link_tbl             IN  Bom_Rtg_Eam_Util.Op_Link_Tbl_Type
,   x_op_network_tbl          IN OUT NOCOPY Bom_Rtg_Pub.Op_Network_Tbl_Type
)
IS

                -- Retrieve operation network from RBO_NWK
        CURSOR   GetOpNwk    (  p_from_op_id NUMBER
                              , p_to_op_id   NUMBER )
        IS
        SELECT   bos1.Operation_Type
               , bos1.operation_seq_num From_Op_Seq_Number
               , bos1.effectivity_date  From_Start_Effective_Date
               , bos2.operation_seq_num To_Op_Seq_Number
               , bos2.effectivity_date  To_Start_Effective_Date
        FROM  BOM_OPERATION_SEQUENCES  bos1
           ,  BOM_OPERATION_SEQUENCES  bos2
        WHERE bos1.operation_sequence_id = p_from_op_id
        AND   bos2.operation_sequence_id = p_to_op_id ;

        nwk_c    NUMBER := 0; -- counter for operation network

BEGIN


    FOR I IN 1..p_op_link_tbl.COUNT LOOP


IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
   ('Getting Operation Network Record . . .');
END IF ;

        nwk_c:= nwk_c + 1 ; --counter for operation networks
        FOR nwk_rec IN GetOpNwk (  p_from_op_id =>  p_op_link_tbl(I).From_Op_Seq_Id
                                 , p_to_op_id   =>   p_op_link_tbl(I).To_Op_Seq_Id )
        LOOP
            x_op_network_tbl(nwk_c).Operation_Type            := nwk_rec.Operation_Type ;
            x_op_network_tbl(nwk_c).From_Op_Seq_Number        := nwk_rec.From_Op_Seq_Number ;
            x_op_network_tbl(nwk_c).From_Start_Effective_Date := nwk_rec.From_Start_Effective_Date ;
            x_op_network_tbl(nwk_c).To_Op_Seq_Number          := nwk_rec.To_Op_Seq_Number ;
            x_op_network_tbl(nwk_c).To_Start_Effective_Date   := nwk_rec.To_Start_Effective_Date ;

        END LOOP ;


        x_op_network_tbl(nwk_c).Assembly_Item_Name  := p_op_link_tbl(I).Assembly_Item_Name ;
        x_op_network_tbl(nwk_c).Organization_Code   := p_op_link_tbl(I).Organization_Code ;
        x_op_network_tbl(nwk_c).Alternate_Routing_Code  := p_op_link_tbl(I).Alternate_Routing_Code ;
        x_op_network_tbl(nwk_c).New_From_Op_Seq_Number        := NULL ;
        x_op_network_tbl(nwk_c).New_From_Start_Effective_Date := NULL ;
        x_op_network_tbl(nwk_c).New_To_Op_Seq_Number          := NULL ;
        x_op_network_tbl(nwk_c).New_To_Start_Effective_Date   := NULL ;
        x_op_network_tbl(nwk_c).Connection_Type   := NULL ;
        x_op_network_tbl(nwk_c).Planning_Percent  := NULL ;
        x_op_network_tbl(nwk_c).Attribute_category := NULL ;
        x_op_network_tbl(nwk_c).Attribute1  := NULL ;
        x_op_network_tbl(nwk_c).Attribute2  := NULL ;
        x_op_network_tbl(nwk_c).Attribute3  := NULL ;
        x_op_network_tbl(nwk_c).Attribute4  := NULL ;
        x_op_network_tbl(nwk_c).Attribute5  := NULL ;
        x_op_network_tbl(nwk_c).Attribute6  := NULL ;
        x_op_network_tbl(nwk_c).Attribute7  := NULL ;
        x_op_network_tbl(nwk_c).Attribute8  := NULL ;
        x_op_network_tbl(nwk_c).Attribute9  := NULL ;
        x_op_network_tbl(nwk_c).Attribute10 := NULL ;
        x_op_network_tbl(nwk_c).Attribute11 := NULL ;
        x_op_network_tbl(nwk_c).Attribute12 := NULL ;
        x_op_network_tbl(nwk_c).Attribute13 := NULL ;
        x_op_network_tbl(nwk_c).Attribute14 := NULL ;
        x_op_network_tbl(nwk_c).Attribute15 := NULL ;
        x_op_network_tbl(nwk_c).Original_System_Reference := NULL ;
        x_op_network_tbl(nwk_c).Transaction_Type := p_op_link_tbl(I).Transaction_Type ;
        x_op_network_tbl(nwk_c).Return_Status    := p_op_link_tbl(I).Return_Status ;
   END LOOP;


END Create_OpNwkTbl_From_OpLinkTbl ;



/****************************************************************************
* Procedure : Operation_Links
* Parameters IN   : Operation Links Table
* Parameters OUT  : Operatin Links Table and Return Status and Messages
* Purpose   : This procedure will process all the Operation Link records
*             using Routing Business Objects.
*****************************************************************************/
PROCEDURE Operation_Links
(   p_op_link_tbl             IN  Bom_Rtg_Eam_Util.Op_Link_Tbl_Type
,   x_op_link_tbl             IN OUT NOCOPY Bom_Rtg_Eam_Util.Op_Link_Tbl_Type
,   x_message_list            IN OUT NOCOPY Error_Handler.Error_Tbl_Type
,   x_return_status           IN OUT NOCOPY VARCHAR2
)
IS

        /* Record and Table declaration */
        l_rtg_header_rec        Bom_Rtg_Pub.Rtg_Header_Rec_Type ;
        l_out_rtg_header_rec    Bom_Rtg_Pub.Rtg_Header_Rec_Type ;
        l_rtg_revision_tbl      Bom_Rtg_Pub.Rtg_Revision_Tbl_Type ;
        l_out_rtg_revision_tbl  Bom_Rtg_Pub.Rtg_Revision_Tbl_Type ;
        l_operation_tbl         Bom_Rtg_Pub.Operation_Tbl_Type ;
        l_out_operation_tbl     Bom_Rtg_Pub.Operation_Tbl_Type ;
        l_op_resource_tbl       Bom_Rtg_Pub.Op_Resource_Tbl_Type ;
        l_out_op_resource_tbl   Bom_Rtg_Pub.Op_Resource_Tbl_Type ;
        l_sub_resource_tbl      Bom_Rtg_Pub.Sub_Resource_Tbl_Type  ;
        l_out_sub_resource_tbl  Bom_Rtg_Pub.Sub_Resource_Tbl_Type  ;
        l_op_network_tbl        Bom_Rtg_Pub.Op_Network_Tbl_Type ;
        l_out_op_network_tbl    Bom_Rtg_Pub.Op_Network_Tbl_Type ;

        l_return_status                 VARCHAR2(1);
        l_unexp_error                   VARCHAR2(1000);
        l_msg_count                     NUMBER := 0;
        l_message_list                  Error_Handler.Error_Tbl_Type  ;




BEGIN

        SAVEPOINT init_operation_link ;


IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
   ('Create op_network_tbl from p_op_link_tbl. . . ');
END IF ;


         Create_OpNwkTbl_From_OpLinkTbl
         (   p_op_link_tbl             => p_op_link_tbl
         ,   x_op_network_tbl          => l_op_network_tbl
         ) ;


IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
   ('Call Routing Business Object Public API . . . ');
END IF ;

         Bom_Rtg_Pub.Process_Rtg
                      ( p_init_msg_list           => TRUE
                      , p_rtg_header_rec          => l_rtg_header_rec
                      , p_rtg_revision_tbl        => l_rtg_revision_tbl
                      , p_operation_tbl           => l_operation_tbl
                      , p_op_resource_tbl         => l_op_resource_tbl
                      , p_sub_resource_tbl        => l_sub_resource_tbl
                      , p_op_network_tbl          => l_op_network_tbl
                      , x_rtg_header_rec          => l_out_rtg_header_rec
                      , x_rtg_revision_tbl        => l_out_rtg_revision_tbl
                      , x_operation_tbl           => l_out_operation_tbl
                      , x_op_resource_tbl         => l_out_op_resource_tbl
                      , x_sub_resource_tbl        => l_out_sub_resource_tbl
                      , x_op_network_tbl          => l_out_op_network_tbl
                      , x_return_status           => l_return_status
                      , x_msg_count               => l_msg_count
                      , p_debug                   => 'N'
                      , p_debug_filename          => NULL
                      , p_output_dir              => NULL
                      ) ;


        -- Check the return status and error handling
        -- If error is returned re-initialize applet again.
        Error_Handler.get_entity_message
        ( p_entity_id           => 'NWK'
        , x_message_list        => l_message_list
        );

        -- Renurn Mesg and Status
        x_message_list    := l_message_list ;
        x_return_status   := l_return_status ;
        x_op_link_tbl     := p_op_link_tbl ;


        IF l_return_status IN ( FND_API.G_RET_STS_ERROR
                              , FND_API.G_RET_STS_UNEXP_ERROR)
        THEN
            ROLLBACK TO init_operation_link ;
        END IF ;

END Operation_Links ;



END Bom_Rtg_Eam_Util ;

/
