--------------------------------------------------------
--  DDL for Package Body OE_OE_FOLDER_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_OE_FOLDER_EXT" AS
/* $Header: OEXFEXTB.pls 120.1.12010000.1 2008/07/25 07:47:56 appldev ship $ */

PROCEDURE Get_Customized_Buttons
               (
               p_folder_id        IN  Number
             , x_custom_buttons_tbl OUT NOCOPY /* file.sql.39 change */ Oe_Oe_Folder_Ext.Config_Buttons_Tbl
             , x_default_buttons_tbl OUT NOCOPY /* file.sql.39 change */ Oe_Oe_Folder_Ext.Config_Buttons_Tbl
                )
   IS
   /*Commented for Bug 6829128
   CURSOR C1(l_folder_id Number) IS
   SELECT action_id,object,action_name,user_entered_prompt,
         folder_id,width,access_key,DISPLAY_AS_BUTTON_FLAG
   FROM  OE_Custom_Actions
   WHERE DISPLAY_AS_BUTTON_FLAG='Y' AND
         folder_id=l_folder_id;*/

   --Modified for Bug#6829128
   CURSOR C1(l_folder_id Number) is
   SELECT *
   FROM
     (SELECT action_id,
        object,
        action_name,
        user_entered_prompt,
        folder_id,
        width,
        access_key,
        display_as_button_flag,
        nvl(user_entered_prompt,    default_prompt) PROMPT
     FROM oe_custom_actions
      WHERE display_as_button_flag = 'Y'
      AND folder_id = l_folder_id
      UNION
      SELECT action_id,
        object,
        action_name,
        NULL,
        NULL,
        width,
        NULL,
        display_as_button_flag,
        decode(action_name,    'RITEMS',    'Related Items',    'BOOK_ORDER',    'Book Order',    initcap(action_name)) PROMPT
     FROM oe_default_actions od
      WHERE display_as_button_flag = 'Y'
      AND NOT EXISTS
       (SELECT action_id
        FROM oe_custom_actions oc
        WHERE oc.action_id = od.action_id
        AND folder_id = l_folder_id)
     )
   ORDER BY PROMPT;
   --End of Bug#6829128

   CURSOR C2(l_folder_id Number) IS
   SELECT action_id,object,action_name,
         width,DISPLAY_AS_BUTTON_FLAG
   FROM  OE_Default_Actions  OD
   WHERE DISPLAY_AS_BUTTON_FLAG='Y' AND
   NOT EXISTS
  (SELECT action_id FROM
   OE_CUSTOM_ACTIONS OC
   WHERE OC.action_id=OD.action_id
   AND Folder_Id=l_folder_id);

   l_count Number:=1;
BEGIN



     FOR BUTTONS IN C1(p_folder_id)
     LOOP
       x_custom_buttons_tbl(l_count).Action_Id:=BUTTONS.Action_id;
       x_custom_buttons_tbl(l_count).Action_Name:=BUTTONS.Action_Name;
       x_custom_buttons_tbl(l_count).User_Entered_Prompt:=BUTTONS.User_Entered_Prompt;
       x_custom_buttons_tbl(l_count).Folder_Id:=BUTTONS.Folder_Id;
       x_custom_buttons_tbl(l_count).Width:=BUTTONS.Width;
       x_custom_buttons_tbl(l_count).access_key:=BUTTONS.access_key;
       x_custom_buttons_tbl(l_count).display_as_button:=
               BUTTONS.display_as_button_flag;
       l_count:=l_count+1;
     END LOOP;

    l_count:=1;
     FOR BUTTONS IN C2(p_folder_id)
     LOOP
       x_default_buttons_tbl(l_count).Action_Id:=BUTTONS.Action_id;
       x_default_buttons_tbl(l_count).Action_Name:=BUTTONS.Action_Name;
       x_default_buttons_tbl(l_count).Width:=BUTTONS.Width;
       x_default_buttons_tbl(l_count).display_as_button:=
                    BUTTONS.display_as_button_flag;
       l_count:=l_count+1;
     END LOOP;

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
    Null;
   WHEN TOO_MANY_ROWS THEN
    Null;
   WHEN OTHERS THEN
    Null;
