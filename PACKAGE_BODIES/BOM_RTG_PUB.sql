--------------------------------------------------------
--  DDL for Package Body BOM_RTG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_RTG_PUB" AS
/* $Header: BOMBRTGB.pls 120.6.12010000.3 2012/08/06 22:49:17 umajumde ship $*/
/***************************************************************************
--
--  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMBRTGB.pls
--
--  DESCRIPTION
--
--      Body of package Bom_Rtg_Pub
--
--  NOTES
--
--  HISTORY
--
--  02-AUG-00   Biao Zhang   Initial Creation

--
-- Conversion from Routing BO Entity to Eco BO Entity
-- Conversion from Eco BO Entity to Routing BO Entity
--
***************************************************************************/

        -- Operation Entity
        /*****************************************************************
        * Procedure     : Convert_RtgOp_To_ComOp
        * Parameters IN : Operation Exposed Column Record
        *                 Operation Unexposed Column Record
        * Parameters OUT: Common Operation Exposed Exposed Column Record
        *                 Common operation Unexposed Column Record
        * Purpose       : This procedure will simply take the operation
        *                 record and copy its values into the common operation
        *                 record. Since the record definitions of ECO and routig
        *                 records is different, this has to done on a field
        *                 by field basis.
        ******************************************************************/
        -- From Routing To Common
       PROCEDURE Convert_RtgOp_To_ComOp
       (  p_rtg_operation_rec  IN  Bom_Rtg_Pub.Operation_Rec_Type
        , p_rtg_op_unexp_rec   IN  Bom_Rtg_Pub.Op_Unexposed_Rec_Type
        , x_com_operation_rec  IN OUT NOCOPY Bom_Rtg_Pub.Com_Operation_Rec_Type
        , x_com_op_unexp_rec   IN OUT NOCOPY Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
       )
       IS
       BEGIN
                x_com_operation_rec.Eco_Name                   := NULL;
                x_com_operation_rec.Organization_Code          :=
                                   p_rtg_operation_rec.Organization_Code;
                x_com_operation_rec.Revised_Item_Name          :=
                                   p_rtg_operation_rec.Assembly_Item_Name;
                x_com_operation_rec.New_Revised_Item_Revision  := NULL;
                x_com_operation_rec.New_Routing_Revision       := NULL; -- Added by MK on 11/02/00
                x_com_operation_rec.From_End_Item_Unit_Number  := NULL; -- Added by MK on 11/02/00
                x_com_operation_rec.ACD_Type                   := NULL;
                x_com_operation_rec.Alternate_Routing_Code     :=
                                   p_rtg_operation_rec.Alternate_Routing_Code;
                x_com_operation_rec.Operation_Sequence_Number  :=
                                   p_rtg_operation_rec.Operation_Sequence_Number;
                x_com_operation_rec.Operation_Type             :=
                                   p_rtg_operation_rec.Operation_Type;
                x_com_operation_rec.Start_Effective_Date       :=
                                   p_rtg_operation_rec.Start_Effective_Date;
                x_com_operation_rec.New_Operation_Sequence_Number:=
                             p_rtg_operation_rec.New_Operation_Sequence_Number;
                x_com_operation_rec.New_Start_Effective_Date   :=
                                   p_rtg_operation_rec.New_Start_Effective_Date;
                x_com_operation_rec.Old_Operation_Sequence_Number := NULL;
                x_com_operation_rec.Old_Start_Effective_Date   := NULL;
                x_com_operation_rec.Standard_Operation_Code    :=
                                   p_rtg_operation_rec.Standard_Operation_Code;
                x_com_operation_rec.Department_Code             :=
                                   p_rtg_operation_rec.Department_Code;
                x_com_operation_rec.Op_Lead_Time_Percent       :=
                                   p_rtg_operation_rec.Op_Lead_Time_Percent;
                x_com_operation_rec.Minimum_Transfer_Quantity  :=
                                 p_rtg_operation_rec.Minimum_Transfer_Quantity;
                x_com_operation_rec.Count_Point_Type           :=
                                   p_rtg_operation_rec.Count_Point_Type;
                x_com_operation_rec.Operation_Description      :=
                                   p_rtg_operation_rec.Operation_Description;
                x_com_operation_rec.Disable_Date               :=
                                   p_rtg_operation_rec.Disable_Date;
                x_com_operation_rec.Backflush_Flag             :=
                                   p_rtg_operation_rec.Backflush_Flag;
                x_com_operation_rec.Option_Dependent_Flag      :=
                                   p_rtg_operation_rec.Option_Dependent_Flag;
                x_com_operation_rec.Reference_Flag             :=
                                   p_rtg_operation_rec.Reference_Flag;
                x_com_operation_rec.Process_Seq_Number         :=
                                   p_rtg_operation_rec.Process_Seq_Number;
                x_com_operation_rec.Process_Code               :=
                                   p_rtg_operation_rec.Process_Code;
                x_com_operation_rec.Line_Op_Seq_Number         :=
                                   p_rtg_operation_rec.Line_Op_Seq_Number;
                x_com_operation_rec.Line_Op_Code               :=
                                   p_rtg_operation_rec.Line_Op_Code;
                x_com_operation_rec.Yield                      :=
                                   p_rtg_operation_rec.Yield ;
                x_com_operation_rec.Cumulative_Yield           :=
                                   p_rtg_operation_rec.Cumulative_Yield;
                x_com_operation_rec.Reverse_CUM_Yield          :=
                                   p_rtg_operation_rec.Reverse_CUM_Yield;
                --
                -- Following op calculated time columns are no longer used
                -- x_com_operation_rec.Calculated_Labor_Time      :=
                --                    p_rtg_operation_rec.Calculated_Labor_Time;
                -- x_com_operation_rec.Calculated_Machine_Time:=
                --                   p_rtg_operation_rec.Calculated_Machine_Time;
                -- x_com_operation_rec.Calculated_Elapsed_Time    :=
                --                   p_rtg_operation_rec.Calculated_Elapsed_Time;

                x_com_operation_rec.User_Labor_Time            :=
                                   p_rtg_operation_rec.User_Labor_Time;
                x_com_operation_rec.User_Machine_Time          :=
                                   p_rtg_operation_rec.User_Machine_Time;
                x_com_operation_rec.Net_Planning_Percent       :=
                                   p_rtg_operation_rec.Net_Planning_Percent;
                x_com_operation_rec.Include_In_Rollup          :=
                                   p_rtg_operation_rec.Include_In_Rollup;
                x_com_operation_rec.Op_Yield_Enabled_Flag      :=
                                   p_rtg_operation_rec.Op_Yield_Enabled_Flag;
                x_com_operation_rec.Cancel_Comments            := NULL;
                x_com_operation_rec.Attribute_category         :=
                                   p_rtg_operation_rec.Attribute_category;
                x_com_operation_rec.Attribute1                 :=
                                   p_rtg_operation_rec.Attribute1;
                x_com_operation_rec.Attribute2                 :=
                                   p_rtg_operation_rec.Attribute2;
                x_com_operation_rec.Attribute3                 :=
                                   p_rtg_operation_rec.Attribute3;
                x_com_operation_rec.Attribute4                 :=
                                   p_rtg_operation_rec.Attribute4;
                x_com_operation_rec.Attribute5                 :=
                                   p_rtg_operation_rec.Attribute5;
                x_com_operation_rec.Attribute6                 :=
                                   p_rtg_operation_rec.Attribute6 ;
                x_com_operation_rec.Attribute7                 :=
                                   p_rtg_operation_rec.Attribute7;
                x_com_operation_rec.Attribute8                 :=
                                   p_rtg_operation_rec.Attribute8;
                x_com_operation_rec.Attribute9                 :=
                                   p_rtg_operation_rec.Attribute9;
                x_com_operation_rec.Attribute10                :=
                                   p_rtg_operation_rec.Attribute10;
                x_com_operation_rec.Attribute11                :=
                                   p_rtg_operation_rec.Attribute11;
                x_com_operation_rec.Attribute12                :=
                                   p_rtg_operation_rec.Attribute12;
                x_com_operation_rec.Attribute13                :=
                                   p_rtg_operation_rec.Attribute13;
                x_com_operation_rec.Attribute14                :=
                                   p_rtg_operation_rec.Attribute14;
                x_com_operation_rec.Attribute15                :=
                                   p_rtg_operation_rec.Attribute15;
                x_com_operation_rec.Original_System_Reference  :=
                           p_rtg_operation_rec.Original_System_Reference;
                x_com_operation_rec.Transaction_Type           :=
                                   p_rtg_operation_rec.Transaction_Type;
                x_com_operation_rec.Return_Status              :=
                                            p_rtg_operation_rec.Return_Status;
                x_com_operation_rec.Delete_Group_Name          :=
                                   p_rtg_operation_rec.Delete_Group_Name;
                x_com_operation_rec.DG_Description             :=
                                   p_rtg_operation_rec.DG_Description;
                -- Added by MK 04/10/2001 for eAM changes
                x_com_operation_rec.Shutdown_Type               :=
                                   p_rtg_operation_rec.Shutdown_Type ;
		-- Added by deepu for Long description project
		x_com_operation_rec.Long_description            :=
                                   p_rtg_operation_rec.Long_Description;



                -- Similarly copy the unexposed record values into an ECO BO
                -- compatible record

                x_com_op_unexp_rec.Revised_Item_Sequence_Id    := NULL;
                x_com_op_unexp_rec.Operation_Sequence_Id       :=
                                    p_rtg_op_unexp_rec.Operation_Sequence_Id;
                x_com_op_unexp_rec.Old_Operation_Sequence_Id   :=NULL;
                x_com_op_unexp_rec.Routing_Sequence_Id         :=
                                    p_rtg_op_unexp_rec.Routing_Sequence_Id;
                x_com_op_unexp_rec.Revised_Item_Id             :=
                                    p_rtg_op_unexp_rec.Assembly_Item_Id;
                x_com_op_unexp_rec.Organization_Id             :=
                                    p_rtg_op_unexp_rec.Organization_Id;
                x_com_op_unexp_rec.Standard_Operation_Id       :=
                                    p_rtg_op_unexp_rec.Standard_Operation_Id;
                x_com_op_unexp_rec.Department_Id               :=
                                    p_rtg_op_unexp_rec.Department_Id;
                x_com_op_unexp_rec.Process_Op_Seq_Id           :=
                                    p_rtg_op_unexp_rec.Process_Op_Seq_Id;
                x_com_op_unexp_rec.Line_Op_Seq_Id              :=
                                    p_rtg_op_unexp_rec.Line_Op_Seq_Id;
                x_com_op_unexp_rec.DG_Sequence_Id              :=
                                    p_rtg_op_unexp_rec.DG_Sequence_Id;
                x_com_op_unexp_rec.DG_Description              :=
                                    p_rtg_op_unexp_rec.DG_Description;
                x_com_op_unexp_rec.DG_New                      :=
                                    p_rtg_op_unexp_rec.DG_New;

                x_com_op_unexp_rec.Lowest_acceptable_yield         :=	-- Added for MES Enhancement
                                    p_rtg_op_unexp_rec.Lowest_acceptable_yield;
                x_com_op_unexp_rec.Use_org_settings                :=
                                    p_rtg_op_unexp_rec.Use_org_settings;
                x_com_op_unexp_rec.Queue_mandatory_flag            :=
                                    p_rtg_op_unexp_rec.Queue_mandatory_flag;
                x_com_op_unexp_rec.Run_mandatory_flag              :=
                                    p_rtg_op_unexp_rec.Run_mandatory_flag;
                x_com_op_unexp_rec.To_move_mandatory_flag          :=
                                    p_rtg_op_unexp_rec.To_move_mandatory_flag;
                x_com_op_unexp_rec.Show_next_op_by_default         :=
                                    p_rtg_op_unexp_rec.Show_next_op_by_default;
                x_com_op_unexp_rec.Show_scrap_code                 :=
                                    p_rtg_op_unexp_rec.Show_scrap_code;
                x_com_op_unexp_rec.Show_lot_attrib                 :=
                                    p_rtg_op_unexp_rec.Show_lot_attrib;
                x_com_op_unexp_rec.Track_multiple_res_usage_dates  :=
                                    p_rtg_op_unexp_rec.Track_multiple_res_usage_dates;	-- End of MES Changes

                -- Moved from exp record
                x_com_op_unexp_rec.User_Elapsed_Time          :=
                                    p_rtg_op_unexp_rec.User_Elapsed_Time;


       END Convert_RtgOp_To_ComOp;

        /*****************************************************************
        * Procedure     : Convert_ComOp_To_RtgOp
        * Parameters IN : Common Operation Exposed Column Record
        *                 Common Operation Unexposed Column Record
        * Parameters OUT: Operation Exposed Exposed Column Record
        *                 Operation Unexposed Column Record
        * Purpose       : This procedure will simply take the common operation
        *                 record and copy its values into the operation record.
        *                 Since the record definitions of ECO and routig
        *                 records is different, this has to done on a field
        *                 by field basis.
        ******************************************************************/
        -- From Common To Routing
        PROCEDURE Convert_ComOp_To_RtgOp
        ( p_com_operation_rec  IN  Bom_Rtg_Pub.Com_Operation_Rec_Type
        , p_com_op_unexp_rec   IN  Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
        , x_rtg_operation_rec  IN OUT NOCOPY Bom_Rtg_Pub.Operation_Rec_Type
        , x_rtg_op_unexp_rec   IN OUT NOCOPY Bom_Rtg_Pub.Op_Unexposed_Rec_Type
        )
        IS
        BEGIN

                x_rtg_operation_rec.Organization_Code          :=
                                   p_com_operation_rec.Organization_Code;
                x_rtg_operation_rec.Assembly_Item_Name         :=
                                   p_com_operation_rec.Revised_Item_Name;
                x_rtg_operation_rec.Alternate_Routing_Code     :=
                                   p_com_operation_rec.Alternate_Routing_Code;
                x_rtg_operation_rec.Operation_Sequence_Number  :=
                                   p_com_operation_rec.Operation_Sequence_Number;
                x_rtg_operation_rec.Operation_Type             :=
                                   p_com_operation_rec.Operation_Type;
                x_rtg_operation_rec.Start_Effective_Date       :=
                                   p_com_operation_rec.Start_Effective_Date;
                x_rtg_operation_rec.New_Operation_Sequence_Number:=
                                   p_com_operation_rec.New_Operation_Sequence_Number;
                x_rtg_operation_rec.New_Start_Effective_Date   :=
                                   p_com_operation_rec.New_Start_Effective_Date;
                x_rtg_operation_rec.Standard_Operation_Code    :=
                                   p_com_operation_rec.Standard_Operation_Code;
                x_rtg_operation_rec.Department_Code            :=
                                   p_com_operation_rec.Department_Code;
                x_rtg_operation_rec.Op_Lead_Time_Percent       :=
                                   p_com_operation_rec.Op_Lead_Time_Percent;
                x_rtg_operation_rec.Minimum_Transfer_Quantity  :=
                                   p_com_operation_rec.Minimum_Transfer_Quantity;
                x_rtg_operation_rec.Count_Point_Type           :=
                                   p_com_operation_rec.Count_Point_Type;
                x_rtg_operation_rec.Operation_Description      :=
                                   p_com_operation_rec.Operation_Description;
                x_rtg_operation_rec.Disable_Date               :=
                                   p_com_operation_rec.Disable_Date;
                x_rtg_operation_rec.Backflush_Flag             :=
                                   p_com_operation_rec.Backflush_Flag;
                x_rtg_operation_rec.Option_Dependent_Flag      :=
                                   p_com_operation_rec.Option_Dependent_Flag;
                x_rtg_operation_rec.Reference_Flag             :=
                                   p_com_operation_rec.Reference_Flag;
                x_rtg_operation_rec.Process_Seq_Number         :=
                                   p_com_operation_rec.Process_Seq_Number;
                x_rtg_operation_rec.Process_Code               :=
                                   p_com_operation_rec.Process_Code;
                x_rtg_operation_rec.Line_Op_Seq_Number         :=
                                   p_com_operation_rec.Line_Op_Seq_Number;
                x_rtg_operation_rec.Line_Op_Code               :=
                                   p_com_operation_rec.Line_Op_Code;
                x_rtg_operation_rec.Yield                      :=
                                   p_com_operation_rec.Yield ;
                x_rtg_operation_rec.Cumulative_Yield           :=
                                   p_com_operation_rec.Cumulative_Yield;
                x_rtg_operation_rec.Reverse_CUM_Yield          :=
                                   p_com_operation_rec.Reverse_CUM_Yield;
                --
                -- Following op calculated time columns are no longer used
                -- x_rtg_operation_rec.Calculated_Labor_Time      :=
                --                  p_com_operation_rec.Calculated_Labor_Time;
                -- x_rtg_operation_rec.Calculated_Machine_Time    :=
                --                  p_com_operation_rec.Calculated_Machine_Time;
                -- x_rtg_operation_rec.Calculated_Elapsed_Time    :=
                --                   p_com_operation_rec.Calculated_Elapsed_Time;

                x_rtg_operation_rec.User_Labor_Time            :=
                                   p_com_operation_rec.User_Labor_Time;
                x_rtg_operation_rec.User_Machine_Time          :=
                                   p_com_operation_rec.User_Machine_Time;
                x_rtg_operation_rec.Net_Planning_Percent       :=
                                   p_com_operation_rec.Net_Planning_Percent;
                x_rtg_operation_rec.Include_In_Rollup          :=
                                   p_com_operation_rec.Include_In_Rollup;
                x_rtg_operation_rec.Op_Yield_Enabled_Flag      :=
                                   p_com_operation_rec.Op_Yield_Enabled_Flag;
                x_rtg_operation_rec.Attribute_category         :=
                                   p_com_operation_rec.Attribute_category;
                x_rtg_operation_rec.Attribute1                 :=
                                   p_com_operation_rec.Attribute1;
                x_rtg_operation_rec.Attribute2                 :=
                                   p_com_operation_rec.Attribute2;
                x_rtg_operation_rec.Attribute3                 :=
                                   p_com_operation_rec.Attribute3;
                x_rtg_operation_rec.Attribute4                 :=
                                   p_com_operation_rec.Attribute4;
                x_rtg_operation_rec.Attribute5                 :=
                                   p_com_operation_rec.Attribute5;
                x_rtg_operation_rec.Attribute6                 :=
                                   p_com_operation_rec.Attribute6;
                x_rtg_operation_rec.Attribute7                 :=
                                   p_com_operation_rec.Attribute7;
                x_rtg_operation_rec.Attribute8                 :=
                                   p_com_operation_rec.Attribute8;
                x_rtg_operation_rec.Attribute9                 :=
                                   p_com_operation_rec.Attribute9;
                x_rtg_operation_rec.Attribute10                :=
                                   p_com_operation_rec.Attribute10;
                x_rtg_operation_rec.Attribute11                :=
                                   p_com_operation_rec.Attribute11;
                x_rtg_operation_rec.Attribute12                :=
                                   p_com_operation_rec.Attribute12;
                x_rtg_operation_rec.Attribute13                :=
                                   p_com_operation_rec.Attribute13;
                x_rtg_operation_rec.Attribute14                :=
                                   p_com_operation_rec.Attribute14;
                x_rtg_operation_rec.Attribute15                :=
                                   p_com_operation_rec.Attribute15;
                x_rtg_operation_rec.Original_System_Reference  :=
                           p_com_operation_rec.Original_System_Reference;
                x_rtg_operation_rec.Transaction_Type           :=
                                   p_com_operation_rec.Transaction_Type;
                x_rtg_operation_rec.Return_Status              :=
                       p_com_operation_rec.Return_Status;
                x_rtg_operation_rec.Delete_Group_Name          :=
                                   p_com_operation_rec.Delete_Group_Name;
                x_rtg_operation_rec.DG_Description             :=
                                   p_com_operation_rec.DG_Description;
                -- Added by MK 04/10/2001 for eAM changes
                x_rtg_operation_rec.Shutdown_Type               :=
                                    p_com_operation_rec.Shutdown_Type ;
		-- Added by deepu for Long description project
                x_rtg_operation_rec.Long_Description            :=
                                    p_com_operation_rec.Long_Description;

                -- Similarly copy the unexposed record values into an ECO BO
                -- compatible record

                x_rtg_op_unexp_rec.Operation_Sequence_Id       :=
                                    p_com_op_unexp_rec.Operation_Sequence_Id;
                x_rtg_op_unexp_rec.Routing_Sequence_Id         :=
                                    p_com_op_unexp_rec.Routing_Sequence_Id;
                x_rtg_op_unexp_rec.Assembly_Item_Id             :=
                                    p_com_op_unexp_rec.Revised_Item_Id;
                x_rtg_op_unexp_rec.Organization_Id             :=
                                    p_com_op_unexp_rec.Organization_Id;
                x_rtg_op_unexp_rec.Standard_Operation_Id       :=
                                    p_com_op_unexp_rec.Standard_Operation_Id;
                x_rtg_op_unexp_rec.Department_Id               :=
                                    p_com_op_unexp_rec.Department_Id;
                x_rtg_op_unexp_rec.Process_Op_Seq_Id           :=
                                    p_com_op_unexp_rec.Process_Op_Seq_Id;
                x_rtg_op_unexp_rec.Line_Op_Seq_Id              :=
                                    p_com_op_unexp_rec.Line_Op_Seq_Id;
                x_rtg_op_unexp_rec.DG_Sequence_Id              :=
                                    p_com_op_unexp_rec.DG_Sequence_Id;
                x_rtg_op_unexp_rec.DG_Description              :=
                                    p_com_op_unexp_rec.DG_Description;
                x_rtg_op_unexp_rec.DG_New                      :=
                                    p_com_op_unexp_rec.DG_New;

                x_rtg_op_unexp_rec.Lowest_acceptable_yield         :=	-- Added for MES Enhancement
                                    p_com_op_unexp_rec.Lowest_acceptable_yield;
                x_rtg_op_unexp_rec.Use_org_settings                :=
                                    p_com_op_unexp_rec.Use_org_settings;
                x_rtg_op_unexp_rec.Queue_mandatory_flag            :=
                                    p_com_op_unexp_rec.Queue_mandatory_flag;
                x_rtg_op_unexp_rec.Run_mandatory_flag              :=
                                    p_com_op_unexp_rec.Run_mandatory_flag;
                x_rtg_op_unexp_rec.To_move_mandatory_flag          :=
                                    p_com_op_unexp_rec.To_move_mandatory_flag;
                x_rtg_op_unexp_rec.Show_next_op_by_default         :=
                                    p_com_op_unexp_rec.Show_next_op_by_default;
                x_rtg_op_unexp_rec.Show_scrap_code                 :=
                                    p_com_op_unexp_rec.Show_scrap_code;
                x_rtg_op_unexp_rec.Show_lot_attrib                 :=
                                    p_com_op_unexp_rec.Show_lot_attrib;
                x_rtg_op_unexp_rec.Track_multiple_res_usage_dates  :=
                                    p_com_op_unexp_rec.Track_multiple_res_usage_dates;	-- End of MES Changes

                -- Moved from exp record
                x_rtg_op_unexp_rec.User_Elapsed_Time           :=
                                    p_com_op_unexp_rec.User_Elapsed_Time;


       END Convert_ComOp_To_RtgOp;

        /*****************************************************************
        * Procedure     : Convert_EcoOp_To_ComOp
        * Parameters IN : ECO Operation Exposed Column Record
        *                 ECO Operation Unexposed Column Record
        * Parameters OUT: Common Operation Exposed Exposed Column Record
        *                 Common operation Unexposed Column Record
        * Purpose       : This procedure will simply take the ECO operation
        *                 record and copy its values into the common operation
        *                 record. Since the record definitions of ECO and routig
        *                 records is different, this has to done on a field
        *                 by field basis.
        ******************************************************************/
        -- From Eco To Common
        PROCEDURE Convert_EcoOp_To_ComOp
        ( p_rev_operation_rec  IN  Bom_Rtg_Pub.Rev_Operation_Rec_Type
        , p_rev_op_unexp_rec   IN  Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
        , x_com_operation_rec  IN OUT NOCOPY Bom_Rtg_Pub.Com_Operation_Rec_Type
        , x_com_op_unexp_rec   IN OUT NOCOPY Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
        )
        IS
        BEGIN

                x_com_operation_rec.Eco_Name                   :=
                                   p_rev_operation_rec.Eco_Name;
                x_com_operation_rec.Organization_Code          :=
                                   p_rev_operation_rec.Organization_Code;
                x_com_operation_rec.Revised_Item_Name          :=
                                   p_rev_operation_rec.Revised_Item_Name;
                x_com_operation_rec.New_Revised_Item_Revision  :=
                                   p_rev_operation_rec.New_Revised_Item_Revision;
                x_com_operation_rec.New_Routing_Revision       :=
                                   p_rev_operation_rec.New_Routing_Revision ; -- Added by MK on 11/02/00
                x_com_operation_rec.From_End_Item_Unit_Number  :=
                                   p_rev_operation_rec.From_End_Item_Unit_Number ; -- Added by MK on 11/02/00
                x_com_operation_rec.ACD_Type   := p_rev_operation_rec.ACD_Type;
                x_com_operation_rec.Alternate_Routing_Code     :=
                                   p_rev_operation_rec.Alternate_Routing_Code;
                x_com_operation_rec.Operation_Sequence_Number  :=
                                   p_rev_operation_rec.Operation_Sequence_Number;
                x_com_operation_rec.Operation_Type             :=
                                   p_rev_operation_rec.Operation_Type;
                x_com_operation_rec.Start_Effective_Date       :=
                                   p_rev_operation_rec.Start_Effective_Date;
                x_com_operation_rec.New_Operation_Sequence_Number:=
                                   p_rev_operation_rec.New_Operation_Sequence_Number;
                x_com_operation_rec.New_Start_Effective_Date   := NULL;
                x_com_operation_rec.Old_Operation_Sequence_Number :=
                                   p_rev_operation_rec.Old_Operation_Sequence_Number;
                x_com_operation_rec.Old_Start_Effective_Date   :=
                                   p_rev_operation_rec.Old_Start_Effective_Date;
                x_com_operation_rec.Standard_Operation_Code    :=
                                   p_rev_operation_rec.Standard_Operation_Code;
                x_com_operation_rec.Department_Code             :=
                                   p_rev_operation_rec.Department_Code;
                x_com_operation_rec.Op_Lead_Time_Percent       :=
                                   p_rev_operation_rec.Op_Lead_Time_Percent;
                x_com_operation_rec.Minimum_Transfer_Quantity  :=
                                   p_rev_operation_rec.Minimum_Transfer_Quantity;
                x_com_operation_rec.Count_Point_Type           :=
                                   p_rev_operation_rec.Count_Point_Type;
                x_com_operation_rec.Operation_Description      :=
                                   p_rev_operation_rec.Operation_Description;
                x_com_operation_rec.Disable_Date               :=
                                   p_rev_operation_rec.Disable_Date;
                x_com_operation_rec.Backflush_Flag             :=
                                   p_rev_operation_rec.Backflush_Flag;
                x_com_operation_rec.Option_Dependent_Flag      :=
                                   p_rev_operation_rec.Option_Dependent_Flag;
                x_com_operation_rec.Reference_Flag             :=
                                   p_rev_operation_rec.Reference_Flag;
                x_com_operation_rec.Process_Seq_Number         := NULL;
                x_com_operation_rec.Process_Code               := NULL;
                x_com_operation_rec.Line_Op_Seq_Number         := NULL;
                x_com_operation_rec.Line_Op_Code               := NULL;
                x_com_operation_rec.Yield                      :=
                                   p_rev_operation_rec.Yield ;
                x_com_operation_rec.Cumulative_Yield           :=
                                   p_rev_operation_rec.Cumulative_Yield;
                x_com_operation_rec.Reverse_CUM_Yield          := NULL;

                --
                -- Following op calculated time columns are no longer used
                -- x_com_operation_rec.Calculated_Labor_Time      := NULL;
                -- x_com_operation_rec.Calculated_Machine_Time    := NULL;
                -- x_com_operation_rec.Calculated_Elapsed_Time    := NULL;

                x_com_operation_rec.User_Labor_Time            := NULL;
                x_com_operation_rec.User_Machine_Time          := NULL;
                x_com_operation_rec.Net_Planning_Percent       := NULL;
                x_com_operation_rec.Include_In_Rollup          := NULL;
                x_com_operation_rec.Op_Yield_Enabled_Flag      := NULL;
                x_com_operation_rec.Cancel_Comments            :=
                                   p_rev_operation_rec.Cancel_Comments ; -- Added by MK on 11/27/00
                x_com_operation_rec.Attribute_category         :=
                                   p_rev_operation_rec.Attribute_category;
                x_com_operation_rec.Attribute1                 :=
                                   p_rev_operation_rec.Attribute1;
                x_com_operation_rec.Attribute2                 :=
                                   p_rev_operation_rec.Attribute2;
                x_com_operation_rec.Attribute3                 :=
                                   p_rev_operation_rec.Attribute3;
                x_com_operation_rec.Attribute4                 :=
                                   p_rev_operation_rec.Attribute4;
                x_com_operation_rec.Attribute5                 :=
                                   p_rev_operation_rec.Attribute5;
                x_com_operation_rec.Attribute6                 :=
                                   p_rev_operation_rec.Attribute6;
                x_com_operation_rec.Attribute7                 :=
                                   p_rev_operation_rec.Attribute7;
                x_com_operation_rec.Attribute8                 :=
                                   p_rev_operation_rec.Attribute8;
                x_com_operation_rec.Attribute9                 :=
                                   p_rev_operation_rec.Attribute9;
                x_com_operation_rec.Attribute10                :=
                                   p_rev_operation_rec.Attribute10;
                x_com_operation_rec.Attribute11                :=
                                   p_rev_operation_rec.Attribute11;
                x_com_operation_rec.Attribute12                :=
                                   p_rev_operation_rec.Attribute12;
                x_com_operation_rec.Attribute13                :=
                                   p_rev_operation_rec.Attribute13;
                x_com_operation_rec.Attribute14                :=
                                   p_rev_operation_rec.Attribute14;
                x_com_operation_rec.Attribute15                :=
                                   p_rev_operation_rec.Attribute15;
                x_com_operation_rec.Original_System_Reference  :=
                           p_rev_operation_rec.Original_System_Reference;
                x_com_operation_rec.Transaction_Type           :=
                                   p_rev_operation_rec.Transaction_Type;
                x_com_operation_rec.Return_Status              :=
                p_rev_operation_rec.Return_Status;
                x_com_operation_rec.Delete_Group_Name          := NULL ;
                x_com_operation_rec.DG_Description             := NULL ;
                -- Added by MK 04/10/2001 for eAM changes
                x_com_operation_rec.Shutdown_Type              := NULL ;
		-- Added by deepu for Long description project
		x_com_operation_rec.Long_description	       := NULL;

                -- Similarly copy the unexposed record values into an ECO BO
                -- compatible record

                x_com_op_unexp_rec.Revised_Item_Sequence_Id    :=
                                    p_rev_op_unexp_rec.Revised_Item_Sequence_Id;
                x_com_op_unexp_rec.Operation_Sequence_Id       :=
                                    p_rev_op_unexp_rec.Operation_Sequence_Id;
                x_com_op_unexp_rec.Old_Operation_Sequence_Id   :=
                                   p_rev_op_unexp_rec.Old_Operation_Sequence_Id;
                x_com_op_unexp_rec.Routing_Sequence_Id         :=
                                    p_rev_op_unexp_rec.Routing_Sequence_Id;
                x_com_op_unexp_rec.Revised_Item_Id             :=
                                    p_rev_op_unexp_rec.Revised_Item_Id;
                x_com_op_unexp_rec.Organization_Id             :=
                                    p_rev_op_unexp_rec.Organization_Id;
                x_com_op_unexp_rec.Standard_Operation_Id       :=
                                    p_rev_op_unexp_rec.Standard_Operation_Id;
                x_com_op_unexp_rec.Department_Id               :=
                                    p_rev_op_unexp_rec.Department_Id;
                x_com_op_unexp_rec.Process_Op_Seq_Id           := NULL;
                x_com_op_unexp_rec.Line_Op_Seq_Id              := NULL;
                x_com_op_unexp_rec.DG_Sequence_Id              := NULL;
                x_com_op_unexp_rec.DG_Description              := NULL;
                x_com_op_unexp_rec.DG_New                      := NULL;

                x_com_op_unexp_rec.Lowest_acceptable_yield        := NULL;	-- Added for MES Enhancement
                x_com_op_unexp_rec.Use_org_settings               := NULL;
                x_com_op_unexp_rec.Queue_mandatory_flag           := NULL;
                x_com_op_unexp_rec.Run_mandatory_flag             := NULL;
                x_com_op_unexp_rec.To_move_mandatory_flag         := NULL;
                x_com_op_unexp_rec.Show_next_op_by_default        := NULL;
                x_com_op_unexp_rec.Show_scrap_code                := NULL;
                x_com_op_unexp_rec.Show_lot_attrib                := NULL;
                x_com_op_unexp_rec.Track_multiple_res_usage_dates := NULL;	-- End of MES Changes

                -- Moved from exp rec
                x_com_op_unexp_rec.User_Elapsed_Time           := NULL;


        END Convert_EcoOp_To_ComOp;

        /*****************************************************************
        * Procedure     : Convert_ComOp_To_EcoOp
        * Parameters IN : Common Operation Exposed Column Record
        *                 Common Operation Unexposed Column Record
        * Parameters OUT: ECO Operation Exposed Exposed Column Record
        *                 ECO operation Unexposed Column Record
        * Purpose       : This procedure will simply take the common operation
        *                 record and copy its values into the ECO operation
        *                 record. Since the record definitions of ECO and routig
        *                 records is different, this has to done on a field
        *                 by field basis.
        ******************************************************************/
        -- From Common To Eco
        PROCEDURE Convert_ComOp_To_EcoOp
        ( p_com_operation_rec  IN  Bom_Rtg_Pub.Com_Operation_Rec_Type
        , p_com_op_unexp_rec   IN  Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
        , x_rev_operation_rec  IN OUT NOCOPY Bom_Rtg_Pub.Rev_Operation_Rec_Type
        , x_rev_op_unexp_rec   IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
        )
        IS
        BEGIN

                x_rev_operation_rec.Eco_Name                   :=
                                   p_com_operation_rec.Eco_Name;
                x_rev_operation_rec.Organization_Code          :=
                                   p_com_operation_rec.Organization_Code;
                x_rev_operation_rec.Revised_Item_Name          :=
                                   p_com_operation_rec.Revised_Item_Name;
                x_rev_operation_rec.New_Revised_Item_Revision  :=
                                   p_com_operation_rec.New_Revised_Item_Revision;
                x_rev_operation_rec.New_Routing_Revision       :=
                                   p_com_operation_rec.New_Routing_Revision ; -- Added by MK on 11/02/00
                x_rev_operation_rec.From_End_Item_Unit_Number  :=
                                   p_com_operation_rec.From_End_Item_Unit_Number ; -- Added by MK on 11/02/00
                x_rev_operation_rec.ACD_Type          :=
                                   p_com_operation_rec.ACD_Type;
                x_rev_operation_rec.Alternate_Routing_Code     :=
                                   p_com_operation_rec.Alternate_Routing_Code;
                x_rev_operation_rec.Operation_Sequence_Number  :=
                                   p_com_operation_rec.Operation_Sequence_Number;
                x_rev_operation_rec.Operation_Type             :=
                                   p_com_operation_rec.Operation_Type;
                x_rev_operation_rec.Start_Effective_Date       :=
                                   p_com_operation_rec.Start_Effective_Date;
                x_rev_operation_rec.New_Operation_Sequence_Number:=
                                   p_com_operation_rec.New_Operation_Sequence_Number;
                x_rev_operation_rec.Old_Operation_Sequence_Number:=
                                   p_com_operation_rec.old_Operation_Sequence_Number;
                x_rev_operation_rec.Old_Start_Effective_Date   :=
                                   p_com_operation_rec.Old_Start_Effective_Date;
                x_rev_operation_rec.Standard_Operation_Code    :=
                                   p_com_operation_rec.Standard_Operation_Code;
                x_rev_operation_rec.Department_Code             :=
                                   p_com_operation_rec.Department_Code;
                x_rev_operation_rec.Op_Lead_Time_Percent       :=
                                   p_com_operation_rec.Op_Lead_Time_Percent;
                x_rev_operation_rec.Minimum_Transfer_Quantity  :=
                                   p_com_operation_rec.Minimum_Transfer_Quantity;
                x_rev_operation_rec.Count_Point_Type           :=
                                   p_com_operation_rec.Count_Point_Type;
                x_rev_operation_rec.Operation_Description      :=
                                   p_com_operation_rec.Operation_Description;
                x_rev_operation_rec.Disable_Date               :=
                                   p_com_operation_rec.Disable_Date;
                x_rev_operation_rec.Backflush_Flag             :=
                                   p_com_operation_rec.Backflush_Flag;
                x_rev_operation_rec.Option_Dependent_Flag      :=
                                   p_com_operation_rec.Option_Dependent_Flag;
                x_rev_operation_rec.Reference_Flag             :=
                                   p_com_operation_rec.Reference_Flag;
                x_rev_operation_rec.Yield                      :=
                                   p_com_operation_rec.Yield ;
                x_rev_operation_rec.Cumulative_Yield           :=
                                   p_com_operation_rec.Cumulative_Yield;
                x_rev_operation_rec.cancel_comments      :=
                                   p_com_operation_rec.cancel_comments;
                x_rev_operation_rec.Attribute_category         :=
                                   p_com_operation_rec.Attribute_category;
                x_rev_operation_rec.Attribute1                 :=
                                   p_com_operation_rec.Attribute1;
                x_rev_operation_rec.Attribute2                 :=
                                   p_com_operation_rec.Attribute2;
                x_rev_operation_rec.Attribute3                 :=
                                   p_com_operation_rec.Attribute3;
                x_rev_operation_rec.Attribute4                 :=
                                   p_com_operation_rec.Attribute4;
                x_rev_operation_rec.Attribute5                 :=
                                   p_com_operation_rec.Attribute5;
                x_rev_operation_rec.Attribute6                 :=
                                   p_com_operation_rec.Attribute6;
                x_rev_operation_rec.Attribute7                 :=
                                   p_com_operation_rec.Attribute7;
                x_rev_operation_rec.Attribute8                 :=
                                   p_com_operation_rec.Attribute8;
                x_rev_operation_rec.Attribute9                 :=
                                   p_com_operation_rec.Attribute9;
                x_rev_operation_rec.Attribute10                :=
                                   p_com_operation_rec.Attribute10;
                x_rev_operation_rec.Attribute11                :=
                                   p_com_operation_rec.Attribute11;
                x_rev_operation_rec.Attribute12                :=
                                   p_com_operation_rec.Attribute12;
                x_rev_operation_rec.Attribute13                :=
                                   p_com_operation_rec.Attribute13;
                x_rev_operation_rec.Attribute14                :=
                                   p_com_operation_rec.Attribute14;
                x_rev_operation_rec.Attribute15                :=
                                   p_com_operation_rec.Attribute15;
                x_rev_operation_rec.Original_System_Reference  :=
                                   p_com_operation_rec.Original_System_Reference;
                x_rev_operation_rec.Transaction_Type           :=
                                   p_com_operation_rec.Transaction_Type;
                x_rev_operation_rec.Return_Status              :=
                                   p_com_operation_rec.Return_Status;

                -- Similarly copy the unexposed record values into an ECO BO
                -- compatible record

                x_rev_op_unexp_rec.Revised_Item_Sequence_Id    :=
                                    p_com_op_unexp_rec.Revised_Item_Sequence_Id;
                x_rev_op_unexp_rec.Operation_Sequence_Id       :=
                                    p_com_op_unexp_rec.Operation_Sequence_Id;
                x_rev_op_unexp_rec.Old_Operation_Sequence_Id   :=
                                    p_com_op_unexp_rec.Old_Operation_Sequence_Id;
                x_rev_op_unexp_rec.Routing_Sequence_Id         :=
                                    p_com_op_unexp_rec.Routing_Sequence_Id;
                x_rev_op_unexp_rec.Revised_Item_Id             :=
                                   p_com_op_unexp_rec.Revised_Item_Id;
                x_rev_op_unexp_rec.Organization_Id             :=
                                    p_com_op_unexp_rec.Organization_Id;
                x_rev_op_unexp_rec.Standard_Operation_Id       :=
                                    p_com_op_unexp_rec.Standard_Operation_Id;
                x_rev_op_unexp_rec.Department_Id               :=
                                    p_com_op_unexp_rec.Department_Id;

        END Convert_ComOp_To_EcoOp;

        /*****************************************************************
        * Procedure     : Convert_RtgRes_To_EcoRes
        * Parameters IN : Operation resource Exposed Column Record
        *                 Operation resource Unexposed Column Record
        * Parameters OUT: ECO Operation resource Exposed Exposed Column Record
        *                 ECO Operation resource Unexposed Column Record
        * Purpose       : This procedure will simply take the operation resource
        *                 record and copy its values into the ECO resource
        *                 record. Since the record definitions of ECO and routig
        *                 records is different, this has to done on a field
        *                 by field basis.
        ******************************************************************/
        -- Operation Resource Entity
        PROCEDURE Convert_RtgRes_To_EcoRes
        ( p_rtg_op_resource_rec  IN  Bom_Rtg_Pub.Op_Resource_Rec_Type
        , p_rtg_op_res_unexp_rec IN  Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
        , x_rev_op_resource_rec  IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
        , x_rev_op_res_unexp_rec IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
        )
        IS
        BEGIN
                x_rev_op_resource_rec.Eco_Name                   := p_rtg_op_resource_rec.eco_name; --Bug 14286614
                x_rev_op_resource_rec.Organization_Code          :=
                                   p_rtg_op_resource_rec.Organization_Code;
                x_rev_op_resource_rec.Revised_Item_Name          :=
                                   p_rtg_op_resource_rec.Assembly_Item_Name;
                x_rev_op_resource_rec.New_Revised_Item_Revision  := NULL;
                x_rev_op_resource_rec.New_Routing_Revision       := NULL;    -- Added by MK on 11/02/00
                x_rev_op_resource_rec.From_End_Item_Unit_Number  := NULL;    -- Added by MK on 11/02/00
                x_rev_op_resource_rec.ACD_Type                   := p_rtg_op_resource_rec.acd_type; --Bug 14286614
                x_rev_op_resource_rec.Alternate_Routing_Code     :=
                                   p_rtg_op_resource_rec.Alternate_Routing_Code;
                x_rev_op_resource_rec.Operation_Sequence_Number  :=
                                   p_rtg_op_resource_rec.Operation_Sequence_Number;
                x_rev_op_resource_rec.Operation_Type             :=
                                   p_rtg_op_resource_rec.Operation_Type;
                x_rev_op_resource_rec.OP_Start_Effective_Date    :=
                                   p_rtg_op_resource_rec.OP_Start_Effective_Date;
                x_rev_op_resource_rec.Resource_Sequence_Number   :=
                                   p_rtg_op_resource_rec.Resource_Sequence_Number;
                x_rev_op_resource_rec.Resource_Code              :=
                                   p_rtg_op_resource_rec.Resource_Code;
                x_rev_op_resource_rec.Activity :=p_rtg_op_resource_rec.Activity;
                x_rev_op_resource_rec.Standard_Rate_Flag         :=
                                   p_rtg_op_resource_rec.Standard_Rate_Flag;
                x_rev_op_resource_rec.Assigned_Units             :=
                                   p_rtg_op_resource_rec.Assigned_Units;
                x_rev_op_resource_rec.Usage_Rate_Or_amount       :=
                                   p_rtg_op_resource_rec.Usage_Rate_Or_amount ;
                x_rev_op_resource_rec.Usage_Rate_Or_Amount_Inverse :=
                                   p_rtg_op_resource_rec.Usage_Rate_Or_Amount_Inverse;
                x_rev_op_resource_rec.Basis_Type                 :=
                                   p_rtg_op_resource_rec.Basis_Type;
                x_rev_op_resource_rec.Schedule_Flag              :=
                                   p_rtg_op_resource_rec.Schedule_Flag;
                x_rev_op_resource_rec.Resource_Offset_Percent    :=
                                   p_rtg_op_resource_rec.Resource_Offset_Percent;
                x_rev_op_resource_rec.Autocharge_Type            :=
                                   p_rtg_op_resource_rec.Autocharge_Type;
                x_rev_op_resource_rec.Schedule_Sequence_Number   :=
                                   p_rtg_op_resource_rec.Schedule_Sequence_Number;
                x_rev_op_resource_rec.Principle_Flag             :=
                                   p_rtg_op_resource_rec.Principle_Flag ;
                x_rev_op_resource_rec.Attribute_category         :=
                                   p_rtg_op_resource_rec.Attribute_category;
                x_rev_op_resource_rec.Attribute1                 :=
                                   p_rtg_op_resource_rec.Attribute1;
                x_rev_op_resource_rec.Attribute2                 :=
                                   p_rtg_op_resource_rec.Attribute2;
                x_rev_op_resource_rec.Attribute3                 :=
                                   p_rtg_op_resource_rec.Attribute3;
                x_rev_op_resource_rec.Attribute4                 :=
                                   p_rtg_op_resource_rec.Attribute4;
                x_rev_op_resource_rec.Attribute5                 :=
                                   p_rtg_op_resource_rec.Attribute5;
                x_rev_op_resource_rec.Attribute6                 :=
                                   p_rtg_op_resource_rec.Attribute6;
                x_rev_op_resource_rec.Attribute7                 :=
                                   p_rtg_op_resource_rec.Attribute7;
                x_rev_op_resource_rec.Attribute8                 :=
                                   p_rtg_op_resource_rec.Attribute8;
                x_rev_op_resource_rec.Attribute9                 :=
                                   p_rtg_op_resource_rec.Attribute9;
                x_rev_op_resource_rec.Attribute10                :=
                                   p_rtg_op_resource_rec.Attribute10;
                x_rev_op_resource_rec.Attribute11                :=
                                   p_rtg_op_resource_rec.Attribute11;
                x_rev_op_resource_rec.Attribute12                :=
                                   p_rtg_op_resource_rec.Attribute12;
                x_rev_op_resource_rec.Attribute13                :=
                                   p_rtg_op_resource_rec.Attribute13;
                x_rev_op_resource_rec.Attribute14                :=
                                   p_rtg_op_resource_rec.Attribute14;
                x_rev_op_resource_rec.Attribute15                :=
                                   p_rtg_op_resource_rec.Attribute15;
                x_rev_op_resource_rec.Original_System_Reference  :=
                           p_rtg_op_resource_rec.Original_System_Reference;
                x_rev_op_resource_rec.Transaction_Type           :=
                                   p_rtg_op_resource_rec.Transaction_Type;
                x_rev_op_resource_rec.Return_Status              :=
                                   p_rtg_op_resource_rec.Return_Status;
                x_rev_op_resource_rec.Setup_Type :=
                                   p_rtg_op_resource_rec.Setup_Type;

                -- Similarly copy the unexposed record values into an ECO BO
                -- compatible record

                x_rev_op_res_unexp_rec.Revised_Item_Sequence_Id    := NULL;
                x_rev_op_res_unexp_rec.Operation_Sequence_Id       :=
                                  p_rtg_op_res_unexp_rec.Operation_Sequence_Id;
                x_rev_op_res_unexp_rec.Routing_Sequence_Id         :=
                                  p_rtg_op_res_unexp_rec.Routing_Sequence_Id;
                x_rev_op_res_unexp_rec.Revised_Item_Id             :=
                                  p_rtg_op_res_unexp_rec.Assembly_Item_Id;
                x_rev_op_res_unexp_rec.Organization_Id             :=
                                  p_rtg_op_res_unexp_rec.Organization_Id;
                x_rev_op_resource_rec.Substitute_Group_Number     :=
                                  p_rtg_op_resource_rec.Substitute_Group_Number;
                x_rev_op_res_unexp_rec.Substitute_Group_Number    :=
                                  x_rev_op_resource_rec.Substitute_Group_Number;
                x_rev_op_res_unexp_rec.Resource_Id                 :=
                                  p_rtg_op_res_unexp_rec.Resource_Id;
                x_rev_op_res_unexp_rec.Activity_Id                 :=
                                  p_rtg_op_res_unexp_rec.Activity_Id;
                x_rev_op_res_unexp_rec.Setup_Id                    :=
                                  p_rtg_op_res_unexp_rec.Setup_Id ;

        END Convert_RtgRes_To_EcoRes;

        /*****************************************************************
        * Procedure     : Convert_EcoRes_To_RtgRes
        * Parameters IN : ECO Operation Resource Exposed Column Record
        *                 ECO Operation Resource Unexposed Column Record
        * Parameters OUT: Operation Resource Exposed Exposed Column Record
        *                 Operation Resource Unexposed Column Record
        * Purpose       : This procedure will simply take the ECO  resource
        *                 record and copy its values into the operation resource
        *                 record. Since the record definitions of ECO and routig
        *                 records is different, this has to done on a field
        *                 by field basis.
        ******************************************************************/
        PROCEDURE Convert_EcoRes_To_RtgRes
        (  p_rev_op_resource_rec  IN  Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
         , p_rev_op_res_unexp_rec IN  Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
         , x_rtg_op_resource_rec  IN OUT NOCOPY Bom_Rtg_Pub.Op_Resource_Rec_Type
         , x_rtg_op_res_unexp_rec IN OUT NOCOPY Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
        )
        IS
        BEGIN
                x_rtg_op_resource_rec.Organization_Code          :=
                                   p_rev_op_resource_rec.Organization_Code;
                x_rtg_op_resource_rec.Assembly_item_name         :=
                                   p_rev_op_resource_rec.Revised_Item_Name;
                x_rtg_op_resource_rec.Alternate_Routing_Code     :=
                                   p_rev_op_resource_rec.Alternate_Routing_Code;
                x_rtg_op_resource_rec.Operation_Sequence_Number  :=
                                   p_rev_op_resource_rec.Operation_Sequence_Number;
                x_rtg_op_resource_rec.Operation_Type             :=
                                   p_rev_op_resource_rec.Operation_Type;
                x_rtg_op_resource_rec.Op_Start_Effective_Date    :=
                                   p_rev_op_resource_rec.OP_start_Effective_Date;
                x_rtg_op_resource_rec.acd_type    :=
                                   p_rev_op_resource_rec.acd_type; --Bug 14286614
                x_rtg_op_resource_rec.eco_name    :=
                                   p_rev_op_resource_rec.eco_name; --Bug 14286614
                x_rtg_op_resource_rec.Resource_Sequence_Number   :=
                                   p_rev_op_resource_rec.Resource_Sequence_Number;
                x_rtg_op_resource_rec.Resource_Code              :=
                                   p_rev_op_resource_rec.Resource_Code ;
                x_rtg_op_resource_rec.Activity := p_rev_op_resource_rec.Activity;
                x_rtg_op_resource_rec.Standard_Rate_Flag         :=
                                   p_rev_op_resource_rec.Standard_Rate_Flag;
                x_rtg_op_resource_rec.Assigned_Units             :=
                                   p_rev_op_resource_rec.Assigned_Units;
                x_rtg_op_resource_rec.Usage_Rate_Or_amount       :=
                                   p_rev_op_resource_rec.Usage_Rate_Or_amount ;
                x_rtg_op_resource_rec.Usage_Rate_Or_Amount_Inverse :=
                                   p_rev_op_resource_rec.Usage_Rate_Or_Amount_Inverse;
                x_rtg_op_resource_rec.Basis_Type                 :=
                                   p_rev_op_resource_rec.Basis_Type;
                x_rtg_op_resource_rec.Schedule_Flag              :=
                                   p_rev_op_resource_rec.Schedule_Flag;
                x_rtg_op_resource_rec.Resource_Offset_Percent    :=
                                   p_rev_op_resource_rec.Resource_Offset_Percent;
                x_rtg_op_resource_rec.Autocharge_Type            :=
                                   p_rev_op_resource_rec.Autocharge_Type;
                x_rtg_op_resource_rec.Schedule_Sequence_Number   :=
                                   p_rev_op_resource_rec.Schedule_Sequence_Number;
                x_rtg_op_resource_rec.Principle_Flag             :=
                                   p_rev_op_resource_rec.Principle_Flag ;
                x_rtg_op_resource_rec.Attribute_category         :=
                                   p_rev_op_resource_rec.Attribute_category;
                x_rtg_op_resource_rec.Attribute1                 :=
                                   p_rev_op_resource_rec.Attribute1;
                x_rtg_op_resource_rec.Attribute2                 :=
                                   p_rev_op_resource_rec.Attribute2;
                x_rtg_op_resource_rec.Attribute3                 :=
                                   p_rev_op_resource_rec.Attribute3;
                x_rtg_op_resource_rec.Attribute4                 :=
                                   p_rev_op_resource_rec.Attribute4;
                x_rtg_op_resource_rec.Attribute5                 :=
                                   p_rev_op_resource_rec.Attribute5;
                x_rtg_op_resource_rec.Attribute6                 :=
                                   p_rev_op_resource_rec.Attribute6 ;
                x_rtg_op_resource_rec.Attribute7                 :=
                                   p_rev_op_resource_rec.Attribute7;
                x_rtg_op_resource_rec.Attribute8                 :=
                                   p_rev_op_resource_rec.Attribute8;
                x_rtg_op_resource_rec.Attribute9                 :=
                                   p_rev_op_resource_rec.Attribute9;
                x_rtg_op_resource_rec.Attribute10                :=
                                   p_rev_op_resource_rec.Attribute10;
                x_rtg_op_resource_rec.Attribute11                :=
                                   p_rev_op_resource_rec.Attribute11;
                x_rtg_op_resource_rec.Attribute12                :=
                                   p_rev_op_resource_rec.Attribute12;
                x_rtg_op_resource_rec.Attribute13                :=
                                   p_rev_op_resource_rec.Attribute13;
                x_rtg_op_resource_rec.Attribute14                :=
                                   p_rev_op_resource_rec.Attribute14;
                x_rtg_op_resource_rec.Attribute15                :=
                                   p_rev_op_resource_rec.Attribute15;
                x_rtg_op_resource_rec.Original_System_Reference  :=
                           p_rev_op_resource_rec.Original_System_Reference;
                x_rtg_op_resource_rec.Transaction_Type           :=
                                   p_rev_op_resource_rec.Transaction_Type;
                x_rtg_op_resource_rec.Return_Status              :=
                                   p_rev_op_resource_rec.Return_Status;
                x_rtg_op_resource_rec.Setup_Type                 :=
                                   p_rev_op_resource_rec.Setup_Type ;

                -- Similarly copy the unexposed record values into an ECO BO
                -- compatible record

                x_rtg_op_res_unexp_rec.Operation_Sequence_Id       :=
                                    p_rev_op_res_unexp_rec.Operation_Sequence_Id;
                x_rtg_op_res_unexp_rec.Routing_Sequence_Id         :=
                                    p_rev_op_res_unexp_rec.Routing_Sequence_Id;
                x_rtg_op_res_unexp_rec.Assembly_Item_Id            :=
                                    p_rev_op_res_unexp_rec.Revised_Item_Id;
                x_rtg_op_res_unexp_rec.Organization_Id             :=
                                    p_rev_op_res_unexp_rec.Organization_Id;
                x_rtg_op_resource_rec.Substitute_Group_Number     :=
                             p_rev_op_resource_rec.Substitute_Group_Number;
                x_rtg_op_res_unexp_rec.Substitute_Group_Number    :=
                             x_rtg_op_resource_rec.Substitute_Group_Number;
                x_rtg_op_res_unexp_rec.Resource_Id                 :=
                                    p_rev_op_res_unexp_rec.Resource_Id;
                x_rtg_op_res_unexp_rec.Activity_Id                 :=
                                    p_rev_op_res_unexp_rec.Activity_Id ;
                x_rtg_op_res_unexp_rec.Setup_Id                    :=
                                    p_rev_op_res_unexp_rec.Setup_Id ;

        END Convert_EcoRes_To_RtgRes;

        /*****************************************************************
        * Procedure     : Convert_RtgSubRes_To_EcoSubRes
        * Parameters IN : Substitute Resource Exposed Column Record
        *                 Substitute Resource Unexposed Column Record
        * Parameters OUT: ECO Substitute Resource Exposed Exposed Column Record
        *                 ECO Substitute Resource Unexposed Column Record
        * Purpose       : This procedure will simply take the Sub Resource
        *                 record and copy its values into the ECO Sub Resource
        *                 record. Since the record definitions of ECO and routig
        *                 records is different, this has to done on a field
        *                 by field basis.
        ******************************************************************/
        -- Sub Operation Resource Entity
        PROCEDURE Convert_RtgSubRes_To_EcoSubRes
        ( p_rtg_sub_resource_rec    IN  Bom_Rtg_Pub.Sub_Resource_Rec_Type
        , p_rtg_sub_res_unexp_rec   IN  Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type
        , x_rev_sub_resource_rec    IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type
        , x_rev_sub_res_unexp_rec   IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
        )
        IS
        BEGIN

                x_rev_sub_resource_rec.Eco_Name                   := NULL;
                x_rev_sub_resource_rec.Organization_Code          :=
                                p_rtg_sub_resource_rec.Organization_Code;
                x_rev_sub_resource_rec.Revised_Item_Name          :=
                                p_rtg_sub_resource_rec.Assembly_Item_Name;
                x_rev_sub_resource_rec.New_Revised_Item_Revision  := NULL;
                x_rev_sub_resource_rec.New_Routing_Revision       := NULL;    -- Added by MK on 11/02/00
                x_rev_sub_resource_rec.From_End_Item_Unit_Number  := NULL;    -- Added by MK on 11/02/00
                x_rev_sub_resource_rec.ACD_Type                   := NULL;
                x_rev_sub_resource_rec.Alternate_Routing_Code     :=
                                p_rtg_sub_resource_rec.Alternate_Routing_Code;
                x_rev_sub_resource_rec.Operation_Sequence_Number  :=
                                p_rtg_sub_resource_rec.Operation_Sequence_Number;
                x_rev_sub_resource_rec.Operation_Type             :=
                                p_rtg_sub_resource_rec.Operation_Type;
                x_rev_sub_resource_rec.OP_Start_Effective_Date    :=
                                p_rtg_sub_resource_rec.OP_Start_Effective_Date;
                x_rev_sub_resource_rec.Sub_Resource_code          :=
                                p_rtg_sub_resource_rec.Sub_Resource_code;
                x_rev_sub_resource_rec.New_Sub_Resource_code      :=
                                p_rtg_sub_resource_rec.New_Sub_Resource_code;
                x_rev_sub_resource_rec.Schedule_Sequence_Number   :=
                                p_rtg_sub_resource_rec.Schedule_Sequence_Number ;
                x_rev_sub_resource_rec.Replacement_Group_Number   :=
                                p_rtg_sub_resource_rec.Replacement_Group_Number ;
                x_rev_sub_resource_rec.New_Replacement_Group_Number   := -- bug 3741570
                                p_rtg_sub_resource_rec.New_Replacement_Group_Number ;
                x_rev_sub_resource_rec.Activity :=
                                p_rtg_sub_resource_rec.Activity;
                x_rev_sub_resource_rec.Standard_Rate_Flag         :=
                                p_rtg_sub_resource_rec.Standard_Rate_Flag;
                x_rev_sub_resource_rec.Assigned_Units             :=
                                p_rtg_sub_resource_rec.Assigned_Units;
                x_rev_sub_resource_rec.Usage_Rate_Or_amount       :=
                                p_rtg_sub_resource_rec.Usage_Rate_Or_amount ;
                x_rev_sub_resource_rec.Usage_Rate_Or_Amount_Inverse :=
                                p_rtg_sub_resource_rec.Usage_Rate_Or_Amount_Inverse;
                x_rev_sub_resource_rec.Basis_Type                 :=
                                p_rtg_sub_resource_rec.Basis_Type;
                x_rev_sub_resource_rec.New_Basis_Type             :=
                                p_rtg_sub_resource_rec.New_Basis_Type; /* Added for bug 4689856 */
                x_rev_sub_resource_rec.Schedule_Flag              :=
                                p_rtg_sub_resource_rec.Schedule_Flag;
                x_rev_sub_resource_rec.New_Schedule_Flag          :=
 	                                 p_rtg_sub_resource_rec.New_Schedule_Flag; /* Added for bug 13005178 */
                x_rev_sub_resource_rec.Resource_Offset_Percent    :=
                                p_rtg_sub_resource_rec.Resource_Offset_Percent;
                x_rev_sub_resource_rec.Autocharge_Type            :=
                                p_rtg_sub_resource_rec.Autocharge_Type;
                x_rev_sub_resource_rec.Principle_Flag             :=
                                p_rtg_sub_resource_rec.Principle_Flag ;
                x_rev_sub_resource_rec.Attribute_category         :=
                                p_rtg_sub_resource_rec.Attribute_category;
                x_rev_sub_resource_rec.Attribute1                 :=
                                p_rtg_sub_resource_rec.Attribute1;
                x_rev_sub_resource_rec.Attribute2                 :=
                                p_rtg_sub_resource_rec.Attribute2;
                x_rev_sub_resource_rec.Attribute3                 :=
                                p_rtg_sub_resource_rec.Attribute3;
                x_rev_sub_resource_rec.Attribute4                 :=
                                p_rtg_sub_resource_rec.Attribute4;
                x_rev_sub_resource_rec.Attribute5                 :=
                                p_rtg_sub_resource_rec.Attribute5;
                x_rev_sub_resource_rec.Attribute6                 :=
                                p_rtg_sub_resource_rec.Attribute6;
                x_rev_sub_resource_rec.Attribute7                 :=
                                p_rtg_sub_resource_rec.Attribute7;
                x_rev_sub_resource_rec.Attribute8                 :=
                                p_rtg_sub_resource_rec.Attribute8;
                x_rev_sub_resource_rec.Attribute9                 :=
                                p_rtg_sub_resource_rec.Attribute9;
                x_rev_sub_resource_rec.Attribute10                :=
                                p_rtg_sub_resource_rec.Attribute10;
                x_rev_sub_resource_rec.Attribute11                :=
                                p_rtg_sub_resource_rec.Attribute11;
                x_rev_sub_resource_rec.Attribute12                :=
                                p_rtg_sub_resource_rec.Attribute12;
                x_rev_sub_resource_rec.Attribute13                :=
                                p_rtg_sub_resource_rec.Attribute13;
                x_rev_sub_resource_rec.Attribute14                :=
                                p_rtg_sub_resource_rec.Attribute14;
                x_rev_sub_resource_rec.Attribute15                :=
                                p_rtg_sub_resource_rec.Attribute15;
                x_rev_sub_resource_rec.Original_System_Reference  :=
                                p_rtg_sub_resource_rec.Original_System_Reference;
                x_rev_sub_resource_rec.Transaction_Type           :=
                                p_rtg_sub_resource_rec.Transaction_Type;
                x_rev_sub_resource_rec.Return_Status              :=
                                p_rtg_sub_resource_rec.Return_Status;
                x_rev_sub_resource_rec.Setup_Type                 :=
                                p_rtg_sub_resource_rec.Setup_Type ;

                -- Similarly copy the unexposed record values into an ECO BO
                -- compatible record

                x_rev_sub_res_unexp_rec.Revised_Item_Sequence_Id    := NULL;
                x_rev_sub_res_unexp_rec.Operation_Sequence_Id       :=
                                p_rtg_sub_res_unexp_rec.Operation_Sequence_Id;
                x_rev_sub_res_unexp_rec.Routing_Sequence_Id         :=
                                p_rtg_sub_res_unexp_rec.Routing_Sequence_Id;
                x_rev_sub_res_unexp_rec.Revised_Item_Id             :=
                                p_rtg_sub_res_unexp_rec.Assembly_Item_Id;
                x_rev_sub_res_unexp_rec.Organization_Id             :=
                                p_rtg_sub_res_unexp_rec.Organization_Id;
                x_rev_sub_resource_rec.Substitute_Group_Number     :=
                                p_rtg_sub_resource_rec.Substitute_Group_Number;
                x_rev_sub_res_unexp_rec.Substitute_Group_Number     :=
                                x_rev_sub_resource_rec.Substitute_Group_Number;
                x_rev_sub_res_unexp_rec.Resource_Id                 :=
                                p_rtg_sub_res_unexp_rec.Resource_Id;
                x_rev_sub_res_unexp_rec.New_Resource_Id             :=
                                p_rtg_sub_res_unexp_rec.New_Resource_Id;
                x_rev_sub_res_unexp_rec.Activity_Id                 :=
                                p_rtg_sub_res_unexp_rec.Activity_Id ;
                x_rev_sub_res_unexp_rec.Setup_Id                    :=
                                p_rtg_sub_res_unexp_rec.Setup_ID ;

        END Convert_RtgSubRes_To_EcoSubRes;

        /*****************************************************************
        * Procedure     : Convert_EcoSubRes_To_RtgSubRes
        * Parameters IN : ECO Substitute Resource Exposed Column Record
        *                 ECO Substitute Resource Unexposed Column Record
        * Parameters OUT: Substitute Resource Exposed Exposed Column Record
        *                 Substitute Resource Unexposed Column Record
        * Purpose       : This procedure will simply take the ECO Sub Resource
        *                 record and copy its values into the Sub Resource
        *                 record. Since the record definitions of ECO and routig
        *                 records is different, this has to done on a field
        *                 by field basis.
        ******************************************************************/
        PROCEDURE Convert_EcoSubRes_To_RtgSubRes
        ( p_rev_sub_resource_rec  IN  Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type
        , p_rev_sub_res_unexp_rec IN  Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
        , x_rtg_sub_resource_rec  IN OUT NOCOPY Bom_Rtg_Pub.Sub_Resource_Rec_Type
        , x_rtg_sub_res_unexp_rec IN OUT NOCOPY Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type
        )
        IS
        BEGIN

                x_rtg_sub_resource_rec.Organization_Code          :=
                                p_rev_sub_resource_rec.Organization_Code;
                x_rtg_sub_resource_rec.Assembly_Item_Name         :=
                                p_rev_sub_resource_rec.Revised_Item_Name;
                x_rtg_sub_resource_rec.Alternate_Routing_Code     :=
                                p_rev_sub_resource_rec.Alternate_Routing_Code;
                x_rtg_sub_resource_rec.Operation_Sequence_Number  :=
                                p_rev_sub_resource_rec.Operation_Sequence_Number;
                x_rtg_sub_resource_rec.Operation_Type             :=
                                p_rev_sub_resource_rec.Operation_Type;
                x_rtg_sub_resource_rec.OP_Start_Effective_Date    :=
                                p_rev_sub_resource_rec.OP_Start_Effective_Date;
                x_rtg_sub_resource_rec.Sub_Resource_code          :=
                                p_rev_sub_resource_rec.Sub_Resource_code;
                x_rtg_sub_resource_rec.New_Sub_Resource_code      :=
                                p_rev_sub_resource_rec.New_Sub_Resource_code;
                x_rtg_sub_resource_rec.Schedule_Sequence_Number   :=
                                p_rev_sub_resource_rec.Schedule_Sequence_Number ;
                x_rtg_sub_resource_rec.Replacement_Group_Number   :=
                                p_rev_sub_resource_rec.Replacement_Group_Number ;
                x_rtg_sub_resource_rec.New_Replacement_Group_Number   := -- bug 3741570
                                p_rev_sub_resource_rec.New_Replacement_Group_Number;
                x_rtg_sub_resource_rec.Activity                   :=
                                p_rev_sub_resource_rec.Activity;
                x_rtg_sub_resource_rec.Standard_Rate_Flag         :=
                                p_rev_sub_resource_rec.Standard_Rate_Flag;
                x_rtg_sub_resource_rec.Assigned_Units             :=
                                p_rev_sub_resource_rec.Assigned_Units;
                x_rtg_sub_resource_rec.Usage_Rate_Or_amount       :=
                                p_rev_sub_resource_rec.Usage_Rate_Or_amount ;
                x_rtg_sub_resource_rec.Usage_Rate_Or_Amount_Inverse :=
                                p_rev_sub_resource_rec.Usage_Rate_Or_Amount_Inverse;
                x_rtg_sub_resource_rec.Basis_Type                 :=
                                p_rev_sub_resource_rec.Basis_Type;
                x_rtg_sub_resource_rec.New_Basis_Type             :=
                                p_rev_sub_resource_rec.New_Basis_Type; /* Added for bug 4689856 */
                x_rtg_sub_resource_rec.Schedule_Flag              :=
                                p_rev_sub_resource_rec.Schedule_Flag;
                x_rtg_sub_resource_rec.New_Schedule_Flag          :=
 	                                 p_rev_sub_resource_rec.New_Schedule_Flag; /* Added for bug 13005178 */
                x_rtg_sub_resource_rec.Resource_Offset_Percent    :=
                                p_rev_sub_resource_rec.Resource_Offset_Percent;
                x_rtg_sub_resource_rec.Autocharge_Type            :=
                                p_rev_sub_resource_rec.Autocharge_Type;
                x_rtg_sub_resource_rec.Principle_Flag             :=
                                p_rev_sub_resource_rec.Principle_Flag ;
                x_rtg_sub_resource_rec.Attribute_category         :=
                                p_rev_sub_resource_rec.Attribute_category;
                x_rtg_sub_resource_rec.Attribute1                 :=
                                p_rev_sub_resource_rec.Attribute1;
                x_rtg_sub_resource_rec.Attribute2                 :=
                                p_rev_sub_resource_rec.Attribute2;
                x_rtg_sub_resource_rec.Attribute3                 :=
                                p_rev_sub_resource_rec.Attribute3;
                x_rtg_sub_resource_rec.Attribute4                 :=
                                p_rev_sub_resource_rec.Attribute4;
                x_rtg_sub_resource_rec.Attribute5                 :=
                                p_rev_sub_resource_rec.Attribute5;
                x_rtg_sub_resource_rec.Attribute6                 :=
                                p_rev_sub_resource_rec.Attribute6 ;
                x_rtg_sub_resource_rec.Attribute7                 :=
                                p_rev_sub_resource_rec.Attribute7;
                x_rtg_sub_resource_rec.Attribute8                 :=
                                p_rev_sub_resource_rec.Attribute8;
                x_rtg_sub_resource_rec.Attribute9                 :=
                                p_rev_sub_resource_rec.Attribute9;
                x_rtg_sub_resource_rec.Attribute10                :=
                                p_rev_sub_resource_rec.Attribute10;
                x_rtg_sub_resource_rec.Attribute11                :=
                                p_rev_sub_resource_rec.Attribute11;
                x_rtg_sub_resource_rec.Attribute12                :=
                                p_rev_sub_resource_rec.Attribute12;
                x_rtg_sub_resource_rec.Attribute13                :=
                                p_rev_sub_resource_rec.Attribute13;
                x_rtg_sub_resource_rec.Attribute14                :=
                                p_rev_sub_resource_rec.Attribute14;
                x_rtg_sub_resource_rec.Attribute15                :=
                                p_rev_sub_resource_rec.Attribute15;
                x_rtg_sub_resource_rec.Original_System_Reference  :=
                                p_rev_sub_resource_rec.Original_System_Reference;
                x_rtg_sub_resource_rec.Transaction_Type           :=
                                p_rev_sub_resource_rec.Transaction_Type;
                x_rtg_sub_resource_rec.Return_Status              :=
                                p_rev_sub_resource_rec.Return_Status;
                x_rtg_sub_resource_rec.Setup_Type                 :=
                                p_rev_sub_resource_rec.Setup_Type;

                -- Similarly copy the unexposed record values into an ECO BO
                -- compatible record

                x_rtg_sub_res_unexp_rec.Operation_Sequence_Id      :=
                                p_rev_sub_res_unexp_rec.Operation_Sequence_Id;
                x_rtg_sub_res_unexp_rec.Routing_Sequence_Id        :=
                                p_rev_sub_res_unexp_rec.Routing_Sequence_Id;
                x_rtg_sub_res_unexp_rec.Assembly_Item_Id           :=
                                p_rev_sub_res_unexp_rec.revised_Item_Id;
                x_rtg_sub_res_unexp_rec.Organization_Id            :=
                                p_rev_sub_res_unexp_rec.Organization_Id;
                x_rtg_sub_resource_rec.Substitute_Group_Number    :=
                                p_rev_sub_resource_rec.substitute_Group_Number;
                x_rtg_sub_res_unexp_rec.Substitute_Group_Number    :=
                                x_rtg_sub_resource_rec.Substitute_Group_Number;
                x_rtg_sub_res_unexp_rec.Resource_Id                :=
                                p_rev_sub_res_unexp_rec.Resource_Id;
                x_rtg_sub_res_unexp_rec.New_Resource_Id            :=
                                p_rev_sub_res_unexp_rec.New_Resource_Id;
                x_rtg_sub_res_unexp_rec.Activity_Id                :=
                                p_rev_sub_res_unexp_rec.Activity_Id ;
                x_rtg_sub_res_unexp_rec.Setup_Id                   :=
                                p_rev_sub_res_unexp_rec.Setup_Id ;


        END Convert_EcoSubRes_To_RtgSubRes ;


        /********************************************************************
        * Function      : Does_Rev_Have_Same_Rtg
        * Parameters IN : Routing Revision exposed column record
        *                 Assembly Name
        *                 Organization Name
        * Parameters OUT: N/A
        * Purpose       : This function is to check all the records have the
        *                 same assembly_item_name and same organization.
        *                 This function is callled in the procedure
        *                 Check_Records_In_Same_BOM
        *********************************************************************/
        FUNCTION Does_Rev_Have_Same_Rtg
        ( p_rtg_revision_tbl        IN Bom_Rtg_Pub.Rtg_Revision_Tbl_Type
        , p_assembly_item_name      IN VARCHAR2
        , p_organization_code       IN VARCHAR2
        ) RETURN BOOLEAN
        IS
                table_index     NUMBER;
                record_count    NUMBER;
        BEGIN
                record_count := p_rtg_revision_tbl.COUNT;

                FOR table_index IN 1..record_count
                LOOP
                    IF NVL(p_rtg_revision_tbl(table_index).assembly_item_name,
                           FND_API.G_MISS_CHAR) <>
                                NVL(p_assembly_item_name, FND_API.G_MISS_CHAR)
                           OR
                           NVL(p_rtg_revision_tbl(table_index).organization_code,
                               FND_API.G_MISS_CHAR) <>
                                NVL(p_organization_code, FND_API.G_MISS_CHAR)
                    THEN
                         RETURN FALSE;
                    END IF;
                END LOOP;
                RETURN TRUE;
        END Does_Rev_Have_Same_Rtg;

        /********************************************************************
        * Function      : Does_Op_Have_Same_Rtg
        * Parameters IN : Operation exposed column record
        *                 Assembly Name
        *                 Organization Name
        *                 Alternate routing code
        * Parameters OUT: N/A
        * Purpose       : This function is to check all the records have the
        *                 same assembly_item_name and same organization.
        *                 This function is callled in the procedure
        *                 Check_Records_In_Same_BOM
        *********************************************************************/
        FUNCTION Does_Op_Have_Same_Rtg
        ( p_operation_tbl            IN  Bom_Rtg_Pub.Operation_Tbl_Type
        , p_assembly_item_name       IN VARCHAR2
        , p_organization_code        IN VARCHAR2
        , p_alternate_routing_code   IN VARCHAR2
        ) RETURN BOOLEAN
        IS
                table_index     NUMBER;
                record_count    NUMBER;
        BEGIN
                record_count := p_operation_tbl.COUNT;

                FOR table_index IN 1..record_count
                LOOP
                  IF NVL(p_operation_tbl(table_index).assembly_item_name,
                            FND_API.G_MISS_CHAR) <>
                              NVL(p_assembly_item_name, FND_API.G_MISS_CHAR)
                     OR
                     NVL(p_operation_tbl(table_index).organization_code,
                           FND_API.G_MISS_CHAR) <>
                              NVL(p_organization_code, FND_API.G_MISS_CHAR)
                     OR
                     NVL(p_operation_tbl(table_index).alternate_routing_code,
                              FND_API.G_MISS_CHAR) <>
                           NVL(p_alternate_routing_code, FND_API.G_MISS_CHAR)
                     AND NVL(p_alternate_routing_code,  FND_API.G_MISS_CHAR)
                         <> 'XXXXXXXXXX'
                  THEN
                    RETURN FALSE;
                  END IF;
                END LOOP;

                RETURN TRUE;
        END Does_Op_Have_Same_Rtg;

        /********************************************************************
        * Function      : Does_Res_Have_Same_Rtg
        * Parameters IN : Operation resource exposed column record
        *                 Assembly Name
        *                 Organization Name
        *                 Alternate routing code
        * Parameters OUT: N/A
        * Purpose       : This function is to check all the records have the
        *                 same assembly_item_name and same organization.
        *                 This function is callled in the procedure
        *                 Check_Records_In_Same_BOM
        *********************************************************************/
        FUNCTION Does_Res_Have_Same_Rtg
        (p_op_resource_tbl          IN  Bom_Rtg_Pub.Op_Resource_Tbl_Type
        , p_assembly_item_name      IN VARCHAR2
        , p_organization_code       IN VARCHAR2
        , p_alternate_routing_code  IN VARCHAR2
        ) RETURN BOOLEAN
        IS
                table_index     NUMBER;
                record_count    NUMBER;
        BEGIN
                record_count := p_op_resource_tbl .COUNT;

                FOR table_index IN 1..record_count
                LOOP
                     IF NVL(p_op_resource_tbl (table_index).assembly_item_name,
                            FND_API.G_MISS_CHAR) <>
                            NVL(p_assembly_item_name, FND_API.G_MISS_CHAR)
                     OR NVL(p_op_resource_tbl(table_index).organization_code,
                            FND_API.G_MISS_CHAR) <>
                            NVL(p_organization_code, FND_API.G_MISS_CHAR)
                     OR NVL(p_op_resource_tbl(table_index).alternate_routing_code,
                            FND_API.G_MISS_CHAR) <>
                            NVL(p_alternate_routing_code, FND_API.G_MISS_CHAR)
                     AND NVL(p_alternate_routing_code,  FND_API.G_MISS_CHAR)
                            <> 'XXXXXXXXXX'
                     THEN
                         RETURN FALSE;
                     END IF;
                END LOOP;

                RETURN TRUE;
        END Does_Res_Have_Same_Rtg;

        /********************************************************************
        * Function      : Does_SubRes_Have_Same_Rtg
        * Parameters IN : Operation Sub resource exposed column record
        *                 Assembly Name
        *                 Organization Name
        *                 Alternate routing code
        * Parameters OUT: N/A
        * Purpose       : This function is to check all the records have the
        *                 same assembly_item_name and same organization.
        *                 This function is callled in the procedure
        *                 Check_Records_In_Same_BOM
        *********************************************************************/
        FUNCTION Does_SubRes_Have_Same_Rtg
        ( p_sub_resource_tbl        IN  Bom_Rtg_Pub.Sub_Resource_Tbl_Type
        , p_assembly_item_name      IN VARCHAR2
        , p_organization_code       IN VARCHAR2
        , p_alternate_routing_code  IN VARCHAR2
        ) RETURN BOOLEAN
        IS
                table_index     NUMBER;
                record_count    NUMBER;
        BEGIN
                record_count := p_sub_resource_tbl.COUNT;

                FOR table_index IN 1..record_count
                LOOP
                    IF NVL(p_sub_resource_tbl(table_index).assembly_item_name,
                           FND_API.G_MISS_CHAR) <>
                           NVL(p_assembly_item_name, FND_API.G_MISS_CHAR)
                    OR NVL(p_sub_resource_tbl(table_index).organization_code,
                           FND_API.G_MISS_CHAR) <>
                           NVL(p_organization_code, FND_API.G_MISS_CHAR)
                    OR NVL(p_sub_resource_tbl(table_index).alternate_routing_code,
                             FND_API.G_MISS_CHAR) <>
                           NVL(p_alternate_routing_code,  FND_API.G_MISS_CHAR)
                    AND NVL(p_alternate_routing_code,  FND_API.G_MISS_CHAR)
                           <> 'XXXXXXXXXX'
                    THEN
                       RETURN FALSE;
                    END IF;
                END LOOP;

                RETURN TRUE;
        END Does_SubRes_Have_Same_Rtg;

        /********************************************************************
        * Function      : Does_OpNw_Have_Same_Rtg
        * Parameters IN : Operation Sub resource exposed column record
        *                 Assembly Name
        *                 Organization Name
        *                 Alternate routing code
        * Parameters OUT: N/A
        * Purpose       : This function is to check all the records have the
        *                 same assembly_item_name and same organization.
        *                 This function is callled in the procedure
        *                 Check_Records_In_Same_BOM
        *********************************************************************/
        FUNCTION Does_OpNw_Have_Same_Rtg
        ( p_op_network_tbl          IN Bom_Rtg_Pub.Op_Network_Tbl_Type
        , p_assembly_item_name      IN VARCHAR2
        , p_organization_code       IN VARCHAR2
        , p_alternate_routing_code  IN VARCHAR2
        ) RETURN BOOLEAN
        IS
                table_index     NUMBER;
                record_count    NUMBER;
        BEGIN
                record_count := p_op_network_tbl.COUNT;
                FOR table_index IN 1..record_count
                LOOP
                    IF NVL(p_op_network_tbl(table_index).assembly_item_name,
                           FND_API.G_MISS_CHAR) <>
                           NVL(p_assembly_item_name, FND_API.G_MISS_CHAR)
                    OR NVL(p_op_network_tbl(table_index).organization_code,
                           FND_API.G_MISS_CHAR) <>
                           NVL(p_organization_code, FND_API.G_MISS_CHAR)
                    OR NVL(p_op_network_tbl(table_index).alternate_routing_code,
                           FND_API.G_MISS_CHAR) <>
                           NVL(p_alternate_routing_code, FND_API.G_MISS_CHAR)
                    AND NVL(p_alternate_routing_code,  FND_API.G_MISS_CHAR)
                           <> 'XXXXXXXXXX'
                    THEN
                         RETURN FALSE;
                    END IF;
                END LOOP;

                RETURN TRUE;
        END Does_OpNw_Have_Same_Rtg;


        /********************************************************************
        * Procedure     : Check_Records_In_Same_RTG
        * Parameters IN : Routing Header exposed column record
        *                 Routing revision exposed column table
        *                 Operation Exposed Column Table
        *                 Resource Exposed Column table
        *                 Substitute  Resource Exposed column table
        *                 Network Exposed column table
        * Parameters OUT: Assembly_item_name
        *                 Organization_code
        * Purpose       : This procedure is to check all the records have the
        *                 same assembly_item_name and same organization.
        *                 This procedure is callled in public procedure
        *                 Process_Rtg.
        *********************************************************************/

        FUNCTION Check_Records_In_Same_RTG
        (  p_rtg_header_rec         IN  Bom_Rtg_Pub.Rtg_Header_Rec_Type
         , p_rtg_revision_tbl       IN  Bom_Rtg_Pub.Rtg_Revision_Tbl_Type
         , p_operation_tbl          IN  Bom_Rtg_Pub.Operation_Tbl_Type
         , p_op_resource_tbl        IN  Bom_Rtg_Pub.Op_resource_Tbl_Type
         , p_sub_resource_tbl       IN  Bom_Rtg_Pub.Sub_Resource_Tbl_Type
         , p_op_network_tbl         IN  Bom_Rtg_Pub.Op_network_Tbl_Type
         , x_assembly_item_name     IN OUT NOCOPY VARCHAR2
         , x_organization_code      IN OUT NOCOPY VARCHAR2
         , x_alternate_routing_code IN OUT NOCOPY VARCHAR2
        )
        RETURN BOOLEAN
        IS
                l_organization_code      VARCHAR2(3);
                l_assembly_item_name     VARCHAR2(81);
                l_alternate_routing_code VARCHAR2(10);
                record_count             NUMBER;
        BEGIN

                ----  if Routing header record exist
                IF (p_rtg_header_rec.assembly_item_name IS NOT NULL AND
                    p_rtg_header_rec.assembly_item_name <> FND_API.G_MISS_CHAR)
                    OR
                    (p_rtg_header_rec.organization_code IS NOT NULL AND
                     p_rtg_header_rec.organization_code <> FND_API.G_MISS_CHAR)
                    OR
                    (p_rtg_header_rec.alternate_routing_code IS NOT NULL AND
                     p_rtg_header_rec.alternate_routing_code <>
                             FND_API.G_MISS_CHAR)
                THEN
                        l_assembly_item_name :=
                                        p_rtg_header_rec.assembly_item_name;
                        l_organization_code :=
                                        p_rtg_header_rec.organization_code;
                        l_alternate_routing_code :=
                                        p_rtg_header_rec.alternate_routing_code;
                        x_assembly_item_name :=
                                        p_rtg_header_rec.assembly_item_name;
                        x_organization_code :=
                                        p_rtg_header_rec.organization_code;
                        x_alternate_routing_code :=
                                        p_rtg_header_rec.alternate_routing_code;
                        IF NOT Does_Rev_Have_Same_Rtg
                        ( p_rtg_revision_tbl => p_rtg_revision_tbl
                        , p_assembly_item_name => l_assembly_item_name
                        , p_organization_code => l_organization_code
                        )
                        THEN
                                RETURN FALSE;
                        END IF;

                        IF NOT Does_Op_Have_Same_Rtg
                        ( p_operation_tbl        => p_operation_tbl
                        , p_assembly_item_name   => l_assembly_item_name
                        , p_organization_code    => l_organization_code
                        , p_alternate_routing_code =>
                                             l_alternate_routing_code
                        )
                        THEN
                                RETURN FALSE;
                        END IF;

                        IF NOT Does_Res_Have_Same_Rtg
                        ( p_op_resource_tbl     => p_op_resource_tbl
                        , p_assembly_item_name  => l_assembly_item_name
                        , p_organization_code   => l_organization_code
                        , p_alternate_routing_code =>
                                             l_alternate_routing_code
                        )
                        THEN
                                RETURN FALSE;
                        END IF;

                        IF NOT Does_SubRes_Have_Same_Rtg
                        ( p_sub_resource_tbl    => p_sub_resource_tbl
                        , p_assembly_item_name  => l_assembly_item_name
                        , p_organization_code   => l_organization_code
                        , p_alternate_routing_code =>
                                             l_alternate_routing_code
                        )
                        THEN
                                RETURN FALSE;
                        END IF;

                        IF NOT Does_OpNw_Have_Same_Rtg
                        ( p_op_network_tbl     =>  p_op_network_tbl
                        , p_assembly_item_name => l_assembly_item_name
                        , p_organization_code  => l_organization_code
                        , p_alternate_routing_code =>
                                             l_alternate_routing_code
                        )
                        THEN
                                RETURN FALSE;
                        END IF;


                        RETURN TRUE;

                END IF;

                ----  If revision records exist
                record_count := p_rtg_revision_tbl.COUNT;
                IF record_count <> 0
                THEN
                        l_assembly_item_name :=
                                p_rtg_revision_tbl(1).assembly_item_name;
                        l_organization_code :=
                                p_rtg_revision_tbl(1).organization_code;
                        x_assembly_item_name :=
                                p_rtg_revision_tbl(1).assembly_item_name;
                        x_organization_code :=
                                p_rtg_revision_tbl(1).organization_code;

                        l_alternate_routing_code := 'XXXXXXXXXX';
                        x_alternate_routing_code := 'XXXXXXXXXX';

                        IF record_count > 1
                        THEN

                          IF NOT Does_Rev_Have_Same_Rtg
                           ( p_rtg_revision_tbl    => p_rtg_revision_tbl
                           , p_assembly_item_name  => l_assembly_item_name
                           , p_organization_code   => l_organization_code
                           )
                          THEN
                                RETURN FALSE;
                          END IF;
                        END IF;

                         IF NOT Does_OP_Have_Same_Rtg
                           ( p_operation_tbl       => p_operation_tbl
                           , p_assembly_item_name  => l_assembly_item_name
                           , p_organization_code   => l_organization_code
                           , p_alternate_routing_code =>
                                   l_alternate_routing_code
                          )
                          THEN
                                RETURN FALSE;
                          END IF;

                          IF NOT Does_Res_Have_Same_Rtg
                           ( p_op_resource_tbl     => p_op_resource_tbl
                           , p_assembly_item_name  => l_assembly_item_name
                           , p_organization_code   => l_organization_code
                           , p_alternate_routing_code =>
                                   l_alternate_routing_code
                          )
                        THEN
                                RETURN FALSE;
                        END IF;

                        IF NOT Does_SubRes_Have_Same_Rtg
                            ( p_sub_resource_tbl    => p_sub_resource_tbl
                            , p_assembly_item_name  => l_assembly_item_name
                            , p_organization_code   => l_organization_code
                            , p_alternate_routing_code =>
                                             l_alternate_routing_code
                            )
                          THEN
                                RETURN FALSE;
                        END IF;

                       IF NOT Does_OpNw_Have_Same_Rtg
                        ( p_op_network_tbl     =>  p_op_network_tbl
                        , p_assembly_item_name => l_assembly_item_name
                        , p_organization_code  => l_organization_code
                        , p_alternate_routing_code =>
                                             l_alternate_routing_code
                        )
                        THEN
                                RETURN FALSE;
                       END IF;


                     RETURN TRUE;



                END IF;

                --  If operation records exist
                record_count := p_operation_tbl.COUNT;
                IF record_count <> 0
                THEN
                        l_assembly_item_name :=
                                p_operation_tbl(1).assembly_item_name;
                        l_organization_code :=
                                p_operation_tbl(1).organization_code;
                        x_assembly_item_name :=
                                p_operation_tbl(1).assembly_item_name;
                        x_organization_code :=
                                p_operation_tbl(1).organization_code;

                        l_alternate_routing_code :=
                             p_operation_tbl(1).alternate_routing_code;
                        x_alternate_routing_code :=
                             p_operation_tbl(1).alternate_routing_code;

                        IF record_count > 1
                        THEN

                          IF NOT Does_OP_Have_Same_Rtg
                           ( p_operation_tbl       => p_operation_tbl
                           , p_assembly_item_name  => l_assembly_item_name
                           , p_organization_code   => l_organization_code
                           , p_alternate_routing_code =>
                                   l_alternate_routing_code
                          )
                          THEN
                                RETURN FALSE;
                          END IF;
                        END IF;

                        IF NOT Does_Res_Have_Same_Rtg
                           ( p_op_resource_tbl     => p_op_resource_tbl
                           , p_assembly_item_name  => l_assembly_item_name
                           , p_organization_code   => l_organization_code
                           , p_alternate_routing_code =>
                                   l_alternate_routing_code
                          )
                        THEN
                                RETURN FALSE;
                        END IF;

                        IF NOT Does_SubRes_Have_Same_Rtg
                            ( p_sub_resource_tbl    => p_sub_resource_tbl
                            , p_assembly_item_name  => l_assembly_item_name
                            , p_organization_code   => l_organization_code
                            , p_alternate_routing_code =>
                                             l_alternate_routing_code
                            )
                          THEN
                                RETURN FALSE;
                        END IF;

                        IF NOT Does_OpNw_Have_Same_Rtg
                        ( p_op_network_tbl     =>  p_op_network_tbl
                        , p_assembly_item_name => l_assembly_item_name
                        , p_organization_code  => l_organization_code
                        , p_alternate_routing_code =>
                                             l_alternate_routing_code
                        )
                        THEN
                                RETURN FALSE;
                        END IF;

                     RETURN TRUE;

                END IF;

                --  If Operation Network records exist
                record_count := p_op_network_tbl.COUNT;
                IF record_count <> 0
                THEN
                        l_assembly_item_name :=
                                p_op_network_tbl(1).assembly_item_name;
                        l_organization_code :=
                                p_op_network_tbl(1).organization_code;
                        x_assembly_item_name :=
                                p_op_network_tbl(1).assembly_item_name;
                        x_organization_code :=
                                p_op_network_tbl(1).organization_code;
                        l_alternate_routing_code :=
                             p_op_network_tbl(1).alternate_routing_code;
                        x_alternate_routing_code :=
                             p_op_network_tbl(1).alternate_routing_code;

                         IF record_count > 1
                         THEN

                          IF NOT Does_OpNw_Have_Same_Rtg
                           ( p_op_network_tbl     =>  p_op_network_tbl
                           , p_assembly_item_name => l_assembly_item_name
                           , p_organization_code  => l_organization_code
                           , p_alternate_routing_code =>
                           l_alternate_routing_code
                          )
                          THEN
                                RETURN FALSE;
                          END IF;
                        END IF;

                        IF NOT Does_OP_Have_Same_Rtg
                           ( p_operation_tbl       => p_operation_tbl
                           , p_assembly_item_name  => l_assembly_item_name
                           , p_organization_code   => l_organization_code
                           , p_alternate_routing_code =>
                                   l_alternate_routing_code
                          )
                        THEN
                                RETURN FALSE;
                        END IF;

                        IF NOT Does_Res_Have_Same_Rtg
                           ( p_op_resource_tbl     => p_op_resource_tbl
                           , p_assembly_item_name  => l_assembly_item_name
                           , p_organization_code   => l_organization_code
                           , p_alternate_routing_code =>
                                   l_alternate_routing_code
                          )
                        THEN
                                RETURN FALSE;
                        END IF;

                        IF NOT Does_SubRes_Have_Same_Rtg
                            ( p_sub_resource_tbl    => p_sub_resource_tbl
                            , p_assembly_item_name  => l_assembly_item_name
                            , p_organization_code   => l_organization_code
                            , p_alternate_routing_code =>
                                             l_alternate_routing_code
                            )
                        THEN
                                RETURN FALSE;
                        END IF;
                     RETURN TRUE;

                END IF;

                --  If operation resource records exist
                record_count := p_op_resource_tbl.COUNT;
                IF record_count <> 0
                THEN
                        l_assembly_item_name :=
                                p_op_resource_tbl(1).assembly_item_name;
                        l_organization_code :=
                                p_op_resource_tbl(1).organization_code;
                        x_assembly_item_name :=
                                p_op_resource_tbl(1).assembly_item_name;
                        x_organization_code :=
                                p_op_resource_tbl(1).organization_code;

                        l_alternate_routing_code :=
                             p_op_resource_tbl(1).alternate_routing_code;
                        x_alternate_routing_code :=
                             p_op_resource_tbl(1).alternate_routing_code;

                        IF NOT Does_Res_Have_Same_Rtg
                        ( p_op_resource_tbl     => p_op_resource_tbl
                        , p_assembly_item_name  => l_assembly_item_name
                        , p_organization_code   => l_organization_code
                        , p_alternate_routing_code =>
                                             l_alternate_routing_code
                        )
                        THEN
                                RETURN FALSE;
                        END IF;

                        IF record_count > 1
                        THEN
                          IF NOT Does_Res_Have_Same_Rtg
                           ( p_op_resource_tbl     => p_op_resource_tbl
                           , p_assembly_item_name  => l_assembly_item_name
                           , p_organization_code   => l_organization_code
                           , p_alternate_routing_code =>
                                   l_alternate_routing_code
                          )
                          THEN
                                RETURN FALSE;
                          END IF;
                        END IF;

                         RETURN TRUE;

                END IF;


                --  If operation Substitute resouce records exist
                record_count := p_sub_resource_tbl.COUNT;
                IF record_count <> 0
                THEN
                        l_assembly_item_name :=
                                p_sub_resource_tbl(1).assembly_item_name;
                        l_organization_code :=
                                p_sub_resource_tbl(1).organization_code;
                        x_assembly_item_name :=
                                p_sub_resource_tbl(1).assembly_item_name;
                        x_organization_code :=
                                p_sub_resource_tbl(1).organization_code;

                        l_alternate_routing_code :=
                             p_sub_resource_tbl(1).alternate_routing_code;
                        x_alternate_routing_code :=
                             p_sub_resource_tbl(1).alternate_routing_code;



                        IF record_count > 1
                        THEN
                            IF NOT Does_SubRes_Have_Same_Rtg
                            ( p_sub_resource_tbl => p_sub_resource_tbl
                            , p_assembly_item_name  => l_assembly_item_name
                            , p_organization_code   => l_organization_code
                            , p_alternate_routing_code =>
                                             l_alternate_routing_code
                            )
                            THEN
                                RETURN FALSE;
                            END IF;
                        END IF;

                     RETURN TRUE;

                END IF;

                --
                -- If nothing to process then return TRUE.
                --
                RETURN TRUE;

        END Check_Records_In_Same_RTG;


        /********************************************************************
        * Procedure     : Process_Rtg
        * Parameters IN : Routing Header exposed column record
        *                 Routing revision exposed column table
        *                 Operation Exposed Column Table
        *                 Resource Exposed Column table
        *                 Substitute  Resource Exposed column table
        *                 Network Exposed column table
        * Parameters OUT: Routing Header exposed column record
        *                 Routing revision exposed column table
        *                 Operation Exposed Column Table
        *                 Resource Exposed Column table
        *                 Substitute  Resource Exposed column table
        *                 Network Exposed column table
        * Purpose       : This procedure is the driving procedure of the Rtg
        *                 business Obect. It will verify the integrity of the
        *                 business object and will call the private API which
        *                 further drive the business object to perform business
        *                 logic validations.
        *********************************************************************/
        PROCEDURE Process_Rtg
        ( p_bo_identifier           IN  VARCHAR2 := 'RTG'
        , p_api_version_number      IN  NUMBER := 1.0
        , p_init_msg_list           IN  BOOLEAN := FALSE
        , p_rtg_header_rec          IN  Bom_Rtg_Pub.Rtg_Header_Rec_Type
                                        :=Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
        , p_rtg_revision_tbl        IN  Bom_Rtg_Pub.Rtg_Revision_Tbl_Type
                                        :=Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
        , p_operation_tbl           IN  Bom_Rtg_Pub.Operation_Tbl_Type
                                        :=  Bom_Rtg_Pub.G_MISS_OPERATION_TBL
        , p_op_resource_tbl         IN  Bom_Rtg_Pub.Op_Resource_Tbl_Type
                                        :=  Bom_Rtg_Pub.G_MISS_OP_RESOURCE_TBL
        , p_sub_resource_tbl        IN  Bom_Rtg_Pub.Sub_Resource_Tbl_Type
                                       :=  Bom_Rtg_Pub.G_MISS_SUB_RESOURCE_TBL
        , p_op_network_tbl          IN  Bom_Rtg_Pub.Op_Network_Tbl_Type
                                        :=  Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
        , x_rtg_header_rec          IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Header_Rec_Type
        , x_rtg_revision_tbl        IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Revision_Tbl_Type
        , x_operation_tbl           IN OUT NOCOPY Bom_Rtg_Pub.Operation_Tbl_Type
        , x_op_resource_tbl         IN OUT NOCOPY Bom_Rtg_Pub.Op_Resource_Tbl_Type
        , x_sub_resource_tbl        IN OUT NOCOPY Bom_Rtg_Pub.Sub_Resource_Tbl_Type
        , x_op_network_tbl          IN OUT NOCOPY Bom_Rtg_Pub.Op_Network_Tbl_Type
        , x_return_status           IN OUT NOCOPY VARCHAR2
        , x_msg_count               IN OUT NOCOPY NUMBER
        , p_debug                   IN  VARCHAR2 := 'N'
        , p_output_dir              IN  VARCHAR2 := NULL
        , p_debug_filename          IN  VARCHAR2 := 'RTG_BO_debug.log'
        )
       IS

       G_EXC_SEV_QUIT_OBJECT       EXCEPTION;
       G_EXC_UNEXP_SKIP_OBJECT     EXCEPTION;
       l_Mesg_Token_Tbl            Error_Handler.Mesg_Token_Tbl_Type;
       l_other_message             VARCHAR2(50);
       l_Token_Tbl                 Error_Handler.Token_Tbl_Type;
       l_err_text                  VARCHAR2(2000);
       l_return_status             VARCHAR2(1);
       l_assembly_item_name        VARCHAR2(81);
       l_organization_code         VARCHAR2(3);
       l_organization_id           NUMBER;
       l_alternate_routing_code    VARCHAR2(10);
       l_rtg_header_rec            Bom_Rtg_Pub.Rtg_Header_Rec_Type;
       l_routing_revision_tbl      Bom_Rtg_Pub.Rtg_Revision_Tbl_Type ;
       l_operation_tbl             Bom_Rtg_Pub.Operation_Tbl_Type;
       l_op_resource_tbl           Bom_Rtg_Pub.Op_Resource_Tbl_Type ;
       l_sub_resource_tbl          Bom_Rtg_Pub.Sub_Resource_Tbl_Type;
       l_op_network_tbl            Bom_Rtg_Pub.Op_Network_Tbl_Type;
       l_Debug_flag                VARCHAR2(1) := p_debug;

       BEGIN

