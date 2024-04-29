--------------------------------------------------------
--  DDL for Package IGI_IAC_COMMON_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_COMMON_UTILS" AUTHID CURRENT_USER AS
-- $Header: igiiacus.pls 120.6.12000000.1 2007/08/01 16:14:00 npandya ship $

   debug_on_test boolean;
-- DMahajan Start
 Function Get_Period_Info_for_Counter( P_book_type_Code IN VARCHAR2 ,
                                                        P_period_Counter IN NUMBER ,
                                                        P_prd_rec       OUT NOCOPY igi_iac_types.prd_rec
                                                        )
 RETURN BOOLEAN ;




 Function Get_Period_Info_for_Date( P_book_type_Code IN VARCHAR2 ,
                                                     P_date           IN DATE ,
                                                     p_prd_rec       OUT NOCOPY igi_iac_types.prd_rec
                                                     )
 RETURN BOOLEAN ;



 Function Get_Period_Info_for_Name( P_book_type_Code IN VARCHAR2 ,
                                                     P_Prd_Name       IN VARCHAR2 ,
                                                     p_prd_rec       OUT NOCOPY igi_iac_types.prd_rec
                                                     )
 RETURN BOOLEAN ;



 Function Get_Open_Period_Info ( P_book_type_Code IN VARCHAR2 ,
                                                  p_prd_rec       OUT NOCOPY igi_iac_types.prd_rec
                                                  )
 RETURN BOOLEAN ;




 Function Get_Retirement_Info ( P_Retirement_Id   IN NUMBER ,
                                                 P_Retire_Info    OUT NOCOPY fa_retirements%ROWTYPE
                                                 )
 RETURN BOOLEAN ;



 Function Get_Units_Info_for_Gain_Loss (P_asset_id  IN NUMBER ,
                                                         P_Book_type_code  IN VARCHAR2 ,
                                                         P_Retirement_Id   IN NUMBER ,
--                                                         P_Calling_txn     IN NUMBER ,
                                                         P_Calling_txn     IN VARCHAR2,
                                                         P_Units_Before   OUT NOCOPY NUMBER ,
                                                         P_Units_After    OUT NOCOPY NUMBER
                                                         )
 RETURN BOOLEAN ;



 Function  Get_Cost_Retirement_Factor ( P_Book_Type_code  IN VARCHAR2 ,
                                        P_Asset_id IN NUMBER ,
--                                        P_Transaction_header_id IN NUMBER ,
                                        P_Retirement_Id IN NUMBER ,
                                        P_Factor OUT NOCOPY NUMBER
                                        )
 RETURN BOOLEAN ;