END Get_Customized_Buttons;


PROCEDURE Get_Buttons_List
               (
               p_folder_id        IN  Number
             , p_displayed_buttons IN Oe_Oe_Folder_Ext.Config_Buttons_Tbl
             , x_buttons_tbl OUT NOCOPY /* file.sql.39 change */ Oe_Oe_Folder_Ext.Config_Buttons_Tbl
                )
   IS
   CURSOR C1(l_folder_id Number) IS
   SELECT action_id,object,action_name,user_entered_prompt,
         folder_id,width,access_key,display_as_button_flag,default_prompt
   FROM  OE_Custom_Actions
   WHERE folder_id=l_folder_id;

   CURSOR C2(l_folder_id Number) IS
   SELECT action_id,object,action_name,
         width,display_as_button_flag
   FROM  OE_Default_Actions  OD
   WHERE  NOT EXISTS
  (SELECT action_id FROM
   OE_CUSTOM_ACTIONS OC
   WHERE OC.action_id=OD.action_id
   AND Folder_Id=l_folder_id);


   l_count Number:=1;
BEGIN


     FOR BUTTONS IN C1(p_folder_id)
     LOOP
       x_buttons_tbl(l_count).Action_Id:=BUTTONS.Action_id;
       x_buttons_tbl(l_count).Action_Name:=BUTTONS.Action_Name;
       x_buttons_tbl(l_count).User_Entered_Prompt:=BUTTONS.User_Entered_Prompt;
       x_buttons_tbl(l_count).access_key:=BUTTONS.access_key;
       x_buttons_tbl(l_count).default_prompt:=BUTTONS.default_prompt;
       x_buttons_tbl(l_count).display_as_button:=BUTTONS.display_as_button_flag;
       x_buttons_tbl(l_count).Folder_Id:=BUTTONS.Folder_Id;
       x_buttons_tbl(l_count).Width:=BUTTONS.Width;
            BEGIN
             SELECT default_prompt into
                    x_buttons_tbl(l_count).default_prompt
             FROM  oe_custom_actions
             WHERE action_name=BUTTONS.Action_Name
             AND default_prompt IS NOT NULL
             AND ROWNUM=1;
             EXCEPTION
             WHEN NO_DATA_FOUND THEN
              Null;
             WHEN TOO_MANY_ROWS THEN
              Null;
             WHEN OTHERS THEN
              Null;
            END;
       l_count:=l_count+1;
     END LOOP;

     FOR BUTTONS IN C2(p_folder_id)
     LOOP
       x_buttons_tbl(l_count).Action_Id:=BUTTONS.Action_id;
       x_buttons_tbl(l_count).Action_Name:=BUTTONS.Action_Name;
       x_buttons_tbl(l_count).Width:=BUTTONS.Width;
       x_buttons_tbl(l_count).display_as_button:=BUTTONS.display_as_button_flag;
            BEGIN
             SELECT default_prompt into
                    x_buttons_tbl(l_count).default_prompt
             FROM  oe_custom_actions
             WHERE action_name=BUTTONS.Action_Name
             AND default_prompt IS NOT NULL
             AND ROWNUM=1;
             EXCEPTION
             WHEN NO_DATA_FOUND THEN
              Null;
             WHEN TOO_MANY_ROWS THEN
              Null;
             WHEN OTHERS THEN
              Null;
            END;
       l_count:=l_count+1;
     END LOOP;

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
    Null;
   WHEN TOO_MANY_ROWS THEN
    Null;
   WHEN OTHERS THEN
    Null;
END Get_Buttons_List;

PROCEDURE Store_Custom_Buttons
            (
             p_folder_id        IN  Number
           , p_config_buttons_tbl IN Oe_Oe_Folder_Ext.Config_Buttons_Tbl
           , l_return_status     OUT NOCOPY /* file.sql.39 change */ Varchar2
           , x_custom_buttons_tbl OUT NOCOPY /* file.sql.39 change */ Oe_Oe_Folder_Ext.Config_Buttons_Tbl
           , x_default_buttons_tbl OUT NOCOPY /* file.sql.39 change */ Oe_Oe_Folder_Ext.Config_Buttons_Tbl
            )
 IS PRAGMA AUTONOMOUS_TRANSACTION;
 l_action_id Number;