--dbms_output.put_line('In Bom_Rtg_Globals . . .' ) ;
--dbms_output.put_line('Set Business Object Idenfier in the System Information. . .' ) ;
                --
                -- Set Business Object Idenfier in the System Information
                -- record.
                --
/* Following code takes care ot setting the desired value after the entry into the Process_Rtg Procedure instead of defaulting the parameters
                IF p_bo_identifier IS NULL THEN
                  p_bo_identifier := 'RTG';
                END IF;
                IF p_rtg_header_rec IS NULL THEN
                  p_rtg_header_rec := Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC;
                END IF;
                IF p_rtg_revision_tbl IS NULL THEN
                  p_rtg_revision_tbl := Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL;
                END IF;
                IF p_operation_tbl IS NULL THEN
                  p_operation_tbl := Bom_Rtg_Pub.G_MISS_OPERATION_TBL;
                END IF;
                IF p_op_resource_tbl IS NULL THEN
                  p_op_resource_tbl := Bom_Rtg_Pub.G_MISS_OP_RESOURCE_TBL;
                END IF;
                IF p_sub_resource_tbl IS NULL THEN
                  p_sub_resource_tbl := Bom_Rtg_Pub.G_MISS_SUB_RESOURCE_TBL;
                END IF;
                IF p_op_network_tbl IS NULL THEN
                  p_op_network_tbl := Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL;
                END IF;
*/
                BOM_Rtg_Globals.Set_Bo_Identifier
                            (p_bo_identifier => p_bo_identifier);

