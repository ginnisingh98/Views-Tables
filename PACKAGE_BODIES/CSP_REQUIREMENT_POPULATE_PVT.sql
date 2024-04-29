--------------------------------------------------------
--  DDL for Package Body CSP_REQUIREMENT_POPULATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_REQUIREMENT_POPULATE_PVT" AS
/* $Header: cspgrqpb.pls 120.3.12010000.3 2012/04/13 09:43:32 htank ship $ */
-- Start of Comments
-- Package name     : CSP_SCH_INT_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


    G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspgrqpb.pls';

    PROCEDURE POPULATE_REQUIREMENTS(p_task_id    IN NUMBER
                                ,p_api_version   IN NUMBER
                                ,p_Init_Msg_List IN VARCHAR2     := FND_API.G_FALSE
                                ,p_commit        IN VARCHAR2     := FND_API.G_FALSE
                                ,x_return_status OUT NOCOPY VARCHAR2
                                ,x_msg_data      OUT NOCOPY NUMBER
                                ,x_msg_count     OUT NOCOPY NUMBER
                                ,px_header_id   IN OUT NOCOPY NUMBER
                                ,p_called_by     IN   NUMBER) IS


        CURSOR product_task_id(l_task_id NUMBER) IS
		SELECT p.product_task_id,
		  p.ACTUAL_TIMES_USED
		FROM jtf_tasks_b j,
		  CS_INCIDENTS_ALL_B i,
		  csp_product_tasks p,
		  JTF_TASK_TEMPLATES_B jtt,
		  jtf_task_types_b ttype
		WHERE j.task_id                         = l_task_id
		AND j.SOURCE_OBJECT_TYPE_CODE           = 'SR'
		AND i.incident_id                       = j.SOURCE_OBJECT_ID
		AND p.product_id                        = i.inventory_item_id
		AND p.task_template_id                  = j.template_id
		AND j.template_id                       = jtt.task_template_id
		AND jtt.task_type_id                    = ttype.task_type_id
		AND NVL(ttype.spares_allowed_flag, 'N') = 'Y'
		UNION ALL
		SELECT cpp.product_task_id,
		  cpp.ACTUAL_TIMES_USED
		FROM jtf_tasks_b jtb,
		  csd_repairs cr,
		  csp_product_tasks cpp,
		  JTF_TASK_TEMPLATES_B jtt,
		  jtf_task_types_b ttype
		WHERE jtb.task_id                       = l_task_id
		AND jtb.SOURCE_OBJECT_TYPE_CODE         = 'DR'
		AND cr.repair_line_id                   = jtb.SOURCE_OBJECT_ID
		AND cpp.product_id                      = cr.inventory_item_id
		AND cpp.task_template_id                = jtb.template_id
		AND jtb.template_id                     = jtt.task_template_id
		AND jtt.task_type_id                    = ttype.task_type_id
		AND NVL(ttype.spares_allowed_flag, 'N') = 'Y';


       /* Commented to solve bug..


        CURSOR get_parts(temp_product_task_id NUMBER) IS
        SELECT INVENTORY_ITEM_ID,PRIMARY_UOM_CODE,QUANTITY,PERCENTAGE
        FROM   CSP_TASK_PARTS_V
        WHERE  PRODUCT_TASK_ID = temp_product_task_id;*/

        CURSOR get_parts(temp_product_task_id NUMBER) IS
        SELECT INVENTORY_ITEM_ID,PRIMARY_UOM_CODE,QUANTITY,PERCENTAGE,MANUAL_QUANTITY,ROLLUP_QUANTITY,REVISION
        FROM   CSP_TASK_PARTS_V
        WHERE  PRODUCT_TASK_ID = temp_product_task_id
        AND   INVENTORY_ITEM_FLAG = 'Y'
        AND   NVL( trunc(START_DATE),trunc(sysdate)) <= trunc(sysdate)
        AND   NVL( trunc(END_DATE),trunc(sysdate+1)) >= trunc(sysdate);

       l_user_id NUMBER;
       l_login_id NUMBER;
       l_product_task_id NUMBER;
       l_quantity NUMBER;
       l_item_id  NUMBER;
       l_uom_code VARCHAR2(3);
       l_ship_set VARCHAR2(10);
       l_ship_complete VARCHAR2(1);
       l_likelihood    NUMBER;
       l_requirement_header_rec CSP_Requirement_headers_PVT.REQUIREMENT_HEADER_Rec_Type;
       l_requirement_line_tbl   CSP_Requirement_Lines_PVT.Requirement_Line_Tbl_Type ;
       l_requirement_header_id  NUMBER;
       l_header_return_status VARCHAR2(128);
       l_line_return_status VARCHAR2(128);
       l_api_version_number NUMBER := 1.0;
       x_requirement_header_id NUMBER;
       x_requirement_line_tbl CSP_Requirement_Lines_PVT.Requirement_Line_Tbl_Type ;
       l_msg varchar2(2000);
       count1 NUMBER := 0;
       L_API_NAME                CONSTANT VARCHAR2(30) := 'POPULATE_REQUIREMENTS';
       l_manual_quantity NUMBER;
       l_times_used    NUMBER;
       l_rollup_quantity NUMBER;
       l_revision        VARCHAR2(30);
    BEGIN
         SAVEPOINT CSP_REQUIREMENT_POPULATE_PVT;
         x_msg_count := 0;
         x_return_status := FND_API.G_RET_STS_SUCCESS;

         IF NOT FND_API.Compatible_API_Call
            ( l_api_version_number
            , p_api_version
            , L_API_NAME
            , G_PKG_NAME
            )
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        --  Initialize message stack if required
        IF FND_API.to_Boolean(p_init_msg_list)
        THEN
            FND_MSG_PUB.initialize;
        END IF;

         l_user_id := fnd_global.user_id;
         l_login_id := fnd_global.login_id;
         IF l_login_id = -1 THEN
            l_login_id := fnd_global.conc_login_id;
         END IF;
         l_ship_complete := fnd_profile.value(name => 'CSP_SHIP_COMPLETE');
         IF l_ship_complete ='Y' THEN
            l_ship_set := TO_CHAR(1);
         END IF;
         OPEN product_task_id(p_task_id);
         LOOP
            FETCH product_task_id INTO l_product_task_id ,l_times_used ;
            EXIT WHEN product_task_id%NOTFOUND;
         END LOOP;
         IF l_product_task_id IS NOT NULL THEN
            OPEN get_parts(l_product_task_id);
            LOOP
                FETCH get_parts INTO l_item_id,l_uom_code,l_quantity,l_likelihood,l_manual_quantity,l_rollup_quantity,l_revision;
                EXIT WHEN get_parts%NOTFOUND;
                l_header_return_status := FND_API.G_RET_STS_SUCCESS;
                IF get_parts % ROWCOUNT = 1 AND  p_called_by = 1  THEN
                        l_requirement_header_rec.CREATED_BY       := l_user_id ;
                        l_requirement_header_rec.CREATION_DATE    := SYSDATE ;
                        l_requirement_header_rec.LAST_UPDATED_BY  := l_user_id ;
                        l_requirement_header_rec.LAST_UPDATE_DATE := SYSDATE;
                        l_requirement_header_rec.LAST_UPDATE_LOGIN:= l_login_id;
                        l_requirement_header_rec.OPEN_REQUIREMENT := 'Yes';
                        l_requirement_header_rec.TASK_ID          := p_task_id;
                        l_requirement_header_rec.order_type_id    :=  fnd_profile.value(name => 'CSP_ORDER_TYPE');
                       l_requirement_header_rec.address_type := 'R';
                        CSP_Requirement_headers_PVT.Create_requirement_headers(
                                                 P_Api_Version_Number      => l_api_version_number
                                                ,P_Init_Msg_List          => FND_API.G_FALSE
                                                ,P_Commit                 => FND_API.G_TRUE
                                                ,p_validation_level       => FND_API.G_VALID_LEVEL_FULL
                                                ,P_REQUIREMENT_HEADER_Rec => l_requirement_header_rec
                                                ,X_REQUIREMENT_HEADER_ID  => px_header_id
                                                ,X_Return_Status          => l_header_return_status
                                                ,X_Msg_Count              => x_msg_count
                                                ,X_Msg_Data               => x_msg_data
                                                );

                END IF;
                    IF px_header_id is null and p_called_by = 2 THEN
                        select CSP_Requirement_headers_s1.nextval
                        INTO px_header_id
                        FROM DUAL;
                    END IF;
                    IF l_header_return_status = FND_API.G_RET_STS_SUCCESS THEN
                        If l_manual_quantity is null  then
                            IF  l_rollup_quantity is not null THEN
                                IF l_times_used >= FND_PROFILE.value(name => 'CSP_PROD_TASK_HIST_RULE') Then
                                    count1 := count1 + 1;
                                    l_requirement_line_tbl(count1).CREATED_BY              := l_user_id;
                                    l_requirement_line_tbl(count1).CREATION_DATE           := SYSDATE;
                                    l_requirement_line_tbl(count1).LAST_UPDATED_BY         := l_user_id;
                                    l_requirement_line_tbl(count1).LAST_UPDATE_DATE        := SYSDATE ;
                                    l_requirement_line_tbl(count1).LAST_UPDATE_LOGIN       := l_login_id ;
                                    l_requirement_line_tbl(count1).REQUIREMENT_HEADER_ID   := px_header_id;
                                    l_requirement_line_tbl(count1).INVENTORY_ITEM_ID       := l_item_id;
                                    l_requirement_line_tbl(count1).UOM_CODE                := l_uom_code;
                                    l_requirement_line_tbl(count1).REQUIRED_QUANTITY       := l_quantity;
                                    l_requirement_line_tbl(count1).SHIP_COMPLETE_FLAG      := l_ship_set;
                                    l_requirement_line_tbl(count1).LIKELIHOOD              := l_likelihood;
                                    l_requirement_line_tbl(count1).REVISION                := l_revision;
                                END IF;
                            END IF;
                        else
                            count1 := count1 + 1;
                            l_requirement_line_tbl(count1).CREATED_BY              := l_user_id;
                            l_requirement_line_tbl(count1).CREATION_DATE           := SYSDATE;
                            l_requirement_line_tbl(count1).LAST_UPDATED_BY         := l_user_id;
                            l_requirement_line_tbl(count1).LAST_UPDATE_DATE        := SYSDATE ;
                            l_requirement_line_tbl(count1).LAST_UPDATE_LOGIN       := l_login_id ;
                            l_requirement_line_tbl(count1).REQUIREMENT_HEADER_ID   := px_header_id;
                            l_requirement_line_tbl(count1).INVENTORY_ITEM_ID       := l_item_id;
                            l_requirement_line_tbl(count1).UOM_CODE                := l_uom_code;
                            l_requirement_line_tbl(count1).REQUIRED_QUANTITY       := l_quantity;
                            l_requirement_line_tbl(count1).SHIP_COMPLETE_FLAG      := l_ship_set;
                            l_requirement_line_tbl(count1).LIKELIHOOD              := l_likelihood;
                            l_requirement_line_tbl(count1).REVISION                := l_revision;
                      end if;
                    ELSE
                        x_return_status := l_header_return_status;
                        RETURN;
                    END IF;
             END LOOP;
             IF l_header_return_status = FND_API.G_RET_STS_SUCCESS THEN
                CSP_Requirement_Lines_PVT.Create_requirement_lines(
                                                 P_Api_Version_Number      => l_api_version_number
                                                ,P_Init_Msg_List          => FND_API.G_FALSE
                                                ,P_Commit                 => FND_API.G_TRUE
                                                ,p_validation_level       => FND_API.G_VALID_LEVEL_FULL
                                                ,P_Requirement_Line_TBL   => l_Requirement_Line_tbl
                                                ,X_Requirement_Line_TBL   => x_requirement_line_tbl
                                                ,X_Return_Status          => l_line_return_status
                                                ,X_Msg_Count              => x_msg_count
                                                ,X_Msg_Data               => x_msg_data
                                                );
              IF l_line_return_status = FND_API.G_RET_STS_SUCCESS THEN
               				x_return_status := l_line_return_status;
               				IF FND_API.to_Boolean( p_commit ) THEN
                  				COMMIT;
               				END IF;
            		 ELSE
               				x_return_status := l_line_return_status;
              				 RETURN;
            		 END IF;
            	 END IF;
         	  END IF;
         CLOSE product_task_id;
          x_return_status :=FND_API.G_RET_STS_SUCCESS;
        EXCEPTION
           WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           ROLLBACK TO CSP_REQUIREMENT_POPULATE_PVT;
    END POPULATE_REQUIREMENTS;
END CSP_REQUIREMENT_POPULATE_PVT;

/