BEGIN

  IF p_config_buttons_tbl.count>0 THEN
    FOR i in p_config_buttons_tbl.first ..p_config_buttons_tbl.last LOOP
     BEGIN
      SELECT ACTION_ID
      INTO l_action_id
      FROM OE_Custom_Actions
      WHERE action_id=p_config_buttons_tbl(i).action_id
      AND folder_id=p_folder_id;

      UPDATE OE_Custom_Actions
      SET action_name=p_config_buttons_tbl(i).action_name,
          width=p_config_buttons_tbl(i).width,
          user_entered_prompt=p_config_buttons_tbl(i).user_entered_prompt,
          access_key=p_config_buttons_tbl(i).access_key,
          display_as_button_flag=p_config_buttons_tbl(i).display_as_button
      WHERE action_id=p_config_buttons_tbl(i).action_id
      AND folder_id=p_folder_id;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN

      INSERT INTO OE_Custom_Actions
      (
      action_name,
      width,
      folder_id,
      user_entered_prompt,
      access_key,
      display_as_button_flag,
      default_prompt,
      action_id,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN

       )
       Values(
         p_config_buttons_tbl(i).action_name ,
         p_config_buttons_tbl(i).width,
         p_folder_id,
         p_config_buttons_tbl(i).user_entered_prompt,
         p_config_buttons_tbl(i).access_key,
         p_config_buttons_tbl(i).display_as_button,
         p_config_buttons_tbl(i).default_prompt,
         p_config_buttons_tbl(i).action_id,
         fnd_profile.value('USER_ID'),
         sysdate,
         sysdate,
         fnd_profile.value('USER_ID'),
         fnd_profile.value('USER_ID')
        );
    END;

    END LOOP;
  END IF;
  COMMIT;
    Get_Customized_Buttons
               (
               p_folder_id=>p_folder_id
             , x_custom_buttons_tbl=>x_custom_buttons_tbl
             , x_default_buttons_tbl=>x_default_buttons_tbl
                );
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
    Null;
   WHEN TOO_MANY_ROWS THEN
    Null;
   WHEN OTHERS THEN
    Null;
END Store_Custom_Buttons;


PROCEDURE INSERT_FOLDER(p_folder_extension_id IN Number,
                       p_object IN Varchar2,
                       p_user_id IN Number,
                       p_folder_id IN Number,
                       p_pricing_tab IN Varchar2 Default Null,
                       p_service_tab IN Varchar2 Default Null,
                       p_others_tab IN Varchar2 Default Null,
                       p_addresses_tab IN varchar2 Default Null,
                       p_returns_tab  IN Varchar2 Default Null,
                       p_shipping_tab IN Varchar2 Default Null,
                       p_headers_others_tab IN Varchar2 Default Null,
                       p_options_details IN Varchar2 Default Null,
                       p_services_details IN Varchar2 Default Null,
                       p_adjustment_details IN Varchar2 Default Null,
                       p_related_item_details IN Varchar2 Default Null,
                       p_pricing_ava_details IN Varchar2 Default Null,
                       p_default_line_region IN Varchar2 Default Null
                     )
IS PRAGMA AUTONOMOUS_TRANSACTION;
 l_folder_extension_id Number;