--dbms_output.put_line('End of Setting Business Object Idenfier in the System Information. . .' ) ;
                --
                -- Initialize the message list if the user has set the
                -- Init Message List parameter
                --
                IF p_init_msg_list
                THEN
--dbms_output.put_line('Error_Handler.Initialize. . .' ) ;
                        Error_Handler.Initialize;
                END IF;


                IF l_Debug_flag IS NULL THEN
                  l_Debug_flag := 'N';
                END IF;
                IF l_debug_flag = 'Y'
                THEN

                     IF trim(p_output_dir) IS NULL OR
                        trim(p_output_dir) = ''
                     THEN
                         -- If debug is Y then out dir must be
                         -- specified


--dbms_output.put_line('Debug Y ,then Add_Error_Token. . .' ) ;

                         Error_Handler.Add_Error_Token
                         (  p_Message_text       =>
                                   'Debug is set to Y so an output directory' ||
                                   ' must be specified. Debug will be turned' ||
                                   ' off since no directory is specified'
                          , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                          , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                          , p_Token_Tbl          => l_token_tbl
                         );

--dbms_output.put_line('Debug Y ,then Log_Error. . .' ) ;

                         Bom_Rtg_Error_Handler.Log_Error
                         (  p_rtg_header_rec        => p_rtg_header_rec
                         ,  p_rtg_revision_tbl      => p_rtg_revision_tbl
                         ,  p_operation_tbl         => p_operation_tbl
                         ,  p_op_resource_tbl       => p_op_resource_tbl
                         ,  p_sub_resource_tbl      => p_sub_resource_tbl
                         ,  p_op_network_tbl        => p_op_network_tbl
                         ,  p_mesg_token_tbl        => l_mesg_token_tbl
                         ,  p_error_status          => 'W'
                         ,  p_error_scope           => NULL
                         ,  p_error_level           => Error_Handler.G_BO_LEVEL
                         , p_other_message          => NULL
                         , p_other_mesg_appid       => 'BOM'
                         , p_other_status           => NULL
                         , p_other_token_tbl        =>
                                     Error_Handler.G_MISS_TOKEN_TBL
                         , p_entity_index           => 1
                         ,  x_rtg_header_rec        => l_rtg_header_rec
                         ,  x_rtg_revision_tbl      => l_routing_revision_tbl
                         ,  x_operation_tbl         => l_operation_tbl
                         ,  x_op_resource_tbl       => l_op_resource_tbl
                         ,  x_sub_resource_tbl      => l_sub_resource_tbl
                         ,  x_op_network_tbl        => l_op_network_tbl
                         );


                         l_debug_flag := 'N' ;

                     END IF;

                     IF trim(p_debug_filename) IS NULL OR
                        trim(p_debug_filename) = ''
                     THEN

                         Error_Handler.Add_Error_Token
                         (  p_Message_text       =>
                                  ' Debug is set to Y so an output filename' ||
                                  ' must be specified. Debug will be turned' ||
                                  ' off since no filename is specified'
                          , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                          , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                          , p_Token_Tbl          => l_token_tbl
                         );

                         Bom_Rtg_Error_Handler.Log_Error
                          (  p_rtg_header_rec        => p_rtg_header_rec
                          ,  p_rtg_revision_tbl      => p_rtg_revision_tbl
                          ,  p_operation_tbl         => p_operation_tbl
                          ,  p_op_resource_tbl       => p_op_resource_tbl
                          ,  p_sub_resource_tbl      => p_sub_resource_tbl
                          ,  p_op_network_tbl        => p_op_network_tbl
                          ,  p_mesg_token_tbl        => l_mesg_token_tbl
                          ,  p_error_status          => 'W'
                          ,  p_error_level           => Error_Handler.G_BO_LEVEL
                          , p_error_scope            => NULL
                          , p_other_message          => NULL
                          , p_other_mesg_appid       => 'BOM'
                          , p_other_status           => NULL
                          , p_other_token_tbl        =>
                                     Error_Handler.G_MISS_TOKEN_TBL
                          , p_entity_index           => 1

                          ,  x_rtg_header_rec        => l_rtg_header_rec
                          ,  x_rtg_revision_tbl      => l_routing_revision_tbl
                          ,  x_operation_tbl         => l_operation_tbl
                          ,  x_op_resource_tbl       => l_op_resource_tbl
                          ,  x_sub_resource_tbl      => l_sub_resource_tbl
                          ,  x_op_network_tbl        => l_op_network_tbl
                         );
                              l_debug_flag := 'N';

                      END IF;

                      BOM_Rtg_Globals.Set_Debug(l_debug_flag);

                      IF l_debug_flag = 'Y'
                      THEN
                          Error_Handler.Open_Debug_Session
                          (  p_debug_filename     => p_debug_filename
                           , p_output_dir         => p_output_dir
                           , x_return_status      => l_return_status
                           , p_mesg_token_tbl     => l_mesg_token_tbl
                           , x_mesg_token_tbl     => l_mesg_token_tbl
                          );

                          IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                          THEN
                                BOM_Rtg_Globals.Set_Debug('N');
                          END IF;
                      END IF;
                END IF;