-- Function Is_Part_Ret_Unit_or_Cost( P_book_type_Code IN VARCHAR2 ,
 Function          Get_Retirement_Type( P_book_type_Code IN VARCHAR2 ,
                                                     P_Asset_id       IN NUMBER ,
--                                                     P_Transaction_header_id IN NUMBER ,
                                                     P_Retirement_Id IN NUMBER ,
                                                     P_Type   OUT NOCOPY VARCHAR2
                                                     )
 RETURN BOOLEAN ;



 Function Prorate_Amt_to_Active_Dists( P_book_type_Code IN VARCHAR2 ,
                                                     P_Asset_id       IN NUMBER ,
                                                     P_Amount         IN NUMBER ,
                                                     P_out_tab       OUT NOCOPY igi_iac_types.dist_amt_tab
                                                     )
 RETURN BOOLEAN ;



 Function Get_Active_Distributions ( P_book_type_Code IN VARCHAR2 ,
                                                      P_Asset_id       IN NUMBER ,
                                                      P_dh_tab        OUT NOCOPY igi_iac_types.dh_tab
                                                      )
 RETURN BOOLEAN ;



 Function Get_CY_PY_Factors( P_book_type_Code IN VARCHAR2 ,
                                              P_Asset_id       IN NUMBER ,
                                              P_Period_Name    IN VARCHAR2 ,
                                              P_PY_Ratio      OUT NOCOPY NUMBER ,
                                              P_CY_Ratio      OUT NOCOPY  NUMBER
                                              )
 RETURN BOOLEAN ;



 Function Is_Asset_Rvl_in_curr_Period( P_book_type_Code IN VARCHAR2 ,
                                                        P_Asset_id       IN NUMBER
                                                        )
 RETURN BOOLEAN ;



 Function Any_Txns_In_Open_Period( P_book_type_Code IN VARCHAR2 ,
                                                    P_Asset_id       IN NUMBER
                                                    )
 RETURN BOOLEAN ;



 Function Any_Adj_In_Book( P_book_type_Code IN VARCHAR2 ,
                                            P_Asset_id       IN NUMBER
                                            )
 RETURN BOOLEAN ;



 Function Any_Reval_in_Corp_Book( P_book_type_Code IN VARCHAR2 ,
                                                   P_Asset_id       IN NUMBER
                                                   )
 RETURN BOOLEAN ;



 Function Any_Ret_In_Curr_Yr    ( P_book_type_Code IN  VARCHAR2 ,
                                                   P_Asset_id       IN  NUMBER ,
                                                   P_retirements    OUT NOCOPY VARCHAR2
                                                   )
 RETURN BOOLEAN ;

 --DMahajan End


 -- Niyer Start

 FUNCTION Is_Asset_Proc (
        X_book_type_code   IN  VARCHAR2,
        X_asset_id         IN  VARCHAR2 )
   RETURN BOOLEAN ;

   FUNCTION Get_Dpis_Period_Counter (
        X_book_type_code IN Varchar2,
        X_asset_id       IN Varchar2,
        X_Period_Counter OUT NOCOPY Varchar2 )
   RETURN BOOLEAN;

   FUNCTION Get_Price_Index (
        X_book_type_code IN VARCHAR2,
        X_asset_id       IN Varchar2,
        X_Price_Index_Id OUT NOCOPY NUMBER,
        X_Price_Index_Name OUT NOCOPY VARCHAR2 )
   RETURN BOOLEAN;

   FUNCTION Get_Price_Index_Value (
        X_book_type_code IN VARCHAR2,
        X_asset_id       IN Varchar2,
        X_Period_Name	IN VARCHAR2,
        X_Price_Index_Value OUT NOCOPY NUMBER )
    RETURN BOOLEAN;

  -- Niyer End

  -- Shekar Start

  FUNCTION Is_IAC_Book ( X_book_type_code   IN  VARCHAR2 )
   RETURN BOOLEAN ;

   FUNCTION Get_Latest_Transaction (
   		X_book_type_code IN Varchar2,
   		X_asset_id		IN	Number,
   		X_Transaction_Type_Code	IN OUT NOCOPY	Varchar2,
   		X_Transaction_Id	IN OUT NOCOPY	Number,
   		X_Mass_Reference_ID	IN OUT NOCOPY	Number,
   		X_Adjustment_Id		OUT NOCOPY	Number,
   		X_Prev_Adjustment_Id	OUT NOCOPY	Number,
   		X_Adjustment_Status	OUT NOCOPY	Varchar2)
   RETURN BOOLEAN;

   FUNCTION Get_Book_GL_Info (
        X_book_type_code IN VARCHAR2,
        Set_Of_Books_Id IN OUT NOCOPY NUMBER,
        Chart_Of_Accounts_Id IN OUT NOCOPY NUMBER,
        Currency IN OUT NOCOPY VARCHAR2,
        Precision IN OUT NOCOPY NUMBER )
   RETURN BOOLEAN;

   FUNCTION Get_Account_Segment_Value (
        X_sob_id                IN gl_sets_of_books.set_of_books_id%TYPE,
        X_code_combination_id   IN fa_distribution_history.code_combination_id%TYPE,
        X_segment_type          IN VARCHAR2 ,
        X_segment_value         IN OUT NOCOPY VARCHAR2 )
    RETURN BOOLEAN;

    FUNCTION Get_Distribution_Ccid (
        X_book_type_code IN VARCHAR2,
        X_asset_id       IN NUMBER,
        X_Distribution_Id IN NUMBER,
        Dist_CCID IN OUT NOCOPY NUMBER )
     RETURN BOOLEAN;



    FUNCTION Get_Default_Account (
        X_book_type_code IN VARCHAR2,
        Default_Account IN OUT NOCOPY NUMBER )
     RETURN BOOLEAN;

    FUNCTION Get_Account_CCID (
        X_book_type_code IN VARCHAR2,
        X_asset_id       IN NUMBER,
        X_Distribution_ID IN NUMBER,
        X_Account_Type    IN VARCHAR2,
        Account_CCID IN OUT NOCOPY NUMBER )
     RETURN BOOLEAN;

     FUNCTION Get_Account_CCID (
        X_book_type_code IN VARCHAR2,
        X_asset_id       IN NUMBER,
        X_Distribution_ID IN NUMBER,
        X_Account_Type    IN VARCHAR2,
        X_Transaction_Header_ID IN NUMBER,
        X_Calling_function IN VARCHAR2,
        Account_CCID IN OUT NOCOPY NUMBER )
     RETURN BOOLEAN;

     Procedure debug_on;

     Procedure debug_off;
     procedure debug_write(stmt varchar2);

 -- Shekar End

 -- M Hazarika, 07-05-2002, start

    FUNCTION Iac_Round(
               X_Amount  IN OUT NOCOPY NUMBER,
               X_book    IN     VARCHAR2)
    RETURN BOOLEAN;

 -- M Hazarika, 07-05-2002, end

     FUNCTION Populate_iac_fa_deprn_data(
                X_book_type_code    IN VARCHAR2
                ,X_calling_mode     IN VARCHAR2)
    RETURN BOOLEAN;


    /* Added for Bug 5846861 by Venkataramanan S on 02-Feb-2007
    FUNCTION NAME: Is_Asset_Adjustment_Done
    PARAMETERS: Book Type Code and Asset Id
    RETURN TYPE: BOOLEAN
    DESCRIPTION: This function checks whether adjustments have been made in the
    open period for the given Asset and Book combination. A "BOOLEAN TRUE" is
    returned if adjustments have been done. A "BOOLEAN FALSE" is returned otherwise
    */
    FUNCTION Is_Asset_Adjustment_Done(
        X_book_type_code IN VARCHAR2,
        X_asset_id       IN NUMBER)
    RETURN BOOLEAN;


END; --package spec

 

/