BEGIN
  SELECT FOLDER_EXTENSION_ID
  INTO l_folder_extension_id
  FROM oe_folder_extensions
  WHERE  folder_id=p_folder_id;

  UPDATE oe_folder_extensions
  SET DISPLAY_LINE_OTHERS=p_others_tab,
     DISPLAY_LINE_PRICING=p_pricing_tab,
     DISPLAY_LINE_SERVICES=p_service_tab,
     DISPLAY_LINE_ADDRESSES=p_addresses_tab,
     DISPLAY_LINE_RETURNS=p_returns_tab,
     DISPLAY_LINE_SHIPPING=p_shipping_tab,
     DEFAULT_LINE_REGION=p_default_line_region,
     DISPLAY_ORDER_OTHERS=p_headers_others_tab,
     DISPLAY_OPTIONS_DETAILS=p_options_details,
     DISPLAY_SERVICES_DETAILS=p_services_details,
     DISPLAY_ADJUSTMENT_DETAILS=p_adjustment_details,
     DISPLAY_RELATED_ITEMS_DETAILS=p_related_item_details,
     DISPLAY_PRICING_AVA_DETAILS= p_pricing_ava_details
  WHERE FOLDER_ID=p_folder_id;
   Commit;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
  INSERT INTO oe_folder_extensions
   (FOLDER_EXTENSION_ID,
    OBJECT,
    USER_ID,
    FOLDER_ID,
    APPLICATION_ID,
    DISPLAY_LINE_OTHERS ,
    DISPLAY_LINE_PRICING,
    DISPLAY_LINE_SERVICES,
    DISPLAY_LINE_ADDRESSES,
    DISPLAY_LINE_RETURNS,
    DISPLAY_LINE_SHIPPING,
    DISPLAY_ORDER_OTHERS,
    DISPLAY_OPTIONS_DETAILS,
    DISPLAY_SERVICES_DETAILS,
    DISPLAY_ADJUSTMENT_DETAILS,
    DISPLAY_RELATED_ITEMS_DETAILS,
    DISPLAY_PRICING_AVA_DETAILS,
    DEFAULT_LINE_REGION,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN
   ) VALUES
  (
   oe_folder_extensions_s.nextval,
   p_object,
   p_user_id,
   p_folder_id,
   fnd_profile.value('RESP_APPL_ID'),
   p_others_tab,
   p_pricing_tab,
   p_service_tab,
   p_addresses_tab,
   p_returns_tab,
   p_shipping_tab,
   p_headers_others_tab,
   p_options_details,
   p_services_details,
   p_adjustment_details,
   p_related_item_details,
   p_pricing_ava_details ,
   p_default_line_region,
   1,
   sysdate,
   sysdate,
   1,
   1
   );
   Commit;


   WHEN TOO_MANY_ROWS THEN
    Null;
   WHEN OTHERS THEN
    Null;

END INSERT_FOLDER;