IF BOM_Rtg_Globals.get_debug = 'Y' THEN
    Error_Handler.Write_Debug('The Routing BO as passed ');
    Error_Handler.Write_Debug('-----------------------------------------------------') ;
    Error_Handler.Write_Debug('Header Rec - Assembly Item : ' || p_rtg_header_rec.assembly_item_name);
    Error_Handler.Write_Debug('Num of Routing Revisions   : ' || p_rtg_revision_tbl.COUNT);
    Error_Handler.Write_Debug('Num of Operations          : ' || p_operation_tbl.COUNT);
    Error_Handler.Write_Debug('Num of Resources           : ' || p_op_resource_tbl.COUNT);
    Error_Handler.Write_Debug('Num of Substitue Resources : ' || p_sub_resource_tbl.COUNT);
    Error_Handler.Write_Debug('Num of Operation Network   : ' || p_op_network_tbl.COUNT);
    Error_Handler.Write_Debug('-----------------------------------------------------') ;
END IF;
/* Following code is for Patchset G because we are suppressing the OSFM support
  as the OSFM team's request. This will be added in Patchset H */
  --for OSFM import routings
  --IF p_rtg_header_rec.cfm_routing_flag = 3 THEN
  --   l_other_message := 'BOM_RBO_NO_OSFM_RTG_SUPPORT';
  --   RAISE G_EXC_SEV_QUIT_OBJECT;
  --END IF;

                --
                -- Verify if all the entity record(s) belong to the same
                -- business object
                --
--dbms_output.put_line('Verify if all the entity record(s) belong to the same bo. . .' ) ;

                IF NOT Check_Records_In_Same_RTG
                   (  p_rtg_header_rec          => p_rtg_header_rec
                    , p_rtg_revision_tbl        => p_rtg_revision_tbl
                    , p_operation_tbl           => p_operation_tbl
                    , p_op_resource_tbl         => p_op_resource_tbl
                    , p_sub_resource_tbl        => p_sub_resource_tbl
                    , p_op_network_tbl          => p_op_network_tbl
                    , x_assembly_item_name      => l_assembly_item_name
                    , x_organization_code       => l_organization_code
                    , x_alternate_routing_code  => l_alternate_routing_code
                    )
                THEN
                        l_other_message := 'BOM_MUST_BE_IN_SAME_RTG';
                        RAISE G_EXC_SEV_QUIT_OBJECT;
                END IF;

                IF (l_assembly_item_name IS NULL OR
                    l_assembly_item_name = FND_API.G_MISS_CHAR)
                    OR
                    (l_organization_code IS NULL OR
                     l_organization_code = FND_API.G_MISS_CHAR)
                THEN
                        l_other_message := 'BOM_ASSY_OR_ORG_MISSING';
                        RAISE G_EXC_SEV_QUIT_OBJECT;
                END IF;


                l_organization_id := BOM_Rtg_Val_To_Id.Organization
                                     (  p_organization => l_organization_code
                                      , x_err_text => l_err_text
                                     );

                IF l_organization_id IS NULL
                THEN
                        l_other_message := 'BOM_ORG_INVALID';
                        l_token_tbl(1).token_name := 'ORG_CODE';
                        l_token_tbl(1).token_value := l_organization_code;
                        RAISE G_EXC_SEV_QUIT_OBJECT;

                ELSIF l_organization_id = FND_API.G_MISS_NUM
                THEN
                        l_other_message := 'BOM_UNEXP_ORG_INVALID';
                        RAISE G_EXC_UNEXP_SKIP_OBJECT;
                END IF;


                --
                -- Set Organization Id in the System Information record.
                --
                BOM_Rtg_Globals.Set_Org_Id( p_org_id => l_organization_id);

		--
		-- Set Application Id in the appication context and set the
		-- fine-grained security policy on bom_alternate_designators
		-- table. This is currently applicable only if the application
		-- calling this BO is EAM
		--
		Bom_Set_Context.set_application_id;

		--
                -- Call the Private API for performing further business
                -- rules validation
                --