PROCEDURE FOLDER_ACTIONS_INIT( x_others_flag OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                               x_pricing_flag OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                               x_addresses_flag OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                               x_services_flag  OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                               x_shipping_flag  OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                               x_returns_flag  OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                               x_header_others_flag OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                               x_options_details    OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                               x_services_details   OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                               x_adjustment_details OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                               x_related_item_details OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                               x_pricing_ava_details  OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                               x_default_line_region  OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                               x_custom_buttons_tbl OUT NOCOPY /* file.sql.39 change */
                               Oe_Oe_Folder_Ext.Config_Buttons_Tbl,
                               x_default_buttons_tbl OUT NOCOPY /* file.sql.39 change */
                               Oe_Oe_Folder_Ext.Config_Buttons_Tbl,
                               p_order_folder_object IN Varchar DEFAULT 'OE_ORDERS_TELESALES',
			       p_line_folder_object IN Varchar DEFAULT 'OE_LINE_TELESALES'

                                ) IS
   l_folder_header_id Number;
   l_folder_line_id Number;
   l_folder_extension_id Number;
   l_user_id  Number;
   l_responsibility_id  Number;
   l_folder_app_id  Number;
   l_lang VARCHAR2(50);

    CURSOR C1 IS
    SELECT FDF.Folder_Id
    FROM FND_DEFAULT_FOLDERS FDF, FND_FOLDERS FF
    WHERE
    FDF.OBJECT=p_order_folder_object
    AND (FDF.USER_ID=l_user_id OR (FDF.APPLICATION_ID=l_folder_app_id
    AND FDF.USER_ID=l_responsibility_id))
    AND FDF.FOLDER_ID=FF.FOLDER_ID
    AND FF.LANGUAGE=l_lang
    ORDER BY FDF.USER_ID DESC;

    CURSOR C2 IS
    SELECT FDF.Folder_Id
    FROM FND_DEFAULT_FOLDERS FDF, FND_FOLDERS FF
    WHERE
    FDF.OBJECT=p_line_folder_object
    AND (FDF.USER_ID=l_user_id OR (FDF.APPLICATION_ID=l_folder_app_id
    AND FDF.USER_ID=l_responsibility_id))
    AND FDF.FOLDER_ID=FF.FOLDER_ID
    AND FF.LANGUAGE=l_lang
    ORDER BY FDF.USER_ID DESC;
  BEGIN
   l_user_id:=fnd_profile.value('USER_ID');
   l_responsibility_id := -1 * to_number(fnd_profile.value('RESP_ID'));
   l_folder_app_id:=fnd_profile.value('RESP_APPL_ID');
   l_lang:=userenv('LANG');
   BEGIN
    OPEN C1;
    FETCH C1 INTO l_folder_header_id;
    CLOSE C1;

    SELECT FOLDER_EXTENSION_ID,
          DISPLAY_ORDER_OTHERS
    INTO   l_folder_extension_id,
          x_header_others_flag
    FROM  OE_FOLDER_EXTENSIONS
    WHERE folder_id=l_folder_header_id ;

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
    Null;
   WHEN TOO_MANY_ROWS THEN
    Null;
   WHEN OTHERS THEN
    Null;
   END ;

   BEGIN
    OPEN C2;
    FETCH C2 INTO l_folder_line_id;
    CLOSE C2;

    SELECT FOLDER_EXTENSION_ID,
          DISPLAY_LINE_OTHERS,
          DISPLAY_LINE_ADDRESSES,
          DISPLAY_LINE_PRICING,
          DISPLAY_LINE_SERVICES,
          DISPLAY_LINE_RETURNS,
          DISPLAY_LINE_SHIPPING,
          DISPLAY_OPTIONS_DETAILS,
          DISPLAY_SERVICES_DETAILS,
          DISPLAY_ADJUSTMENT_DETAILS,
          DISPLAY_RELATED_ITEMS_DETAILS,
          DISPLAY_PRICING_AVA_DETAILS,
          DEFAULT_LINE_REGION
    INTO   l_folder_extension_id,
          x_others_flag,
          x_addresses_flag,
          x_pricing_flag,
          x_services_flag,
          x_returns_flag,
          x_shipping_flag,
          x_options_details ,
          x_services_details,
          x_adjustment_details,
          x_related_item_details,
          x_pricing_ava_details ,
          x_default_line_region
    FROM  OE_FOLDER_EXTENSIONS
    WHERE folder_id=l_folder_line_id ;


   EXCEPTION
   WHEN NO_DATA_FOUND THEN
    Null;
   WHEN TOO_MANY_ROWS THEN
    Null;
   WHEN OTHERS THEN
    Null;
   END ;

    Get_Customized_Buttons
               (
               p_folder_id=>l_folder_header_id
             , x_custom_buttons_tbl=>x_custom_buttons_tbl
             , x_default_buttons_tbl=>x_default_buttons_tbl
                );

 EXCEPTION
 WHEN NO_DATA_FOUND THEN
   Null;
 WHEN TOO_MANY_ROWS THEN
   Null;
 WHEN OTHERS THEN
   Null;
END FOLDER_Actions_Init;

PROCEDURE DELETE_FOLDER(p_folder_extension_id IN Number Default Null ,
                       p_folder_id IN Number
                     )
IS PRAGMA AUTONOMOUS_TRANSACTION;
 l_folder_extension_id Number;
BEGIN

   DELETE FROM OE_CUSTOM_ACTIONS
   WHERE folder_id=p_folder_id;

   DELETE FROM oe_folder_extensions
   WHERE  folder_id=p_folder_id;

   Commit;

 EXCEPTION
 WHEN NO_DATA_FOUND THEN
    Null;
 WHEN TOO_MANY_ROWS THEN
    Null;
 WHEN OTHERS THEN
    Null;
END DELETE_FOLDER;

PROCEDURE Defer_Pricing(p_mode In Varchar2)
IS

BEGIN

 IF p_mode='Y' THEN
  OE_GLOBALS.G_DEFER_PRICING:='Y';
 ELSIF p_mode='N' THEN
  OE_GLOBALS.G_DEFER_PRICING:='N';
 END IF;

END Defer_Pricing;

END Oe_Oe_Folder_Ext;

/