--dbms_output.put_line('Call the Private API Process_Rtg. . .' ) ;

                Bom_Rtg_Pvt.Process_Rtg
                (   p_api_version_number     =>  p_api_version_number
                ,   p_validation_level       =>  FND_API.G_VALID_LEVEL_FULL
                ,   x_return_status          =>  l_return_status
                ,   x_msg_count              =>  x_msg_count
                ,   p_rtg_header_rec         =>  p_rtg_header_rec
                ,   p_rtg_revision_tbl       =>  p_rtg_revision_tbl
                ,   p_operation_tbl          =>  p_operation_tbl
                ,   p_op_resource_tbl        =>  p_op_resource_tbl
                ,   p_sub_resource_tbl       =>  p_sub_resource_tbl
                ,   p_op_network_tbl         =>  p_op_network_tbl
                ,   x_rtg_header_rec         =>  x_rtg_header_rec
                ,   x_rtg_revision_tbl       =>  x_rtg_revision_tbl
                ,   x_operation_tbl          =>  x_operation_tbl
                ,   x_op_resource_tbl        =>  x_op_resource_tbl
                ,   x_sub_resource_tbl       =>  x_sub_resource_tbl
                ,   x_op_network_tbl         =>  x_op_network_tbl
                );

                BOM_Rtg_Globals.Set_Org_Id( p_org_id    => NULL);
                BOM_Rtg_Globals.Set_Eco_Name( p_eco_name => NULL);

                IF l_return_status <> 'S'
                THEN
                    -- Call Error Handler
                    l_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                    l_token_tbl(1).token_value := l_assembly_item_name;
                    l_token_tbl(2).token_name := 'ORGANIZATION_CODE';
                    l_token_tbl(2).token_value := l_organization_code;

                    Bom_Rtg_Error_Handler.Log_Error
                    (
                      p_rtg_header_rec      => p_rtg_header_rec
                    , p_rtg_revision_tbl    => p_rtg_revision_tbl
                    , p_operation_tbl       => p_operation_tbl
                    , p_op_resource_tbl     => p_op_resource_tbl
                    , p_sub_resource_tbl    => p_sub_resource_tbl
                    , p_op_network_tbl      => p_op_network_tbl
                    , p_Mesg_Token_tbl      => Error_Handler.G_MISS_MESG_TOKEN_TBL
                    , p_error_status        => l_return_status
                    , p_error_scope         => Error_Handler.G_SCOPE_ALL
                    , p_error_level         => Error_Handler.G_BO_LEVEL
                    , p_other_message       => 'BOM_ERROR_BUSINESS_OBJECT'
                    , p_other_status        => l_return_status
                    , p_other_token_tbl     => l_token_tbl
                    , p_other_mesg_appid    => 'BOM'
                    , p_entity_index        => 1
                    , x_rtg_header_rec      => l_rtg_header_rec
                    , x_rtg_revision_tbl    => l_routing_revision_tbl
                    , x_operation_tbl       => l_operation_tbl
                    , x_op_resource_tbl     => l_op_resource_tbl
                    , x_sub_resource_tbl    => l_sub_resource_tbl
                    , x_op_network_tbl      => l_op_network_tbl
                    );

                END IF;
/*
                IF l_return_status <> 'S'
                THEN
                    -- Call Error Handler
                    l_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                    l_token_tbl(1).token_value := l_assembly_item_name;
                    l_token_tbl(2).token_name := 'ORGANIZATION_CODE';
                    l_token_tbl(2).token_value := l_organization_code;

                    Bom_Rtg_Error_Handler.Log_Error
                    (
                      p_rtg_header_rec      =>
                                       Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
                    , p_rtg_revision_tbl    =>
                                       Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
                    , p_operation_tbl       =>
                                       Bom_Rtg_Pub.G_MISS_OPERATION_TBL
                    , p_op_resource_tbl     =>
                                       Bom_Rtg_Pub.G_MISS_OP_RESOURCE_TBL
                    , p_sub_resource_tbl    =>
                                       Bom_Rtg_Pub.G_MISS_SUB_RESOURCE_TBL
                    , p_op_network_tbl      =>
                                       Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
                    , p_Mesg_Token_tbl      => Error_Handler.G_MISS_MESG_TOKEN_TBL
                    , p_error_status        => l_return_status
                    , p_error_scope         => Error_Handler.G_SCOPE_ALL
                    , p_error_level         => Error_Handler.G_BO_LEVEL
                    , p_other_message       => 'BOM_ERROR_BUSINESS_OBJECT'
                    , p_other_status        => l_return_status
                    , p_other_token_tbl     => l_token_tbl
                    , p_other_mesg_appid    => 'BOM'
                    , p_entity_index        => 1
                    , x_rtg_header_rec      => l_rtg_header_rec
                    , x_rtg_revision_tbl    => l_rtg_revision_tbl
                    , x_operation_tbl       => l_operation_tbl
                    , x_op_resource_tbl     => l_op_resource_tbl
                    , x_sub_resource_tbl    => l_sub_resource_tbl
                    , x_op_network_tbl      => l_op_network_tbl
                    );
                END IF;
*/
                x_return_status := l_return_status;
                x_msg_count := Error_Handler.Get_Message_Count;
                IF Bom_Rtg_Globals.Get_Debug = 'Y'
                THEN
                        Error_Handler.Close_Debug_Session;
                END IF;

       EXCEPTION
       WHEN G_EXC_SEV_QUIT_OBJECT THEN

                -- Call Error Handler
                Bom_Rtg_Error_Handler.Log_Error
                ( p_rtg_header_rec        => p_rtg_header_rec
                , p_rtg_revision_tbl      => p_rtg_revision_tbl
                , p_operation_tbl         => p_operation_tbl
                , p_op_resource_tbl       => p_op_resource_tbl
                , p_sub_resource_tbl      => p_sub_resource_tbl
                , p_op_network_tbl        => p_op_network_tbl
                , p_Mesg_Token_Tbl        => l_Mesg_Token_Tbl
                , p_error_status          => Error_Handler.G_STATUS_ERROR
                , p_error_level           => Error_Handler.G_BO_LEVEL
                , p_error_scope           => Error_Handler.G_SCOPE_ALL
                , p_other_status          => Error_Handler.G_STATUS_NOT_PICKED
                , p_other_message         => l_other_message
                , p_other_token_tbl       => l_token_tbl
                , p_other_mesg_appid      => 'BOM'
                , p_entity_index          => 1
                , x_rtg_header_rec        => l_rtg_header_rec
                , x_rtg_revision_tbl      => l_routing_revision_tbl
                , x_operation_tbl         => l_operation_tbl
                , x_op_resource_tbl       => l_op_resource_tbl
                , x_sub_resource_tbl      => l_sub_resource_tbl
                , x_op_network_tbl        => l_op_network_tbl
                );

                x_return_status := Error_Handler.G_STATUS_ERROR;
                x_msg_count := Error_Handler.Get_Message_Count;
                IF Bom_Rtg_Globals.Get_Debug = 'Y'
                THEN
                        Error_Handler.Close_Debug_Session;
                END IF;

        WHEN G_EXC_UNEXP_SKIP_OBJECT THEN

                -- Call Error Handler
                Bom_Rtg_Error_Handler.Log_Error
                ( p_rtg_header_rec        => p_rtg_header_rec
                , p_rtg_revision_tbl      => p_rtg_revision_tbl
                , p_operation_tbl         => p_operation_tbl
                , p_op_resource_tbl       => p_op_resource_tbl
                , p_sub_resource_tbl      => p_sub_resource_tbl
                , p_op_network_tbl        => p_op_network_tbl
                , p_Mesg_Token_Tbl        => l_Mesg_Token_Tbl
                , p_error_status          => Error_Handler.G_STATUS_UNEXPECTED
                , p_error_scope           => NULL
                , p_error_level           => Error_Handler.G_BO_LEVEL
                , p_other_status          => Error_Handler.G_STATUS_NOT_PICKED
                , p_other_message         => l_other_message
                , p_other_mesg_appid      => 'BOM'
                , p_other_token_tbl       => l_token_tbl
                , p_entity_index          => 1
                , x_rtg_header_rec        => l_rtg_header_rec
                , x_rtg_revision_tbl      => l_routing_revision_tbl
                , x_operation_tbl         => l_operation_tbl
                , x_op_resource_tbl       => l_op_resource_tbl
                , x_sub_resource_tbl      => l_sub_resource_tbl
                , x_op_network_tbl        => l_op_network_tbl
                );

                x_return_status := Error_Handler.G_STATUS_UNEXPECTED;
                x_msg_count := Error_Handler.Get_Message_Count;
                IF Bom_Rtg_Globals.Get_Debug = 'Y'
                THEN
                        Error_Handler.Close_Debug_Session;
                END IF;

        END Process_Rtg;

END Bom_Rtg_Pub ;

/
