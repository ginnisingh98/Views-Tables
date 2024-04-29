--------------------------------------------------------
--  DDL for Package Body OKC_PRICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_PRICE_PVT" AS
/* $Header: OKCRPREB.pls 120.2 2006/02/28 14:52:17 smallya noship $ */


-- package body level variables-----------------

 l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

 l_exception_stop Exception;
 TYPE flag_tab_type is table of varchar2(1);
 TYPE CHAR_TBL_TYPE is TABLE of VARCHAR2(450) INDEX BY BINARY_INTEGER;

 G_HDR_RUL_TBL            GLOBAL_RPRLE_TBL_TYPE;
 G_HDR_PRLE_TBL           GLOBAL_RPRLE_TBL_TYPE;

 g_hdr_pricelist          NUMBER;
 g_authoring_org_id       NUMBER;
 g_hdr_pricing_date       DATE   DEFAULT TRUNC(SYSDATE);

 g_qa_mode                VARCHAR2(1) := 'N';


Procedure my_debug(p_msg varchar2,p_level NUMBER DEFAULT 1, p_module IN Varchar2 Default  'OKC') IS
 BEGIN
   IF (l_debug = 'Y') THEN
      okc_debug.Log(p_msg,p_level,p_module);
   END IF;
    --dbms_output.put_line(substr(p_msg,1,240));
    --dbms_output.put_line(p_msg);
END my_debug;
----------------------------------------------------
------------------------------------------------------------------------------
 -- Set_control_re sets the control rec for price request if not alraedy set
------------------------------------------------------------------------------
Procedure Set_control_rec(px_control_rec IN OUT NOCOPY OKC_CONTROL_REC_TYPE) IS
  BEGIN
     IF (l_debug = 'Y') THEN
        okc_debug.Set_Indentation('Set_control_rec');
     END IF;
     IF (l_debug = 'Y') THEN
        my_debug('100 : Entering Set_control_rec', 2);
     END IF;

    If px_control_rec.p_request_type_code is null then
       px_control_rec.p_request_type_code := 'OKC';
    End If;
    IF (l_debug = 'Y') THEN
       my_debug('110 : request type code'||px_control_rec.p_request_type_code, 1);
    END IF;

    If px_control_rec.qp_control_rec.pricing_event is null then
       px_control_rec.qp_control_rec.pricing_event := 'BATCH';
    End If;
    IF (l_debug = 'Y') THEN
       my_debug('120 :pricing event'||px_control_rec.qp_control_rec.pricing_event, 1);
    END IF;

    If px_control_rec.qp_control_rec.calculate_flag is null then
     If px_control_rec.p_calc_flag = 'B' then
        px_control_rec.qp_control_rec.calculate_flag := 'Y';
     ELsif px_control_rec.p_calc_flag = 'C' then
        px_control_rec.qp_control_rec.calculate_flag := 'C';
     ELsif px_control_rec.p_calc_flag = 'S' then
        px_control_rec.qp_control_rec.calculate_flag := 'Y'; --???this can be later changed to 'S' if pub is tested for this
        px_control_rec.qp_control_rec.SIMULATION_flag := 'Y'; --???? check if we need to set simulation_flag 'Y' here
     End If;
    End If;
    IF (l_debug = 'Y') THEN
       my_debug('130 :okc calc flag'||px_control_rec.p_calc_flag, 1);
       my_debug('140 :qp calculate flag'||px_control_rec.qp_control_rec.calculate_flag, 1);
       my_debug('145 :p level'||px_control_rec.p_level, 1);
    END IF;

    If px_control_rec.qp_control_rec.SIMULATION_flag is null and px_control_rec.p_level <> 'QA' then
       px_control_rec.qp_control_rec.SIMULATION_flag := 'N';
    Elsif px_control_rec.p_level = 'QA' then
           px_control_rec.qp_control_rec.SIMULATION_flag := 'Y';
    End If;
    IF (l_debug = 'Y') THEN
       my_debug('150 :simulation flag'||px_control_rec.qp_control_rec.SIMULATION_flag, 1);
    END IF;

    If px_control_rec.qp_control_rec.TEMP_TABLE_INSERT_FLAG is null then
       px_control_rec.qp_control_rec.TEMP_TABLE_INSERT_FLAG := 'Y';
    End If;
    IF (l_debug = 'Y') THEN
       my_debug('160 :Temp table insert flag'||px_control_rec.qp_control_rec.TEMP_TABLE_INSERT_FLAG, 1);
    END IF;

-- set OE_DEBUG. Along with this flag, set profile option QP:DEBUG(QP_DEBUG)
-- to generate debug file for QP
    If px_control_rec.qp_control_rec.DEBUG_FLAG  is null then
       --px_control_rec.qp_control_rec.DEBUG_FLAG  := 'N';
       px_control_rec.qp_control_rec.DEBUG_FLAG  := 'Y';
    End If;
    IF (l_debug = 'Y') THEN
       my_debug('170 :Pricing Debug ON/OFF flag'||px_control_rec.qp_control_rec.DEBUG_FLAG, 1);
    END IF;

    IF (l_debug = 'Y') THEN
       my_debug('900 : Exiting Set_control_rec', 2);
    END IF;
    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;
END Set_control_rec;

-------------------------Called from form---------------------------------------------------
-- Update_Line_price
-- This procedure will calculate the price for all the Priced lines below sent in line
-- Called when a line is updated in the form
-- p_lowest_level- Level number of the lowest subline being displayed
-- p_cle_id - id of the line updated
-- p_chr_id - id of the header
-- p_lowest_level Possible values 0(p_cle_id not null and this line is subline),
--                                 1(p_cle_id not null and this line is upper line),
--                                 -1(update all lines)
--                                 -2(update all lines and header)
--                                 DEFAULT -2
--px_chr_list_price  IN OUT -holds the total line list price, for right value pass in the existing value,
--px_chr_net_price   IN OUT -holds the total line net price, for right value pass in the existing value
-- px_cle_amt gets back the net price for the line that was updated. In case of
-- p_negotiated_changed, it brings in the old net price of the line updated
----------------------------------------------------------------------------
PROCEDURE Update_LINE_price(
          p_api_version                 IN          NUMBER,
          p_init_msg_list               IN          VARCHAR2 ,
          p_commit                      IN          VARCHAR2 ,
          p_CHR_ID                      IN          NUMBER,
          p_cle_id			            IN	        NUMBER ,
          p_lowest_level                IN          NUMBER ,
          px_Control_Rec			    IN  OUT NOCOPY     OKC_CONTROL_REC_TYPE,
          px_chr_list_price             IN  OUT NOCOPY     NUMBER,
          px_chr_net_price              IN  OUT NOCOPY     NUMBER,
          px_cle_amt    		        IN  OUT NOCOPY     NUMBER,
          x_CLE_PRICE_TBL		        OUT  NOCOPY CLE_PRICE_TBL_TYPE,
          --???? x_cle_list_price           OUT  NOCOPY NUMBER,
          x_return_status               OUT  NOCOPY VARCHAR2,
          x_msg_count                   OUT  NOCOPY NUMBER,
          x_msg_data                    OUT  NOCOPY VARCHAR2) IS
    l_return_status varchar2(1) :=OKC_API.G_RET_STS_SUCCESS;

    l_api_name constant VARCHAR2(30) := 'Update_line_PRICE';
    l_cle_id_tbl num_tbl_type;
    i pls_integer :=0;
    j pls_integer :=0;
    l_ind pls_integer :=0;

    l_lvl_tbl num_tbl_type;
    l_id_tbl num_tbl_type;
    l_obj_tbl num_tbl_type;
    l_p_tbl   flag_tab_type ;
    l_bpi_tbl flag_tab_type ;
    l_amt_tbl num_tbl_type;
    l_list_tbl num_tbl_type;
    --???? take this out when uncommented above
     x_cle_list_price       NUMBER;
     x_cle_amt              NUMBER;
    l_new_amt number :=0;
    l_new_list_price number :=0;
    l_obj number :=1;
    l_amt number :=0;
    l_list_price number :=0;

    l_cle_id number;

    l_chr_rec  okc_contract_pub.chrv_rec_type;
    x_chr_rec  okc_contract_pub.chrv_rec_type;
    l_cle_tbl  okc_contract_pub.clev_tbl_type;
    x_cle_tbl  okc_contract_pub.clev_tbl_type;

    l_req_line_tbl              QP_PREQ_GRP.LINE_TBL_TYPE;
    l_req_line_qual_tbl         QP_PREQ_GRP.QUAL_TBL_TYPE;
    l_req_line_attr_tbl         QP_PREQ_GRP.LINE_ATTR_TBL_TYPE;
    l_req_line_detail_tbl       QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
    l_req_line_detail_qual_tbl  QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE;
    l_req_line_detail_attr_tbl  QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE;
    l_req_related_line_tbl      QP_PREQ_GRP.RELATED_LINES_TBL_TYPE;

    TYPE char_TBL_TYPE is TABLE of varchar2(3) INDEX BY BINARY_INTEGER;

    l_pat_id_tbl  num_tbl_type;
    l_operand_tbl  num_tbl_type;
    l_value_tbl  num_tbl_type;

    l_operator_tbl char_tbl_type;

    l_rowlevel number :=0;
    l_p_found boolean :=false;

    l_patv_tbl   OKC_PRICE_ADJUSTMENT_PUB.patv_tbl_type;
    lx_patv_tbl  OKC_PRICE_ADJUSTMENT_PUB.patv_tbl_type;
BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('Update_line_PRICE');
    END IF;
    IF (l_debug = 'Y') THEN
       my_debug('1000 : Entering Update_line_PRICE', 2);
    END IF;

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PROCESS',
                                               x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                    raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    Set_control_rec(px_control_rec);
    if px_control_rec.p_calc_flag = 'S' then
       OKC_API.set_message(p_app_name      => g_app_name,
                                 p_msg_name      => 'OKC_INVALID_CALC_FLAG',
                                 p_token1        => 'calc_flag',
                                 p_token1_value  => 'S');

        RAISE OKC_API.G_EXCEPTION_ERROR;
    End if;
    px_control_rec.p_level:= 'L';
    --get all the  lines below the sent in p_cle_id
      select level,cle_id,id,object_version_number,price_level_ind,price_basis_yn
      bulk collect into l_lvl_tbl,l_cle_id_tbl,l_id_tbl,l_obj_tbl,l_p_tbl,l_bpi_tbl
      from OKC_K_LINES_B
      --where config_item_type is null
      connect by (prior id = cle_id  and config_item_type is null)
      start with id=p_cle_id;
      IF (l_debug = 'Y') THEN
         my_debug('1050 : select rowcount:'||SQL%ROWCOUNT, 1);
      END IF;


    i:= l_id_tbl.first;
    l_p_found := false;
    l_rowlevel :=0;
    -- This loop will take out all the first occurrences of priced lines(there can be more
    -- if recursive)
    IF (l_debug = 'Y') THEN
       my_debug('1055 :starting out nocopy loop to filter priced lines', 1);
    END IF;
    while i is not null loop
        If l_lvl_tbl(i) = 1 or l_lvl_tbl(i)<= l_rowlevel then
            l_p_found :=false;
            l_rowlevel:=l_lvl_tbl(i);
        End if;
        If l_p_tbl(i)='Y'  and l_p_found=false then
           IF (l_debug = 'Y') THEN
              my_debug('1060 : Priced Lines returned'||l_id_tbl(i), 1);
           END IF;
           x_cle_price_tbl(i).id:=l_id_tbl(i);
           l_p_found := true;
           l_rowlevel := l_lvl_tbl(i);
        ELSE
           l_p_tbl(i):='N';
        End If;
        IF (l_debug = 'Y') THEN
           my_debug('1061 : line id'||l_id_tbl(i), 1);
           my_debug('1062 : priced flag'||l_p_tbl(i), 1);
           my_debug('1064 : row level'||l_lvl_tbl(i), 1);
        END IF;
        If l_p_found then
          IF (l_debug = 'Y') THEN
             my_debug('1065 : priced already found', 1);
          END IF;
        Else
          IF (l_debug = 'Y') THEN
             my_debug('1066 : priced not found', 1);
          END IF;
        End if;
        IF (l_debug = 'Y') THEN
           my_debug('1067 : saved rowlevel'||l_rowlevel, 1);
        END IF;

        i:=l_id_tbl.next(i);
   END loop;


   IF (l_debug = 'Y') THEN
      my_debug('1070 : Before call to Calculate price priced count'||x_cle_price_tbl.count, 1);
   END IF;
   --call calculate price and pass in the array of priced lines
    CALCULATE_price(p_api_version                => p_api_version,
                    p_CHR_ID                     => p_chr_id,
                    p_Control_Rec			     => px_control_rec,
                    px_req_line_tbl              => l_req_line_tbl,
                    px_Req_qual_tbl              => l_req_line_qual_tbl,
                    px_Req_line_attr_tbl         => l_req_line_attr_tbl,
                    px_Req_LINE_DETAIL_tbl       => l_req_line_detail_tbl,
                    px_Req_LINE_DETAIL_qual_tbl  => l_req_line_detail_qual_tbl,
                    px_Req_LINE_DETAIL_attr_tbl  => l_req_line_detail_attr_tbl,
                    px_Req_RELATED_LINE_TBL      => l_req_related_line_tbl,
                    px_CLE_PRICE_TBL		     => x_CLE_PRICE_TBL,
                    x_return_status              => x_return_status,
                    x_msg_count                  => x_msg_count,
                    x_msg_data                   => x_msg_data);
   IF (l_debug = 'Y') THEN
      my_debug('1080 : After call to Calculate price return status'||x_return_status, 1);
   END IF;

     IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
                  RAISE OKC_API.G_EXCEPTION_ERROR;
     -- here not raising an exception but just returning error status as
     -- we donot want to rollback If one line failed to price
     ELSIF x_return_status = G_SOME_LINE_ERRORED THEN
           x_return_status := OKC_API.G_RET_STS_ERROR;
     END IF;
     -- go on even if error
  -- do rollups
   IF (l_debug = 'Y') THEN
      my_debug('1090 : After call to Calculate price, Priced_Count'||x_cle_price_tbl.count, 1);
   END IF;

      j:=0;
      --for all the priced lines , do the following
      i:= x_cle_price_tbl.first;
      while i is not null loop
        IF (l_debug = 'Y') THEN
           my_debug('1100 : In while loop I is '||i, 1);
           my_debug('1110 : Return status'||x_cle_price_tbl(i).ret_sts, 1);
           my_debug('1120 : Line Id'||x_cle_price_tbl(i).id, 1);
        END IF;
        --if the priced line is P(and not BPI) and the return status is not unexpected error
        If  x_cle_price_tbl(i).pi_bpi ='P' and x_cle_price_tbl(i).ret_sts <> 'U' then --??????ret_sts='S'
          -- make cle buffer equal to priced id
          l_cle_id := x_cle_price_tbl(i).id;
          -- start from the last in array as the parents of the priced line will be prior to it in array
          l_ind := l_id_tbl.last;
          while l_ind is not null loop
                  IF (l_debug = 'Y') THEN
                     my_debug('1130 : In while l_cle_id'||x_cle_price_tbl(i).id, 1);
                     my_debug('1140 : In while l_id'||l_id_tbl(l_ind), 1);
                     my_debug('1150 : In while bpi'||l_bpi_tbl(l_ind), 1);
                     my_debug('1150 : In while level'||(l_lvl_tbl(l_ind)-p_lowest_level), 1);
                  END IF;
            -- if the cle buffer id found
             If (l_id_tbl(l_ind)=l_cle_id ) Then --#1
                 If  (nvl(l_bpi_tbl(l_ind),'N') <> 'Y' and (l_lvl_tbl(l_ind)-p_lowest_level > 1) )then --#2
                    IF (l_debug = 'Y') THEN
                       my_debug('1160 : In NOT BPI IF:', 1);
                    END IF;
                    -- create a record to update the okc_k_lines

                    l_cle_tbl(l_ind).id :=l_id_tbl(l_ind);
                    IF (l_debug = 'Y') THEN
                       my_debug('1162 : loop for line id:'||l_cle_tbl(l_ind).id, 1);
                    END IF;

                    l_cle_tbl(l_ind).object_version_number :=l_obj_tbl(l_ind);
                    If l_cle_tbl(l_ind).line_list_price = OKC_API.G_MISS_NUM then
                         l_cle_tbl(l_ind).line_list_price := null;
                    End if;
                    If l_cle_tbl(l_ind).price_negotiated = OKC_API.G_MISS_NUM then
                        l_cle_tbl(l_ind).price_negotiated := null;
                    End if;

                    -- If the priced line had some negotiated amount over it
                    IF x_cle_price_tbl(i).negotiated_amt is not null then
                       l_cle_tbl(l_ind).price_negotiated :=
                         nvl(l_cle_tbl(l_ind).price_negotiated,0) + x_cle_price_tbl(i).negotiated_amt;
                    End If;
                    IF (l_debug = 'Y') THEN
                       my_debug('1170 : negotiated amount on line:'||l_cle_tbl(l_ind).price_negotiated, 1);
                    END IF;
                      -- if the priced line had some list price over it
                    IF  x_cle_price_tbl(i).list_price is not null  then
                      l_cle_tbl(l_ind).line_list_price :=
                         nvl(l_cle_tbl(l_ind).line_list_price,0) + x_cle_price_tbl(i).list_price;
                    END IF;
                    IF (l_debug = 'Y') THEN
                       my_debug('1180 : list price  on line:'||l_cle_tbl(l_ind).line_list_price, 1);
                    END IF;

                    If l_id_tbl(l_ind) = x_cle_price_tbl(i).id then -- that means priced line #3
                      If x_cle_price_tbl(i).PRICELIST_ID is not null
                            and x_cle_price_tbl(i).PRICELIST_ID<> OKC_API.G_MISS_NUM then
                         l_cle_tbl(l_ind).price_list_id :=x_cle_price_tbl(i).PRICELIST_ID;
                         l_cle_tbl(l_ind).pricing_date :=x_cle_price_tbl(i).pricing_date;
                         l_cle_tbl(l_ind).price_list_line_id :=x_cle_price_tbl(i).list_line_id;
                         IF (l_debug = 'Y') THEN
                            my_debug('1190 : price list found  price list id:'||l_cle_tbl(l_ind).price_list_id, 1);
                            my_debug('1200 : price list found  price list line id:'||l_cle_tbl(l_ind).price_list_line_id, 1);
                         END IF;

                      End If;
                  ---???? nothing regarding rolling up of updated neg price in contract apis. ask john
                      l_cle_tbl(l_ind).price_unit:= x_cle_price_tbl(i).unit_price;
                      IF (l_debug = 'Y') THEN
                         my_debug('1210 : unit price:'||l_cle_tbl(l_ind).price_unit, 1);
                      END IF;
                   END IF; --#3
               END IF; --#2
               -- if we have reached the topmost line
               If l_lvl_tbl(l_ind)=1  then
                 -- say there is a parent for the topmost line, store its prices to update the parents
                 l_new_amt := l_cle_tbl(l_ind).price_negotiated ;
                 l_new_list_price := l_cle_tbl(l_ind).line_list_price ;

                 IF (l_debug = 'Y') THEN
                    my_debug('1220 : p_cle_ids negotiated amount:'||l_new_amt, 1);
                    my_debug('1225 : p_cle_ids list price:'||l_new_list_price, 1);
                 END IF;

                 x_cle_amt := l_new_amt;
                 x_cle_list_price := l_new_list_price;
                 exit; -- we have reached the top. so no point going any further

               End If;
               --pick up the parent of the processed line
               l_cle_id :=nvl(l_cle_id_tbl(l_ind),0);
              End If;--#1
               l_ind:=l_id_tbl.prior(l_ind);
          end loop;
        End If;
        i:=x_cle_price_tbl.next(i);
     END loop;
     IF (l_debug = 'Y') THEN
        my_debug('1240 : number of lines to be updated:'||l_cle_tbl.count);
     END IF;

     IF p_lowest_level < 0  and p_cle_id is not null and x_cle_price_tbl.count > 0
         and (nvl(l_new_amt,-1) <> 0 OR nvl(l_new_list_price,-1) <> 0) then
              IF (l_debug = 'Y') THEN
                 my_debug('1245 : In the if for processing parents of p_cle_id. p_lowest_level:'||p_lowest_level);
              END IF;
              -- get the parents of passed in p_cle_id
               select cle_id,id,object_version_number,nvl(price_negotiated,0),nvl(line_list_price,0)
               bulk collect into l_cle_id_tbl,l_id_tbl,l_obj_tbl,l_amt_tbl,l_list_tbl
               from OKC_K_LINES_B
                --where dnz_chr_id=p_chr_id
               connect by prior cle_id = id
               start with id=p_cle_id;
               IF (l_debug = 'Y') THEN
                  my_debug('1250 : select rowcount for the parents:'||SQL%ROWCOUNT, 1);
                  my_debug('1251 : p_negotiated_changed:'||px_control_rec.p_negotiated_changed, 1);
                  my_debug('1252 : px_cle_amt:'||px_cle_amt, 1);
               END IF;

               l_ind := l_cle_tbl.count;
               i := l_id_tbl.first;
               While i is not null loop
                 -- if the record for updated p_cle_id then
                 If l_id_tbl(i) = p_cle_id then
                       -- If the line passsed as updated is the priced line and also its
                       -- net price has been overridden then the database is right now showing the
                       -- new price as form has posted the changes to database.
                       -- In that case, take the old price not from database
                       -- but from what is passed in by form in px_cle_amt
                       If x_cle_price_tbl(x_cle_price_tbl.first).id = l_id_tbl(i)
                          and x_cle_price_tbl(i).pi_bpi ='P'
                          and px_control_rec.p_negotiated_changed = 'Y' and px_cle_amt is not null then
                                 l_amt_tbl(i) := px_cle_amt;
                       End If;
                        --calculate the difference in old amount on p_cle_id and the new amount
                        -- the difference will be added to all of its parents
                         l_new_amt := nvl(l_new_amt,0) - nvl(l_amt_tbl(i),0);
                         l_new_list_price := nvl(l_new_list_price,0) - nvl(l_list_tbl(i),0);
                         IF (l_debug = 'Y') THEN
                            my_debug('1260 :In IF old list price:'||l_list_tbl(i), 1);
                            my_debug('1265 :In IF old negotiated amount:'||l_amt_tbl(i), 1);
                         END IF;

                         IF (l_debug = 'Y') THEN
                            my_debug('1268 :In IF new list price:'||l_new_list_price, 1);
                            my_debug('1270 :In IF new negotiated amount:'||l_new_amt, 1);
                         END IF;
                 Else
                    -- if the parent of updated line
                     l_ind:=l_ind+1;
                     l_cle_tbl(l_ind).id :=l_id_tbl(i);
                     l_cle_tbl(l_ind).object_version_number :=l_obj_tbl(i);
                     If l_new_amt <>0 then
                        l_cle_tbl(l_ind).price_negotiated := nvl(l_amt_tbl(i),0)+l_new_amt;
                     End if;
                     If l_new_list_price <> 0 then
                       l_cle_tbl(l_ind).line_list_price := nvl(l_list_tbl(i),0)+l_new_list_price;
                     End if;
                     IF (l_debug = 'Y') THEN
                        my_debug('1280 :id of the parent:'||l_cle_tbl(l_ind).id , 1);
                        my_debug('1290 :price negotiated of parent:'||l_cle_tbl(l_ind).price_negotiated, 1);
                        my_debug('1295 :list price of parent:'||l_cle_tbl(l_ind).line_list_price, 1);
                     END IF;


                 End if;
                 i:= l_id_tbl.next(i);
               End loop;
               If l_new_amt is not null and l_new_amt <>0 then
                  px_chr_net_price := nvl(px_chr_net_price,0)+l_new_amt;
               End If;
               If l_new_list_price is not null and l_new_list_price <>0 then
                  px_chr_list_price := nvl(px_chr_list_price,0)+l_new_list_price;
               End If;
               -- if the header also has to be updated
               If p_lowest_level = -2 then
                 Begin
                   Select object_version_number,estimated_amount,total_line_list_price
                   into l_obj,l_amt,l_list_price
                   From okc_k_headers_b
                   where id=p_chr_id;
                   IF (l_debug = 'Y') THEN
                      my_debug('1300 : select rowcount for header should be 1: '||SQL%ROWCOUNT, 1);
                      my_debug('1310 : old amount on header'||l_amt, 1);
                      my_debug('1320 : old list price on header'||l_list_price, 1);
                   END IF;

                     l_chr_rec.id := p_chr_id;
                     l_chr_rec.object_version_number := l_obj;
                     If l_new_amt <> 0 then
                       l_chr_rec.estimated_amount := nvl(l_amt,0)+l_new_amt;
                     End if;
                     If l_new_list_price <> 0 then
                        l_chr_rec.total_line_list_price := nvl(l_list_price,0)+l_new_list_price;
                     End if;
                   IF (l_debug = 'Y') THEN
                      my_debug('1330 : new amount on header'||l_chr_rec.estimated_amount, 1);
                      my_debug('1340 : new list price on header'||l_chr_rec.total_line_list_price, 1);
                   END IF;

                   IF (l_debug = 'Y') THEN
                      my_debug('1350 : Before calling update contract header', 1);
                   END IF;
                   okc_contract_pub.update_contract_header (
	                    p_api_version => 1,
	                    p_init_msg_list => OKC_API.G_FALSE,
	                    x_return_status => l_return_status,
	                    x_msg_count => x_msg_count,
	                    x_msg_data => x_msg_data,
		              -- p_restricted_update => okc_api.g_true,
	                    p_chrv_rec => l_chr_rec,
	                    x_chrv_rec => x_chr_rec);
                   IF (l_debug = 'Y') THEN
                      my_debug('1355 : after calling update contract header status :'||l_return_status, 1);
                   END IF;

                    IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                     RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
                     RAISE OKC_API.G_EXCEPTION_ERROR;
                    END IF;

                   Exception
                     When no_data_found then
                      IF (l_debug = 'Y') THEN
                         my_debug('1360 : no data found This is not possible. some error', 1);
                      END IF;
                       null;
                 End;
                End if; -- p_lowest_level=-2
     End if;-- px_lowest_level <0
     IF (l_debug = 'Y') THEN
        my_debug('1365 : before calling update contract line, count :'||l_cle_tbl.count, 1);
     END IF;

     okc_contract_pub.update_contract_line (
	      p_api_version => 1,
	      p_init_msg_list => OKC_API.G_FALSE,
	      x_return_status => l_return_status,
	      x_msg_count => x_msg_count,
	      x_msg_data => x_msg_data,
		 -- p_restricted_update => okc_api.g_true,
	      p_clev_tbl => l_cle_tbl,
	      x_clev_tbl => x_cle_tbl);
     IF (l_debug = 'Y') THEN
        my_debug('1366 : after calling update contract line status :'||l_return_status, 1);
     END IF;

     IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
           RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- update header level adjustments with the new adjusted value. Right now we
     -- just have % adjustments on header and that also in bucket 1 only
     -- If this changes, then revisit this code
     select id,operand,arithmetic_operator,object_version_number,adjusted_amount
       bulk collect into l_pat_id_tbl,l_operand_tbl,l_operator_tbl,l_obj_tbl,l_value_tbl
       from OKC_PRICE_ADJUSTMENTS
       where chr_id=p_chr_id and cle_id is null;
       IF (l_debug = 'Y') THEN
          my_debug('1370 : header adjustments select rowcount'||SQL%ROWCOUNT, 1);
       END IF;
       If l_pat_id_tbl.count > 0 then
         i:=l_pat_id_tbl.first;
         while i is not null LOOP
            IF (l_debug = 'Y') THEN
               my_debug('1371 : header adjustment id'||l_pat_id_tbl(i), 1);
               my_debug('1372 : operand'||l_operand_tbl(i), 1);
               my_debug('1373 : operator'||l_operator_tbl(i), 1);
               my_debug('1374 : old adjusted value'||l_value_tbl(i), 1);
            END IF;

            If l_operator_tbl(i)='%' then
                    l_patv_tbl(i).ID                      := l_pat_id_tbl(i);
                    l_patv_tbl(i).object_version_number   := l_obj_tbl(i);
                    --  calculate the new adjusted value for this header adjustment
                    l_patv_tbl(i).ADJUSTED_AMOUNT         := (l_operand_tbl(i)/100)*px_chr_list_price;
                    If l_value_tbl(i) < 0 then
                        l_patv_tbl(i).ADJUSTED_AMOUNT         :=l_patv_tbl(i).ADJUSTED_AMOUNT * (-1);
                    end if;
                IF (l_debug = 'Y') THEN
                   my_debug('1374 : adjusted value'||l_patv_tbl(i).ADJUSTED_AMOUNT, 1);
                END IF;

            End If;
            i:=l_pat_id_tbl.next(i);
         End loop;
          IF (l_debug = 'Y') THEN
             my_debug('1378 : Before calling update price adjustment '||l_return_status, 1);
          END IF;

          OKC_PRICE_ADJUSTMENT_PUB.update_price_adjustment(
                    p_api_version      => p_api_version,
                    x_return_status    => l_return_status ,
                    x_msg_count        => x_msg_count,
                    x_msg_data         => x_msg_data,
                    p_patv_tbl         => l_patv_tbl,
                    x_patv_tbl         => lx_patv_tbl );
          IF (l_debug = 'Y') THEN
             my_debug('1379 : after calling update price adjustment '||l_return_status, 1);
          END IF;
          --since adjsuted value column is just fyi, we would not want to rollback just because it returned some
          --error. only if it is unexpected error we rollback
          IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          END IF;
       End If;-- l_pat_id_tbl.count>0
       px_cle_amt := x_cle_amt;
       IF (l_debug = 'Y') THEN
          my_debug('1379 : cle amount returned:'||px_cle_amt, 1);
       END IF;

       IF (l_debug = 'Y') THEN
          my_debug('1380 : p_commit :'||p_commit, 1);
       END IF;

     If p_commit = OKC_API.G_TRUE then
        Commit work;
     End If;
     IF (l_debug = 'Y') THEN
        my_debug('1390:--------------Priced line tbl returned from update line price---------------');
     END IF;
I := x_cle_price_tbl.FIRST;
IF I IS NOT NULL THEN
 LOOP


                      IF (l_debug = 'Y') THEN
                         my_debug(' 1400: pi_bpi:'||x_cle_price_tbl(i).pi_bpi,1);
                         my_debug(' 1410:ID :'||x_cle_price_tbl(i).ID ,1);
                         my_debug(' 1420:UOM :'||x_cle_price_tbl(i).UOM_CODE,1 );
                         my_debug(' 1430:LINE_NUM:'||x_cle_price_tbl(i).LINE_NUM,1 );
                         my_debug(' 1440:LIST_PRICE :'|| x_cle_price_tbl(i).LIST_PRICE ,1);
                         my_debug(' 1450:UNIT_PRICE:'||x_cle_price_tbl(i).UNIT_PRICE ,1);
                         my_debug(' 1460:NEGOTIATED_AMT :'||x_cle_price_tbl(i).NEGOTIATED_AMT,1 );
                         my_debug(' 1470:PRICELIST_ID :'||x_cle_price_tbl(i).PRICELIST_ID ,1);
                         my_debug(' 1480: RET_CODE :'||x_cle_price_tbl(i).RET_CODE,1);
                         my_debug(' 1490: qty :'||x_cle_price_tbl(i).qty ,1);
                         my_debug(' 1500: RET_STS :'||x_cle_price_tbl(i).RET_STS ,1);
                      END IF;
  EXIT WHEN I =x_cle_price_tbl.LAST;
  I := x_cle_price_tbl.NEXT(I);
   END LOOP;
END IF;
    IF (l_debug = 'Y') THEN
       my_debug(' 1510: Header Net price :'||px_chr_net_price ,1);
       my_debug(' 1515: Header List price :'||px_chr_list_price ,1);
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       my_debug('1600 : Exiting Update_line_PRICE', 2);
    END IF;
    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;
    EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
              x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                       'OKC_API.G_RET_STS_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');
                IF (l_debug = 'Y') THEN
                   my_debug('1700 : Exiting Update_line_PRICE', 4);
                END IF;
                IF (l_debug = 'Y') THEN
                   okc_debug.Reset_Indentation;
                END IF;

         WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
              x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                       'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');
                IF (l_debug = 'Y') THEN
                   my_debug('1800 : Exiting Update_line_PRICE', 4);
                END IF;
                IF (l_debug = 'Y') THEN
                   okc_debug.Reset_Indentation;
                END IF;

         WHEN OTHERS THEN
              OKC_API.set_message(p_app_name      => g_app_name,
                                 p_msg_name      => g_unexpected_error,
                                 p_token1        => g_sqlcode_token,
                                 p_token1_value  => sqlcode,
                                 p_token2        => g_sqlerrm_token,
                                 p_token2_value  => sqlerrm);
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            IF (l_debug = 'Y') THEN
               my_debug('1900 : Exiting Update_line_PRICE', 4);
            END IF;
            IF (l_debug = 'Y') THEN
               okc_debug.Reset_Indentation;
            END IF;

 END Update_line_price;


 /*****************************************************************************/
/*****************************************************************************
  commenting out nocopy as this check has been moved to new procedure
  OKC_QA_PRICE_PVT.check_covered_line_qty  (Bug 2503412)


-------------------------------------------------------------------------------
-- Procedure:       validate_covered_line_qty
-- Version:         1.0
-- Purpose:         check to ensure that the quantity of a (sub) line of linestyle 'covered line' matches
--                  that of the (top) line to which it points.
-- In Parameters:   p_cle_id        the (sub) line of linestyle 'covered line'
--

-- Out Parameters:  x_return_status
--
-- Comments:       This procedure is to be called only by QA

PROCEDURE validate_covered_line_qty ( p_chr_id             IN  okc_k_headers_b.ID%TYPE,
                                      p_cle_id             IN  okc_k_lines_b.ID%TYPE,
                                      p_l_id_tbl           IN  num_tbl_type,
                                      p_l_cle_id_tbl       IN  num_tbl_type,
                                      p_l_line_number_tbl  IN  char_tbl_type,
                                      x_return_status      OUT NOCOPY VARCHAR2
        	                    ) IS


   --gets quantity of (sub) line of linestyle 'covered line'
   --also gets the id (object1_id1) of the parent line which is being pointed to
   --NOTE: validate_covered_line_qty is to be called ONLY for (sub) lines with lse_id = 41 as we support only
   --      this particular linestyle for 'OKX_COVLINE' object code
   CURSOR c_get_quantity1 (b_cle_id NUMBER) is
   SELECT object1_id1, number_of_items qty
   FROM   okc_k_items
   WHERE  cle_id = b_cle_id
   AND    dnz_chr_id = p_chr_id
   AND    jtot_object1_code = 'OKX_COVLINE';



   --gets the quantity of the parent non-service item line being pointed to
   CURSOR c_get_quantity2 (b_cle_id NUMBER) is
   SELECT number_of_items qty
   FROM   okc_k_items
   WHERE  cle_id = b_cle_id
   AND    dnz_chr_id = p_chr_id;


   l_return_status     VARCHAR2(1);

   l_qty1                NUMBER := OKC_API.G_MISS_NUM;
   l_qty2                NUMBER := OKC_API.G_MISS_NUM;
   l_parent_cle_id       OKC_K_LINES_B.ID%TYPE;
   l_line_number         OKC_K_LINES_B.LINE_NUMBER%TYPE := '0';
   l_parent_line_number  OKC_K_LINES_B.LINE_NUMBER%TYPE := '0';
   i                     PLS_INTEGER := 0;
   l_top_line_id         NUMBER := OKC_API.G_MISS_NUM;

BEGIN
   x_return_status := okc_api.g_ret_sts_success;
   IF (l_debug = 'Y') THEN
      my_debug('Start : okc_price_pvt.validate_covered_line_qty ',3);
   END IF;
   /* Note: we already perform validation to ensure that the contract is for intent of sale and for OKC, OKO
      in OKC_QA_PRICE_PVT.Check_Price


   /* Get quantity of (sub) line of linestyle 'covered line'
   IF (l_debug = 'Y') THEN
      my_debug('Get quantity of line with id: ' || p_cle_id, 5);
      my_debug('Get quantity of line p_cle_id = ' || p_cle_id || 'with jtot_object=''OKX_COVLINE'' and lse_id=41',5);
   END IF;
   IF c_get_quantity1%ISOPEN THEN
      CLOSE c_get_quantity1;
   END IF;
   OPEN c_get_quantity1 (b_cle_id => p_cle_id);
   FETCH c_get_quantity1 INTO l_parent_cle_id, l_qty1;
   CLOSE c_get_quantity1;
   IF (l_debug = 'Y') THEN
      my_debug('l_qty1: ' || l_qty1, 5);
   END IF;


   /* Get quantity of parent (top) line being pointed to
   IF (l_debug = 'Y') THEN
      my_debug('Get quantity of parent (top) line being pointed to: '||l_parent_cle_id, 5);
   END IF;
   IF c_get_quantity2%ISOPEN THEN
      CLOSE c_get_quantity2;
   END IF;
   OPEN c_get_quantity2 (b_cle_id => l_parent_cle_id);
   FETCH c_get_quantity2 INTO l_qty2;
   CLOSE c_get_quantity2;
   IF (l_debug = 'Y') THEN
      my_debug('l_qty2: ' || l_qty2, 5);
   END IF;



   IF l_qty1 <> OKC_API.G_MISS_NUM AND l_qty2 <> OKC_API.G_MISS_NUM AND l_qty1 <> l_qty2 THEN
          IF (l_debug = 'Y') THEN
             my_debug('l_qty1 and l_qty2 are not the same so setting error message on stack...',5);
          END IF;

         /* get the line number of the immediate (top) line
          i:= p_l_id_tbl.first;
          WHILE i IS NOT NULL LOOP
              IF p_l_id_tbl(i) = p_cle_id THEN
                 l_top_line_id := p_l_cle_id_tbl(i);
                 EXIT;
              END IF;
              i := p_l_id_tbl.next(i);
          END LOOP;

          i:= p_l_id_tbl.first;
          WHILE i IS NOT NULL LOOP
              IF p_l_id_tbl(i) = l_top_line_id THEN
                 l_line_number := p_l_line_number_tbl(i);
                 EXIT;
              END IF;
              i := p_l_id_tbl.next(i);
          END LOOP;


          --now concatenate it with the line number of the (sub) line of linestyle 'covered line'
          i:= p_l_id_tbl.first;
          WHILE i IS NOT NULL LOOP
              IF p_l_id_tbl(i) = p_cle_id THEN
                 l_line_number := l_line_number || '.' || p_l_line_number_tbl(i);
                 EXIT;
              END IF;
              i := p_l_id_tbl.next(i);
          END LOOP;

         /* finally get the line number of the parent (top) line which is being pointed to
          i:= p_l_id_tbl.first;
          WHILE i IS NOT NULL LOOP
              IF p_l_id_tbl(i) = l_parent_cle_id THEN
                 l_parent_line_number := p_l_line_number_tbl(i);
                 EXIT;
              END IF;
              i := p_l_id_tbl.next(i);
          END LOOP;


          OKC_API.set_message(p_app_name      => G_APP_NAME,
                              p_msg_name      => 'OKC_QA_MISMATCH_QTY',
                              p_token1        => 'LNUMB1',
                              p_token1_value  =>  l_line_number,
                              p_token2        => 'LNUMB2',
                              p_token2_value  =>  l_parent_line_number);
           IF (l_debug = 'Y') THEN
              my_debug('Covered line number ' || l_line_number || 'and id: ' || p_cle_id || 'serviceable product have a quantity mismatch.',5);
              my_debug('l_qty1: ' || l_qty1,5);
              my_debug('l_qty2: ' || l_qty2,5);
           END IF;
           x_return_status := OKC_API.G_RET_STS_ERROR;

   END IF;


   If x_return_status <>  OKC_API.G_RET_STS_ERROR then
      IF (l_debug = 'Y') THEN
         my_debug('passed okc_price_pvt.validate_covered_line_qty');
      END IF;
   End if;

   IF (l_debug = 'Y') THEN
      my_debug('End : okc_price_pvt.validate_covered_line_qty ',3);
   END IF;

EXCEPTION
WHEN OTHERS THEN
   IF (l_debug = 'Y') THEN
      my_debug('Error : unexpected error in okc_price_pvt.validate_covered_line_qty ',3);
      my_debug('Error : '|| sqlerrm, 3);
   END IF;

   IF c_get_quantity1%ISOPEN THEN
      CLOSE c_get_quantity1;
   END IF;
   IF c_get_quantity2%ISOPEN THEN
      CLOSE c_get_quantity2;
   END IF;
   OKC_API.set_message(G_APP_NAME,
                            G_UNEXPECTED_ERROR,
                            G_SQLCODE_TOKEN,
                            SQLCODE,
                            G_SQLERRM_TOKEN,
                            SQLERRM);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END;

 *****************************************************************************
 *****************************************************************************/




 --------------------------------------------------------------------------
-- Update_Contract_price
-- This procedure will calculate the price for all the Priced lines in a contract
-- while calculating whether header level adjustments are to be considrerd
-- or not will be taken care of by px_control_rec.p_level (possible values 'L','H','QA')
-- p_chr_id - id of the header
-- x_chr_net_price - estimated amount on header

----------------------------------------------------------------------------
PROCEDURE Update_CONTRACT_price(
          p_api_version                 IN          NUMBER,
          p_init_msg_list               IN          VARCHAR2 ,
          p_commit                      IN          VARCHAR2 ,
          p_CHR_ID                      IN          NUMBER,
          px_Control_Rec			    IN  OUT NOCOPY     OKC_CONTROL_REC_TYPE,
          x_CLE_PRICE_TBL		        OUT  NOCOPY CLE_PRICE_TBL_TYPE,
          x_chr_net_price               OUT  NOCOPY NUMBER,
          x_return_status               OUT  NOCOPY VARCHAR2,
          x_msg_count                   OUT  NOCOPY NUMBER,
          x_msg_data                    OUT  NOCOPY VARCHAR2) IS
    l_return_status varchar2(1) :=OKC_API.G_RET_STS_SUCCESS;

    l_api_name constant VARCHAR2(30) := 'Update_Contract_PRICE';
    l_cle_id_tbl num_tbl_type;
    i pls_integer :=0;
    j pls_integer :=0;
    l_ind pls_integer :=0;

    l_lvl_tbl num_tbl_type;
    l_id_tbl num_tbl_type;
    l_obj_tbl num_tbl_type;
    l_p_tbl   flag_tab_type ;
    l_bpi_tbl flag_tab_type ;
    l_top_model_tbl num_tbl_type;

    l_line_number_tbl char_tbl_type;
    l_lse_id_tbl num_tbl_type;
    ----l_qa_covered_line_qty_mismatch boolean := FALSE;


    l_obj number :=1;
    l_amt number :=0;
    l_list_price number :=0;

    l_cle_id number;
    l_rowlevel number :=0;
    l_p_found boolean :=false;
    l_chr_rec  okc_contract_pub.chrv_rec_type;
    x_chr_rec  okc_contract_pub.chrv_rec_type;
    l_cle_tbl  okc_contract_pub.clev_tbl_type;
    x_cle_tbl  okc_contract_pub.clev_tbl_type;

    l_req_line_tbl              QP_PREQ_GRP.LINE_TBL_TYPE;
    l_req_line_qual_tbl         QP_PREQ_GRP.QUAL_TBL_TYPE;
    l_req_line_attr_tbl         QP_PREQ_GRP.LINE_ATTR_TBL_TYPE;
    l_req_line_detail_tbl       QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
    l_req_line_detail_qual_tbl  QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE;
    l_req_line_detail_attr_tbl  QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE;
    l_req_related_line_tbl      QP_PREQ_GRP.RELATED_LINES_TBL_TYPE;
BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('Update_CONTRACT_price');
    END IF;
    IF (l_debug = 'Y') THEN
       my_debug('2000 : Entering Update_CONTRACT_price', 2);
    END IF;

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PROCESS',
                                               x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                    raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    Set_control_rec(px_control_rec);
    if px_control_rec.p_calc_flag = 'S' then
       OKC_API.set_message(p_app_name      => g_app_name,
                                 p_msg_name      => 'OKC_INVALID_CALC_FLAG',
                                 p_token1        => 'calc_flag',
                                 p_token1_value  => 'S');

        RAISE OKC_API.G_EXCEPTION_ERROR;
    End if;


    IF px_control_rec.p_level = 'QA' THEN
       g_qa_mode := 'Y';
    ELSE
       g_qa_mode := 'N';
    END IF;

    ---???? how to control only header adjustments get applied.
    --px_control_rec.p_level:= 'L';
    --????  how to control that only header adj applied to passed in lines ask jay
      select level,cle_id,id,object_version_number,price_level_ind,price_basis_yn,config_top_model_line_id,
             line_number, lse_id
      bulk collect into l_lvl_tbl,l_cle_id_tbl,l_id_tbl,l_obj_tbl,l_p_tbl,l_bpi_tbl,l_top_model_tbl,
                        l_line_number_tbl, l_lse_id_tbl
      from OKC_K_LINES_B
      connect by prior id = cle_id
      start with chr_id = p_chr_id;
      IF (l_debug = 'Y') THEN
         my_debug('2100 : select rowcount'||SQL%ROWCOUNT, 1);
      END IF;

    i:= l_id_tbl.first;
    l_p_found := false;
    l_rowlevel :=0;
    -- This loop will take out all the first occurrences of priced lines(there can be more
    -- if recursive) and all occurrneces in case of config lines
    IF (l_debug = 'Y') THEN
       my_debug('2102 :starting out nocopy loop to filter priced lines', 1);
    END IF;
-- this might not work if config item below non config item which I think is not possible right now
    while i is not null loop

        /*****************************************************************
           commenting out nocopy as this check has been moved to new procedure
           OKC_QA_PRICE_PVT.check_covered_line_qty  (Bug 2503412)

        IF px_control_rec.p_level = 'QA' AND l_lse_id_tbl(i) = 41 Then
           /** if this procedure is being called from QA i.e. OKC_QA_PRICE_PVT.Check_Price then
               perform validation to ensure that the quantity of a (sub) line of linestyle 'covered line'
               matches  that of the (top) line to which it points.
           validate_covered_line_qty (p_chr_id             =>  p_CHR_ID,
                                      p_cle_id             =>  l_id_tbl(i),
                                      p_l_id_tbl           =>  l_id_tbl,
                                      p_l_cle_id_tbl       =>  l_cle_id_tbl,
                                      p_l_line_number_tbl  =>  l_line_number_tbl,
                                      x_return_status      =>  l_return_status
                                     );

           IF l_return_status = OKC_API.G_RET_STS_ERROR THEN
              --we want QA to eventually pick up the error messages on the stack
              l_qa_covered_line_qty_mismatch := TRUE;
           End If;

           IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           End If;
        End If;
        ******************************************************************/

        If l_lvl_tbl(i) = 1 or l_lvl_tbl(i)<= l_rowlevel then
            l_p_found :=false;
            l_rowlevel:=l_lvl_tbl(i);
        End if;
        If l_p_tbl(i)='Y'  and l_p_found=false
        AND ((l_top_model_tbl(i) is null) OR
              (l_top_model_tbl(i) is not null and l_top_model_tbl(i) <> l_id_tbl(i)))
        then
          IF (l_debug = 'Y') THEN
             my_debug('2109 : Priced Lines returned'||l_id_tbl(i), 1);
          END IF;
           x_cle_price_tbl(i).id:=l_id_tbl(i);
           If l_top_model_tbl(i) is null then
              l_p_found := true;
              l_rowlevel := l_lvl_tbl(i);
           END IF;
        ELSE
           l_p_tbl(i):='N';
        End If;
        IF (l_debug = 'Y') THEN
           my_debug('2110 : line id'||l_id_tbl(i), 1);
           my_debug('2111 : priced flag'||l_p_tbl(i), 1);
           my_debug('2112 : top model line'||l_top_model_tbl(i), 1);
           my_debug('2113 : row level'||l_lvl_tbl(i), 1);
        END IF;
        If l_p_found then
          IF (l_debug = 'Y') THEN
             my_debug('2114 : priced already found', 1);
          END IF;
        Else
          IF (l_debug = 'Y') THEN
             my_debug('2115 : priced not found', 1);
          END IF;
        End if;
        IF (l_debug = 'Y') THEN
           my_debug('2116 : saved rowlevel'||l_rowlevel, 1);
        END IF;

        i:=l_id_tbl.next(i);
   END loop;

   IF (l_debug = 'Y') THEN
      my_debug('2120 : Before call to Calculate price priced count'||x_cle_price_tbl.count, 1);
   END IF;

    CALCULATE_price(p_api_version                => p_api_version,
                    p_CHR_ID                     => p_chr_id,
                    p_Control_Rec			     => px_control_rec,
                    px_req_line_tbl              => l_req_line_tbl,
                    px_Req_qual_tbl              => l_req_line_qual_tbl,
                    px_Req_line_attr_tbl         => l_req_line_attr_tbl,
                    px_Req_LINE_DETAIL_tbl       => l_req_line_detail_tbl,
                    px_Req_LINE_DETAIL_qual_tbl  => l_req_line_detail_qual_tbl,
                    px_Req_LINE_DETAIL_attr_tbl  => l_req_line_detail_attr_tbl,
                    px_Req_RELATED_LINE_TBL      => l_req_related_line_tbl,
                    px_CLE_PRICE_TBL		     => x_CLE_PRICE_TBL,
                    x_return_status              => x_return_status,
                    x_msg_count                  => x_msg_count,
                    x_msg_data                   => x_msg_data);
      IF (l_debug = 'Y') THEN
         my_debug('2130 : After call to Calculate price return status'||x_return_status, 1);
      END IF;

     IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    --In case of header any error means total rollback
     ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
                  RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;
    IF (l_debug = 'Y') THEN
       my_debug('2140 : After call to Calculate price Priced Count'||x_cle_price_tbl.count, 1);
    END IF;

     -- go on even if error
  -- do rollups
     Begin
        Select object_version_number,estimated_amount,total_line_list_price
        into l_obj,l_amt,l_list_price
        From okc_k_headers_b
        where id=p_chr_id;
        l_chr_rec.id := p_chr_id;
        l_chr_rec.object_version_number := l_obj;
        l_chr_rec.estimated_amount := null;
        l_chr_rec.total_line_list_price := null;
        l_chr_rec.pricing_date := g_hdr_pricing_date;

        IF (l_debug = 'Y') THEN
           my_debug('2200 : header select rowcount should be 1: '||SQL%ROWCOUNT, 1);
        END IF;

      Exception
         When no_data_found then
                            IF (l_debug = 'Y') THEN
                               my_debug('2210 : no data found. Not possible code error', 1);
                            END IF;

                      null;
     End;
      j:=0;
       --for all the priced lines , do the following
      i:= x_cle_price_tbl.first;
      while i is not null loop
        IF (l_debug = 'Y') THEN
           my_debug('2220 : In while loop I is '||i, 1);
           my_debug('2230 : Return status'||x_cle_price_tbl(i).ret_sts, 1);
           my_debug('2240 : Line Id'||x_cle_price_tbl(i).id, 1);
        END IF;
        --if the priced line is P(and not BPI) and the return status is not unexpected error
        If  x_cle_price_tbl(i).pi_bpi ='P' and x_cle_price_tbl(i).ret_sts <> 'U' then --??????ret_sts='S'
          -- make cle buffer equal to priced id

          l_cle_id := x_cle_price_tbl(i).id;
          -- start from the last in array as the parents of the priced line will be prior to it in array\
          l_ind := l_id_tbl.last;
          while l_ind is not null loop
                  IF (l_debug = 'Y') THEN
                     my_debug('2250 : In while l_cle_id'||l_cle_id, 1);
                     my_debug('2260 : In while l_id'||l_id_tbl(l_ind), 1);
                     my_debug('2270 : In while bpi'||l_bpi_tbl(l_ind), 1);
                  END IF;
            -- if the cle buffer id found
             If (l_id_tbl(l_ind)=l_cle_id ) then --#1
                If  (nvl(l_bpi_tbl(l_ind),'N') <> 'Y' )then --#2
                    IF (l_debug = 'Y') THEN
                       my_debug('2280 : In NOT BPI IF:', 1);
                    END IF;
                    -- create a record to update the okc_k_lines

                   l_cle_tbl(l_ind).id :=l_id_tbl(l_ind);
                    IF (l_debug = 'Y') THEN
                       my_debug('2290 : loop for line id:'||l_cle_tbl(l_ind).id, 1);
                    END IF;

                   l_cle_tbl(l_ind).object_version_number :=l_obj_tbl(l_ind);
                   If l_cle_tbl(l_ind).price_negotiated = OKC_API.G_MISS_NUM then
                       l_cle_tbl(l_ind).price_negotiated := null;
                   End if;
                   If l_cle_tbl(l_ind).line_list_price = OKC_API.G_MISS_NUM then
                       l_cle_tbl(l_ind).line_list_price := null;
                   End if;
                    -- If the priced line had some negotiated amount over it
                    IF x_cle_price_tbl(i).negotiated_amt is not null then
                       l_cle_tbl(l_ind).price_negotiated :=
                         nvl(l_cle_tbl(l_ind).price_negotiated,0) + x_cle_price_tbl(i).negotiated_amt;
                    End If;
                    IF (l_debug = 'Y') THEN
                       my_debug('2300 : negotiated amount on line:'||l_cle_tbl(l_ind).price_negotiated, 1);
                    END IF;
                      -- if the priced line had some list price over it
                    IF  x_cle_price_tbl(i).list_price is not null  then
                      l_cle_tbl(l_ind).line_list_price :=
                         nvl(l_cle_tbl(l_ind).line_list_price,0) + x_cle_price_tbl(i).list_price;
                    END IF;
                    IF (l_debug = 'Y') THEN
                       my_debug('2310 : list price  on line:'||l_cle_tbl(l_ind).line_list_price, 1);
                    END IF;


                   If l_id_tbl(l_ind) = x_cle_price_tbl(i).id then -- that means priced line #3
                      If x_cle_price_tbl(i).PRICELIST_ID is not null
                            and x_cle_price_tbl(i).PRICELIST_ID<> OKC_API.G_MISS_NUM then
                         l_cle_tbl(l_ind).price_list_id :=x_cle_price_tbl(i).PRICELIST_ID;
                         l_cle_tbl(l_ind).pricing_date :=x_cle_price_tbl(i).pricing_date;
                         l_cle_tbl(l_ind).price_list_line_id :=x_cle_price_tbl(i).list_line_id;
                         IF (l_debug = 'Y') THEN
                            my_debug('2320 : price list found  price list id:'||l_cle_tbl(l_ind).price_list_id, 1);
                            my_debug('2330 : price list found  price list line id:'||l_cle_tbl(l_ind).price_list_line_id, 1);
                         END IF;

                      End If;
                  ---???? nothing regarding rolling up of updated neg price in contract apis. ask john
                    -- l_cle_tbl(l_ind).line_list_price := x_cle_price_tbl(i).list_price;
                     l_cle_tbl(l_ind).price_unit:= x_cle_price_tbl(i).unit_price;
                     IF (l_debug = 'Y') THEN
                        my_debug('2340 : unit price:'||l_cle_tbl(l_ind).price_unit, 1);
                     END IF;
                   END IF; --#3
               END IF; --#2
               -- if we have reached the topmost line
               If l_lvl_tbl(l_ind)=1 then
                  If x_cle_price_tbl(i).negotiated_amt is not null then
                     l_chr_rec.estimated_amount := nvl(l_chr_rec.estimated_amount,0)+x_cle_price_tbl(i).negotiated_amt;
                  End If;
                  If x_cle_price_tbl(i).list_price is not null then
                     l_chr_rec.total_line_list_price := nvl(l_chr_rec.total_line_list_price,0)+x_cle_price_tbl(i).list_price;
                  End if;
                 IF (l_debug = 'Y') THEN
                    my_debug('2350 : priced lines negotiated amount:'||x_cle_price_tbl(i).negotiated_amt, 1);
                    my_debug('2360 : priced lines list price:'||x_cle_price_tbl(i).list_price, 1);
                    my_debug('2370 : new header estimated amount:'||l_chr_rec.estimated_amount, 1);
                    my_debug('2380 : new header list price:'||l_chr_rec.total_line_list_price, 1);
                 END IF;

                  exit; -- we have reached the top. so no point going any further
               End If;
               -- if configurator line then rollup to top model line directly
               If l_top_model_tbl.exists(l_ind)  and  l_top_model_tbl(l_ind) is not null
                  and l_top_model_tbl(l_ind) <> l_id_tbl(l_ind) then
                  IF (l_debug = 'Y') THEN
                     my_debug('2390 : Top model line exists top model id is:'||l_top_model_tbl(l_ind), 1);
                  END IF;
                  l_cle_id := l_top_model_tbl(l_ind);
               Else
                  l_cle_id :=nvl(l_cle_id_tbl(l_ind),0);
               End If;
                 IF (l_debug = 'Y') THEN
                    my_debug('2392 : l_cle_id is:'||l_cle_id, 1);
                 END IF;

             END IF; --#1
            l_ind:=l_id_tbl.prior(l_ind);
          end loop;
          IF (l_debug = 'Y') THEN
             my_debug('2394 : loop ended l_ind:'||l_ind, 1);
          END IF;

        End If;
        i:=x_cle_price_tbl.next(i);
     END loop;
     -- do not pick up directly  from the summary line
     -- we might have to deduct BPI amount from that as we donot rollup
     -- amount on BPI. Also the amount there is after header discounts
     x_chr_net_price := l_chr_rec.estimated_amount;
     IF (l_debug = 'Y') THEN
        my_debug('2392 :Header amount '||x_chr_net_price, 1);
        my_debug('2394 :p_level '||px_control_rec.p_level, 1);
     END IF;

     If px_control_rec.p_level = 'H' then
         IF (l_debug = 'Y') THEN
            my_debug('2400 : Before calling update contract line', 1);
         END IF;
         okc_contract_pub.update_contract_line (
    	      p_api_version => 1,
    	      p_init_msg_list => OKC_API.G_FALSE,
    	      x_return_status => l_return_status,
    	      x_msg_count => x_msg_count,
    	      x_msg_data => x_msg_data,
    		 -- p_restricted_update => okc_api.g_true,
    	      p_clev_tbl => l_cle_tbl,
    	      x_clev_tbl => x_cle_tbl);
         IF (l_debug = 'Y') THEN
            my_debug('2410 : after calling update contract line status :'||l_return_status, 1);
         END IF;

         IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
               RAISE OKC_API.G_EXCEPTION_ERROR;
         END IF;
         IF (l_debug = 'Y') THEN
            my_debug('2420 : Before calling update contract header', 1);
         END IF;
          okc_contract_pub.update_contract_header (
    	                    p_api_version => 1,
    	                    p_init_msg_list => OKC_API.G_FALSE,
    	                    x_return_status => l_return_status,
    	                    x_msg_count => x_msg_count,
    	                    x_msg_data => x_msg_data,
    		              -- p_restricted_update => okc_api.g_true,
    	                    p_chrv_rec => l_chr_rec,
    	                    x_chrv_rec => x_chr_rec);
         IF (l_debug = 'Y') THEN
            my_debug('2430 : after calling update contract header status :'||l_return_status, 1);
         END IF;

          IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
                  RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;
      End If; --p_level='H'
      IF (l_debug = 'Y') THEN
         my_debug('2440 : p_commit :'||p_commit, 1);
      END IF;
     If p_commit = OKC_API.G_TRUE then
        Commit work;
     End If;
     IF (l_debug = 'Y') THEN
        my_debug('2450:--------------Priced line tbl returned from update contract price---------------');
     END IF;
I := x_cle_price_tbl.FIRST;
IF I IS NOT NULL THEN
 LOOP

                      IF (l_debug = 'Y') THEN
                         my_debug(' 2460: pi_bpi:'||x_cle_price_tbl(i).pi_bpi,1);
                         my_debug(' 2470:ID :'||x_cle_price_tbl(i).ID ,1);
                         my_debug(' 2480:UOM :'||x_cle_price_tbl(i).UOM_CODE,1 );
                         my_debug(' 2490:LINE_NUM:'||x_cle_price_tbl(i).LINE_NUM,1 );
                         my_debug(' 2500:LIST_PRICE :'|| x_cle_price_tbl(i).LIST_PRICE ,1);
                         my_debug(' 2510:UNIT_PRICE:'||x_cle_price_tbl(i).UNIT_PRICE ,1);
                         my_debug(' 2520:NEGOTIATED_AMT :'||x_cle_price_tbl(i).NEGOTIATED_AMT,1 );
                         my_debug(' 2530:PRICELIST_ID :'||x_cle_price_tbl(i).PRICELIST_ID ,1);
                         my_debug(' 2540: RET_CODE :'||x_cle_price_tbl(i).RET_CODE,1);
                         my_debug(' 2550: qty :'||x_cle_price_tbl(i).qty ,1);
                         my_debug(' 2560: RET_STS :'||x_cle_price_tbl(i).RET_STS ,1);
                      END IF;
  EXIT WHEN I =x_cle_price_tbl.LAST;
  I := x_cle_price_tbl.NEXT(I);
   END LOOP;
END IF;

  /***************************************************************************
    commenting out nocopy as this check has been moved to new procedure
    OKC_QA_PRICE_PVT.check_covered_line_qty  (Bug 2503412)

  If px_control_rec.p_level = 'QA' AND l_qa_covered_line_qty_mismatch = TRUE Then
     /** this means that validate_covered_line_qty() has put some error messages on the
         error stack which we now want QA to display in the QA results
     x_return_status := OKC_API.G_RET_STS_ERROR;
  End If;
  ****************************************************************************/



 OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

 IF (l_debug = 'Y') THEN
    my_debug('2600 : Exiting Update_Contract_price', 2);
 END IF;
 IF (l_debug = 'Y') THEN
    okc_debug.Reset_Indentation;
 END IF;


    EXCEPTION
          WHEN l_exception_stop then
               x_return_status := OKC_API.G_RET_STS_SUCCESS;
              IF (l_debug = 'Y') THEN
                 my_debug('2690 : Exiting Update_Contract_price', 4);
              END IF;
              IF (l_debug = 'Y') THEN
                 okc_debug.Reset_Indentation;
              END IF;

          WHEN OKC_API.G_EXCEPTION_ERROR THEN
              x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                       'OKC_API.G_RET_STS_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');
           IF (l_debug = 'Y') THEN
              my_debug('2700 : Exiting Update_Contract_price', 4);
           END IF;
           IF (l_debug = 'Y') THEN
              okc_debug.Reset_Indentation;
           END IF;

         WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
              x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                       'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');
           IF (l_debug = 'Y') THEN
              my_debug('2800 : Exiting Update_Contract_price', 4);
           END IF;
           IF (l_debug = 'Y') THEN
              okc_debug.Reset_Indentation;
           END IF;

         WHEN OTHERS THEN
              OKC_API.set_message(p_app_name      => g_app_name,
                                 p_msg_name      => g_unexpected_error,
                                 p_token1        => g_sqlcode_token,
                                 p_token1_value  => sqlcode,
                                 p_token2        => g_sqlerrm_token,
                                 p_token2_value  => sqlerrm);
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
           IF (l_debug = 'Y') THEN
              my_debug('2900 : Exiting Update_Contract_price', 4);
           END IF;
           IF (l_debug = 'Y') THEN
              okc_debug.Reset_Indentation;
           END IF;

 END Update_Contract_price;

--------------------Called from APIs------------------------------------------------
--FUNCTION - GET_LSE_SOURCE_VALUE
-- This function is used in mapping of attributes between QP and OKC lines
-- The calls to this function will be made by QP Engine to get values for
--various Qualifiers and Pricing Attributes
-- p_lse_tbl - Global Table holding various OKX_SOURCES and their values for lse
-- p_registered_source - The source for which value should be returned
-- Returns the value for the p_registered_source
----------------------------------------------------------------------------
FUNCTION Get_LSE_SOURCE_VALUE (
            p_lse_tbl            IN      global_lse_tbl_type,
            p_registered_source  IN      VARCHAR2)
RETURN VARCHAR2 IS
     i NUMBER:=0;
Begin
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('Get_LSE_SOURCE_VALUE');
    END IF;
    IF (l_debug = 'Y') THEN
       my_debug('3000 : Entering Get_LSE_SOURCE_VALUE', 2);
    END IF;

            If p_lse_tbl.count>0 then
                 i:= p_lse_tbl.first;
                 LOOP
                    If p_lse_tbl(i).current_source = p_registered_source then
                            IF (l_debug = 'Y') THEN
                               my_debug('3300 : Exiting Get_LSE_SOURCE_VALUE', 2);
                            END IF;
                            IF (l_debug = 'Y') THEN
                               okc_debug.Reset_Indentation;
                            END IF;

                            return   p_lse_tbl(i).source_value;

                    End If;
                    Exit When i=p_lse_tbl.last;
                    i:= p_lse_tbl.next(i);
                End Loop;
            End If; -- p_lse_type.count
           IF (l_debug = 'Y') THEN
              my_debug('3400 : Exiting Get_LSE_SOURCE_VALUE', 2);
           END IF;
           IF (l_debug = 'Y') THEN
              okc_debug.Reset_Indentation;
           END IF;

           return null;

           EXCEPTION
           WHEN OTHERS then
             IF (l_debug = 'Y') THEN
                my_debug('3450 :should not have come current source:'|| p_lse_tbl(i).current_source,1);
                my_debug('3460 :sql code:'||sqlcode,1);
                my_debug('3470 :msg:'||sqlerrm,1);
                my_debug('3500 : Exiting Get_LSE_SOURCE_VALUE', 4);
             END IF;
             IF (l_debug = 'Y') THEN
                okc_debug.Reset_Indentation;
             END IF;

              RETURN NULL;
END Get_LSE_SOURCE_VALUE;

-----------------------------------------------------------------------------
--FUNCTION - GET_RUL_SOURCE_VALUE
-- This function is used in mapping of attributes between QP and OKC rules
-- The calls to this function will be made by QP Engine to get values for
--various Qualifiers and Pricing Attributes
-- p_rul_tbl - Global Table holding various OKX_SOURCES and their values for rules
-- p_registered_code - The rule code for which value should be returned
-- p_registered_source - The source for which value should be returned
-- Returns the value for the p_registered_source+p_registered_code
----------------------------------------------------------------------------
FUNCTION Get_RUL_SOURCE_VALUE (
            p_rul_tbl            IN      global_rprle_tbl_type,
            p_registered_code    IN      varchar2,
            p_registered_source  IN      VARCHAR2)
RETURN VARCHAR2 IS
     i NUMBER:=0;
Begin
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('GET_RUL_SOURCE_VALUE');
    END IF;
    IF (l_debug = 'Y') THEN
       my_debug('3600 : Entering GET_RUL_SOURCE_VALUE', 2);
       my_debug('3610 :looking for code'||p_registered_code, 1);
       my_debug('3620 : looking for source'||p_registered_source, 1);
       my_debug('3630 :table count'||p_rul_tbl.count, 1);
    END IF;


            If p_rul_tbl.count>0 then
                 i:= p_rul_tbl.first;
                 LOOP
                     IF (l_debug = 'Y') THEN
                        my_debug('3635 :going thru code'||p_rul_tbl(i).code, 1);
                        my_debug('3640 : going thru source'||p_rul_tbl(i).current_source, 1);
                     END IF;

                    If p_rul_tbl(i).current_source = p_registered_source
                         and p_rul_tbl(i).code = p_registered_code then
                             IF (l_debug = 'Y') THEN
                                my_debug('3650 : Found the rec , value-'||p_rul_tbl(i).source_value, 1);
                             END IF;

                             IF (l_debug = 'Y') THEN
                                my_debug('3700 : Exiting GET_RUL_SOURCE_VALUE', 2);
                             END IF;
                             IF (l_debug = 'Y') THEN
                                okc_debug.Reset_Indentation;
                             END IF;

                             return   p_rul_tbl(i).source_value;
                    End If;
                    Exit When i=p_rul_tbl.last;
                    i:= p_rul_tbl.next(i);
                End Loop;
            End If; -- p_rul_type.count
    IF (l_debug = 'Y') THEN
       my_debug('3750 : Could not find the rec', 1);
    END IF;

    IF (l_debug = 'Y') THEN
       my_debug('3800 : Exiting GET_RUL_SOURCE_VALUE', 2);
    END IF;
    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;

           return null;

           EXCEPTION
           WHEN OTHERS then
             IF (l_debug = 'Y') THEN
                my_debug('3850 :should not have come current source:'|| p_rul_tbl(i).current_source,1);
                my_debug('3860 :sql code:'||sqlcode,1);
                my_debug('3870 :msg:'||sqlerrm,1);
                my_debug('3900 : Exiting GET_RUL_SOURCE_VALUE', 4);
             END IF;
             IF (l_debug = 'Y') THEN
                okc_debug.Reset_Indentation;
             END IF;

              RETURN NULL;
END Get_RUL_SOURCE_VALUE;

-----------------------------------------------------------------------------
--FUNCTION - GET_PRLE_SOURCE_VALUE
-- This function is used in mapping of attributes between QP and OKC rules
-- The calls to this function will be made by QP Engine to get values for
--various Qualifiers and Pricing Attributes
-- p_rul_tbl - Global Table holding various OKX_SOURCES and their values for rules
-- p_registered_code - The role code for which value should be returned
-- p_registered_source - The source for which value should be returned
-- Returns the value for the p_registered_source+p_registered_code
----------------------------------------------------------------------------
FUNCTION Get_PRLE_SOURCE_VALUE (
            p_prle_tbl            IN      global_rprle_tbl_type,
            p_registered_code    IN      varchar2,
            p_registered_source  IN      VARCHAR2)
RETURN VARCHAR2 IS
     i NUMBER:=0;
Begin
         IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('Get_PRLE_SOURCE_VALUE');
         END IF;
         IF (l_debug = 'Y') THEN
            my_debug('4000 : Entering Get_PRLE_SOURCE_VALUE', 2);
         END IF;
            If p_prle_tbl.count>0 then
                 i:= p_prle_tbl.first;
                 LOOP
                    If p_prle_tbl(i).current_source = p_registered_source
                         and p_prle_tbl(i).code = p_registered_code then
                              IF (l_debug = 'Y') THEN
                                 my_debug('4100 : Exiting Get_PRLE_SOURCE_VALUE', 2);
                              END IF;
                              IF (l_debug = 'Y') THEN
                                 okc_debug.Reset_Indentation;
                              END IF;

                             return   p_prle_tbl(i).source_value;
                    End If;
                    Exit When i=p_prle_tbl.last;
                    i:= p_prle_tbl.next(i);
                End Loop;
            End If; -- p_prle_type.count
         IF (l_debug = 'Y') THEN
            my_debug('4200 : Exiting Get_PRLE_SOURCE_VALUE', 2);
         END IF;
         IF (l_debug = 'Y') THEN
            okc_debug.Reset_Indentation;
         END IF;

           return null;

           EXCEPTION
           WHEN OTHERS then
             IF (l_debug = 'Y') THEN
                my_debug('4250 :should not have come current source:'|| p_prle_tbl(i).current_source,1);
                my_debug('4260 :sql code:'||sqlcode,1);
                my_debug('4270 :msg:'||sqlerrm,1);
                my_debug('4300 : Exiting Get_PRLE_SOURCE_VALUE', 4);
             END IF;
             IF (l_debug = 'Y') THEN
                okc_debug.Reset_Indentation;
             END IF;

              RETURN NULL;
END Get_PRLE_SOURCE_VALUE;
---------------------------------------------------------------------------
--FUNCTION - ADD_TO_GLOBAL_lse_TBL
-- This proc. checks if the data source specified is alredy there
-- in global tbl or not. If not, it adds the sent in record to the global table
-- else just comes out without adding
-- p_global_rec - Global record with source and its value;
-- Returns status of the call
----------------------------------------------------------------------------
FUNCTION Add_TO_GLOBAL_LSE_TBL (
            p_global_rec         IN      global_lse_rec_type)
            Return varchar2 IS
            l_return_status varchar2(1):=OKC_API.G_RET_STS_SUCCESS;
            i               number :=0;
            l_already_there   Exception;
Begin
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('Add_TO_GLOBAL_LSE_TBL');
    END IF;
    IF (l_debug = 'Y') THEN
       my_debug('4400 : Entering Add_TO_GLOBAL_LSE_TBL', 2);
    END IF;

           If okc_price_pub.g_lse_tbl.count>0 then
                 i:= okc_price_pub.g_lse_tbl.first;
                 LOOP
                    If okc_price_pub.g_lse_tbl(i).current_source = p_global_rec.current_source then
                             raise l_already_there;
                    End If;
                    Exit When i= okc_price_pub.g_lse_tbl.last;
                    i:= okc_price_pub.g_lse_tbl.next(i);
                End Loop;
           End If; -- g_lse_type.count
           IF (l_debug = 'Y') THEN
              my_debug('4450 : current source'||p_global_rec.current_source, 1);
              my_debug('4460 : source value'||p_global_rec.source_value, 1);
           END IF;

           okc_price_pub.g_lse_tbl(i+1):=p_global_rec;
           IF (l_debug = 'Y') THEN
              my_debug('4500 : Exiting Add_TO_GLOBAL_LSE_TBL', 2);
           END IF;
           IF (l_debug = 'Y') THEN
              okc_debug.Reset_Indentation;
           END IF;

           return l_return_status;
  EXCEPTION
    WHEN l_already_there then
           IF (l_debug = 'Y') THEN
              my_debug('4550 : Already there current source'||p_global_rec.current_source, 1);
              my_debug('4560 : source value'||p_global_rec.source_value, 1);
           END IF;

           IF (l_debug = 'Y') THEN
              my_debug('4600 : Exiting Add_TO_GLOBAL_LSE_TBL', 4);
           END IF;
           IF (l_debug = 'Y') THEN
              okc_debug.Reset_Indentation;
           END IF;

	   return l_return_status;
    when others then
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      IF (l_debug = 'Y') THEN
         my_debug('4620 :Unexpected Error:'|| p_global_rec.current_source,1);
         my_debug('4630 :sql code:'||sqlcode,1);
         my_debug('4640 :msg:'||sqlerrm,1);
      END IF;

       IF (l_debug = 'Y') THEN
          my_debug('4700 : Exiting Add_TO_GLOBAL_LSE_TBL', 2);
       END IF;
       IF (l_debug = 'Y') THEN
          okc_debug.Reset_Indentation;
       END IF;

      return l_return_status;
End Add_TO_GLOBAL_LSE_TBL;

---------------------------------------------------------------------------
--FUNCTION - ADD_TO_GLOBAL_TBL
-- This proc. checks if the data source specified is alredy there
-- in global tbl or not. If not, it adds the sent in record to the global table
-- else just comes out without adding
-- p_global_rec - Global record with source and its value;
-- Returns status of the call
----------------------------------------------------------------------------
FUNCTION Add_TO_GLOBAL_TBL (
            p_global_tbl         IN OUT NOCOPY      global_rprle_tbl_type,
            p_global_rec         IN      global_rprle_rec_type)
            Return varchar2 IS
            l_return_status varchar2(1):=OKC_API.G_RET_STS_SUCCESS;
            i               number :=0;
            l_already_there   Exception;
Begin
         IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('Add_TO_GLOBAL_TBL');
         END IF;
         IF (l_debug = 'Y') THEN
            my_debug('4800 : Entering Add_TO_GLOBAL_TBL', 2);
         END IF;

           If p_global_tbl.count>0 then
                 i:= p_global_tbl.first;
                 LOOP
                    If p_global_tbl(i).current_source = p_global_rec.current_source
                         and p_global_tbl(i).code = p_global_rec.code then
                             raise l_already_there;
                    End If;
                    Exit When i= p_global_tbl.last;
                    i:= p_global_tbl.next(i);
                End Loop;
           End If; -- p_global_tbl.count
           IF (l_debug = 'Y') THEN
              my_debug('4850 : current source'||p_global_rec.current_source, 1);
              my_debug('4860 : current code'||p_global_rec.code, 1);
              my_debug('4860 : source value'||p_global_rec.source_value, 1);
           END IF;

           p_global_tbl(i+1):=p_global_rec;
            IF (l_debug = 'Y') THEN
               my_debug('4900 : Exiting Add_TO_GLOBAL_TBL', 2);
            END IF;
            IF (l_debug = 'Y') THEN
               okc_debug.Reset_Indentation;
            END IF;

           return l_return_status;
  EXCEPTION
    WHEN l_already_there then
           IF (l_debug = 'Y') THEN
              my_debug('4950 : Already there current source'||p_global_rec.current_source, 1);
              my_debug('4960 : Already there current code'||p_global_rec.code, 1);
              my_debug('4970 : source value'||p_global_rec.source_value, 1);
           END IF;

            IF (l_debug = 'Y') THEN
               my_debug('5000 : Exiting Add_TO_GLOBAL_TBL', 4);
            END IF;
            IF (l_debug = 'Y') THEN
               okc_debug.Reset_Indentation;
            END IF;

	   return l_return_status;
    when others then
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            IF (l_debug = 'Y') THEN
               my_debug('5050 :Unexpected Error:'|| p_global_rec.current_source,1);
               my_debug('5060 :sql code:'||sqlcode,1);
               my_debug('5070 :msg:'||sqlerrm,1);
            END IF;

            IF (l_debug = 'Y') THEN
               my_debug('5100 : Exiting Add_TO_GLOBAL_TBL', 4);
            END IF;
            IF (l_debug = 'Y') THEN
               okc_debug.Reset_Indentation;
            END IF;

      return l_return_status;
End Add_TO_GLOBAL_TBL;
---------------------------------------------------------------------------
--FUNCTION - Attach_rules
-- This proc. puts the rule source in the global table
-- Returns status of the call
----------------------------------------------------------------------------
Function Attach_Rules(p_chr_id  NUMBER, p_cle_id number default null)
  Return Varchar2 Is
  cursor l_rul_csr(p_chr_id IN NUMBER) Is

     -- The query below has been introduced in place of one below it because of performance reasons
     -- Right now the rules cannot be defined by a user. Neither can he set the pricing_related_yn
     -- flag nor change the source of the rule. Also, we are not expecting the user to enter
     -- Attribute mapping for rules. All these things might be allowed in phase 2. Because of all
     -- these restrictions, we donot need the bigger picture here where we expect the user to
     -- map his own rules in his own rulegroups and then map them to some pricing qualifier/pricing
     -- attribute. So we decided to restrict the query to filter out the unnecessary data that we will
     -- never use. At some point , If the phase 2 is implemented and the user is expected to define
     -- his own rules in rulegroups and define the sources and set pricing_related_yn flag and then
     -- map the value to some pricing attribute, this query will have to be changed to one below.
     -- In that scenario, even the one below will work but will not be efficient and has to be modified to filter based
     -- pricing_related_yn flag
     -- This query also has to be changed if we map some other rule in attribute mapping at some point
     -- Also, this query assumes, based on current mapping of rules in rulegroups, that BTO rule
     -- will only be in rulegroup BILLING and not in SHIPPING or PAYMENT , STO in SHIPPING and not in
     -- BILLING or PAYMENT , PTR in PAYMENT and not in SHIPPING or BILLING (that is the way it is right now)
     -- If the rules mapping is picking up wrong values, check for the validity of this assumption first
      select rul.jtot_object1_code,rul.object1_id1,rul.object1_id2
            ,rul.jtot_object2_code,rul.object2_id1,rul.object2_id2
            ,rul.jtot_object3_code,rul.object3_id1,rul.object3_id2
            ,rul.rule_information_category
      from okc_rules_b rul, okc_rule_groups_b rgp
      where rul.rgp_id = rgp.id and
            rgp.rgd_code in ('BILLING','SHIPPING','PAYMENT') and
            rul.rule_information_category in ('BTO','STO','PTR','CAN') and
            rgp.dnz_chr_id = p_chr_id and rgp.chr_id is not null;

--  the query below has been replaced by one above.please read the comments
  /*  select rul.jtot_object1_code,rul.object1_id1,rul.object1_id2,rul.jtot_object2_code,
           rul.object2_id1,rul.object2_id2, rul.jtot_object3_code,rul.object3_id1,rul.object3_id2
           ,rul.rule_information_category
          -- ,rul.rule_information1,rul.rule_information2,
           --rul.rule_information3,rul.rule_information4,rul.rule_information5,rul.rule_information6,
           --rul.rule_information7,rul.rule_information8,rul.rule_information9,rul.rule_information10,
           --rul.rule_information11,rul.rule_information12,rul.rule_information13,rul.rule_information14,
           --rul.rule_information15
           from okc_rules_b rul, okc_rule_groups_b rgp
           where rul.rgp_id = rgp.id and rgp.chr_id = p_chr_id;*/

 cursor l_cle_rul_csr(p_chr_id IN NUMBER,p_cle_id IN NUMBER) Is

      -- The query below has been introduced in place of one below it because of performance reasons
      -- see comments above for header
      select rul.jtot_object1_code,rul.object1_id1,rul.object1_id2
            ,rul.jtot_object2_code,rul.object2_id1,rul.object2_id2
            ,rul.jtot_object3_code,rul.object3_id1,rul.object3_id2
            ,rul.rule_information_category

      from okc_rules_b rul, okc_rule_groups_b rgp
      where rul.rgp_id = rgp.id and rgp.dnz_chr_id = p_chr_id and
            rgp.cle_id=p_cle_id and
            rgp.rgd_code in ('BILLING','SHIPPING','PAYMENT') and
            rul.rule_information_category in ('BTO','STO','PTR','CAN');

  /*  select rul.jtot_object1_code,rul.object1_id1,rul.object1_id2,rul.jtot_object2_code,
           rul.object2_id1,rul.object2_id2, rul.jtot_object3_code,rul.object3_id1,rul.object3_id2
           ,rul.rule_information_category
          -- ,rul.rule_information1,rul.rule_information2,
           --rul.rule_information3,rul.rule_information4,rul.rule_information5,rul.rule_information6,
           --rul.rule_information7,rul.rule_information8,rul.rule_information9,rul.rule_information10,
           --rul.rule_information11,rul.rule_information12,rul.rule_information13,rul.rule_information14,
           --rul.rule_information15
           from okc_rules_b rul, okc_rule_groups_b rgp
           where rul.rgp_id = rgp.id and rgp.dnz_chr_id = p_chr_id and rgp.cle_id=p_cle_id;*/

  l_return_status varchar2(1):=OKC_API.G_RET_STS_SUCCESS;
  l_rul_rec    global_rprle_rec_type;
  l_rul_data   l_rul_csr%rowtype;
BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('Attach_Rules');
    END IF;
    IF (l_debug = 'Y') THEN
       my_debug('5200 : Entering Attach_Rules', 2);
    END IF;

     If p_cle_id is null then
        OPEN l_rul_csr(p_chr_id);
     Else
        OPEN l_cle_rul_csr(p_chr_id,p_cle_id);
     END IF;

     LOOP
        If p_cle_id is null then
           fetch l_rul_csr into l_rul_data;
           Exit when l_rul_csr%NOTFOUND;
        Else
            fetch l_cle_rul_csr into l_rul_data;
            Exit when l_cle_rul_csr%NOTFOUND;
        END IF;
         IF (l_debug = 'Y') THEN
            my_debug('5210 : Found a record', 1);
            my_debug('5212 : object1_id1'||l_rul_data.object1_id1, 1);
            my_debug('5214 : object1_code'||l_rul_data.jtot_object1_code, 1);
            my_debug('5216 : rule code'||l_rul_data.rule_information_category, 1);
         END IF;

--???? This condition that l_rul_data.object1_id2 = '#' might have to go when
-- service starts using Pricing as in category of Warranty... some records have
-- second value
        If l_rul_data.object1_id1 is not null and l_rul_data.object1_id2 = '#' then
                  l_rul_rec.current_source:=l_rul_data.jtot_object1_code;
                  l_rul_rec.code :=l_rul_data.rule_information_category;
                  l_rul_rec.source_value := l_rul_data.object1_id1;
                  l_return_status:= add_to_global_tbl(okc_price_pub.g_rul_tbl,l_rul_rec);
                  IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
					 RAISE l_exception_stop;
                  END IF;

        End If;
        If l_rul_data.object2_id1 is not null and l_rul_data.object2_id2  = '#' then
                  l_rul_rec.current_source:=l_rul_data.jtot_object2_code;
                  l_rul_rec.code :=l_rul_data.rule_information_category;
                  l_rul_rec.source_value := l_rul_data.object2_id1;
                  l_return_status:= add_to_global_tbl(okc_price_pub.g_rul_tbl,l_rul_rec);
                  IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
					 RAISE l_exception_stop;
                  END IF;
        End If;
        If l_rul_data.object3_id1 is not null and l_rul_data.object3_id2 = '#' then
                  l_rul_rec.current_source:=l_rul_data.jtot_object3_code;
                  l_rul_rec.code :=l_rul_data.rule_information_category;
                  l_rul_rec.source_value := l_rul_data.object3_id1;
                  l_return_status:= add_to_global_tbl(okc_price_pub.g_rul_tbl,l_rul_rec);
                  IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
					 RAISE l_exception_stop;
                  END IF;

        End If;
     End LOOP;
     If l_rul_csr%ISOPEN then
         close l_rul_csr;
     ELSIf l_cle_rul_csr%ISOPEN then
         close l_cle_rul_csr;
     END IF;
     IF (l_debug = 'Y') THEN
        my_debug('5700 : Exiting Attach_Rules', 2);
     END IF;
     IF (l_debug = 'Y') THEN
        okc_debug.Reset_Indentation;
     END IF;

     return l_return_status;

  EXCEPTION
    WHEN l_exception_stop then
     If l_rul_csr%ISOPEN then
         close l_rul_csr;
     ELSIf l_cle_rul_csr%ISOPEN then
         close l_cle_rul_csr;
     END IF;
     IF (l_debug = 'Y') THEN
        my_debug('5800 : Exiting Attach_Rules', 4);
     END IF;
     IF (l_debug = 'Y') THEN
        okc_debug.Reset_Indentation;
     END IF;

	 return l_return_status;
    when others then
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      If l_rul_csr%ISOPEN then
         close l_rul_csr;
      ELSIf l_cle_rul_csr%ISOPEN then
         close l_cle_rul_csr;
      END IF;
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      IF (l_debug = 'Y') THEN
         my_debug('5900 : Exiting Attach_Rules', 4);
      END IF;
      IF (l_debug = 'Y') THEN
         okc_debug.Reset_Indentation;
      END IF;

      return l_return_status;
END Attach_rules;

---------------------------------------------------------------------------
--FUNCTION - Attach_party_roles
-- This proc. puts the party role source in the global table
-- Returns status of the call
----------------------------------------------------------------------------
Function Attach_party_roles(p_chr_id  NUMBER, p_cle_id IN NUMBER default null)
  Return Varchar2 Is
  cursor l_chr_csr(p_chr_id IN NUMBER) Is
            ---???????? only id1
    select jtot_object1_code, object1_id1,object1_id2,rle_code
    from okc_k_party_roles_b
     where dnz_chr_id = p_chr_id and chr_id is not null;

  cursor l_cle_csr(p_chr_id IN NUMBER, p_cle_id IN NUMBER) Is
            ---???????? only id1
    select jtot_object1_code,object1_id1,object1_id2,rle_code
    from okc_k_party_roles_b
    where dnz_chr_id = p_chr_id and cle_id=p_cle_id;
  l_prle_data   l_chr_csr%rowtype;
  l_return_status varchar2(1):=OKC_API.G_RET_STS_SUCCESS;
  l_prle_rec    global_rprle_rec_type;
BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('Attach_party_roles');
    END IF;
    IF (l_debug = 'Y') THEN
       my_debug('6000 : Entering Attach_party_roles', 2);
    END IF;

     If p_cle_id is null then
        OPEN l_chr_csr(p_chr_id);
     Else
        OPEN l_cle_csr(p_chr_id,p_cle_id);
     END IF;
     LOOP
           If p_cle_id is null then
                Fetch l_chr_csr into l_prle_data;
                Exit when l_chr_csr%NOTFOUND;
           Else
                Fetch l_cle_csr into l_prle_data;
                Exit when l_cle_csr%NOTFOUND;
           END IF;
           If l_prle_data.object1_id1 is not null and l_prle_data.object1_id2 = '#' then
                  l_prle_rec.current_source:=l_prle_data.jtot_object1_code;
                  l_prle_rec.code :=l_prle_data.rle_code;
                  l_prle_rec.source_value := l_prle_data.object1_id1;
                  ---?????????? do we need unique check in global prle table as
                  ---??????????? there could be same role multiple times on a contract
                  ---????? coming from same source e.d third party  in gsi
                  ---??? Then do we pick the first one only or do we allow duplication here
                  ---??? as any of the third party could get us some modifier
                  --??? doing above might become a problem when duplication checked in extra pricing attributes.
                  -- ?????Use party precedence column to check which party role should be sent
                  ---???? when same role multiple times on a contract.
                  l_return_status:= add_to_global_tbl(okc_price_pub.g_prle_tbl,l_prle_rec);
                  IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
					 RAISE l_exception_stop;
                  END IF;
           End If;

     END LOOP;
     If l_chr_csr%isopen then
           close l_chr_csr;
     ELSIF l_cle_csr%isopen then
           close l_cle_csr;
     END IF;
    IF (l_debug = 'Y') THEN
       my_debug('6700 : Exiting Attach_party_roles',2);
    END IF;
    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;

     return l_return_status;
  -- --dbms_output.put_line('attach_party_roles');
  EXCEPTION
    WHEN l_exception_stop then
       If l_chr_csr%isopen then
           close l_chr_csr;
       ELSIF l_cle_csr%isopen then
           close l_cle_csr;
        END IF;
    IF (l_debug = 'Y') THEN
       my_debug('6800 : Exiting Attach_party_roles', 4);
    END IF;
    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;

	   return l_return_status;
    when others then
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
       l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
       If l_chr_csr%isopen then
           close l_chr_csr;
       ELSIF l_cle_csr%isopen then
           close l_cle_csr;
        END IF;
    IF (l_debug = 'Y') THEN
       my_debug('6900 : Exiting Attach_party_roles', 4);
    END IF;
    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;

      return l_return_status;
END Attach_party_roles;
---------------------------------------------------------------------------
--FUNCTION - IS_ALREADY_THERE
-- This function determines if the attribute sent in is already there or not
-- Returns 'Y' if already there else 'N'
--p_pricing_contexts_Tbl - Pricing context table from build_context
--p_qualifier_contexts_Tbl- Qualifier context table from build_context
--p_context - Context name
--p_attrib_name-Attribute name
---------------------------------------------------------------------------
FUNCTION IS_ALREADY_THERE(
          p_pricing_attrib_tbl    QP_PREQ_GRP.LINE_ATTR_TBL_TYPE
         ,p_qual_tbl              QP_PREQ_GRP.QUAL_TBL_TYPE
         ,p_line_index            number
         ,p_context               varchar2
         ,p_attrib_name           varchar2
         ) Return varchar2 IS

         i  pls_integer;
         l_return_flag  varchar2(1):='N';
 BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('IS_ALREADY_THERE');
    END IF;
    IF (l_debug = 'Y') THEN
       my_debug('7000 : Entering IS_ALREADY_THERE', 2);
    END IF;

      If p_attrib_name like 'PRICING%' then --#1
            i := p_pricing_attrib_Tbl.First;
	        While i is not null loop
                IF  p_context =  p_pricing_attrib_tbl(i).PRICING_CONTEXT
                    and p_attrib_name = p_pricing_attrib_tbl(i).PRICING_ATTRIBUTE
                    and p_line_index = p_pricing_attrib_tbl(i).line_index
                THEN
                    IF (l_debug = 'Y') THEN
                       my_debug('7050 : Exiting IS_ALREADY_THERE', 2);
                    END IF;
                    IF (l_debug = 'Y') THEN
                       okc_debug.Reset_Indentation;
                    END IF;

                    return 'Y';
                END IF;
		        i := p_pricing_attrib_Tbl.Next(i);
	        end loop;
      ELSIF p_attrib_name like 'QUALIFIER%' then  --#1
            i := p_qual_Tbl.First;
	        While i is not null loop
                IF  p_context =  p_qual_tbl(i).QUALIFIER_CONTEXT
                    and p_attrib_name = p_qual_tbl(i).QUALIFIER_ATTRIBUTE
                    and p_line_index = p_qual_tbl(i).line_index

                THEN
                    IF (l_debug = 'Y') THEN
                       my_debug('7100 : Exiting IS_ALREADY_THERE', 2);
                    END IF;
                    IF (l_debug = 'Y') THEN
                       okc_debug.Reset_Indentation;
                    END IF;

                    return 'Y';
                END IF;
		        i := p_qual_Tbl.Next(i);
	        end loop;

      END IF; --#1
    IF (l_debug = 'Y') THEN
       my_debug('7200 : Exiting IS_ALREADY_THERE', 2);
    END IF;
    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;

      return l_return_flag;
 END IS_ALREADY_THERE;
---------------------------------------------------------------------------
--Procedure - Copy_Attribs_To_req
-- This proc. copies the data returned by build_context to request line
-- qulaifier and pricing attribute tables.
--p_line_index - Index of the request line
--p_pricing_contexts_Tbl - Pricing context table from build_context
--p_qualifier_contexts_Tbl- Qualifier context table from build_context
--px_Req_line_attr_tbl - Pricing context table for request line
--px_Req_qual_tbl - Qualifier context table for request line
----------------------------------------------------------------------------
procedure copy_attribs_to_Req(
        p_line_index				               number
       ,p_pricing_contexts_Tbl 		               QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type
       ,p_qualifier_contexts_Tbl 	               QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type
       ,px_Req_line_attr_tbl		in out nocopy  QP_PREQ_GRP.LINE_ATTR_TBL_TYPE
       ,px_Req_qual_tbl			    in out nocopy  QP_PREQ_GRP.QUAL_TBL_TYPE
)is
i			    pls_integer := 0;
l_attr_index	pls_integer := nvl(px_Req_line_attr_tbl.last,0);
l_qual_index	pls_integer := nvl(px_Req_qual_tbl.last,0);
begin
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('copy_attribs_to_Req');
    END IF;
    IF (l_debug = 'Y') THEN
       my_debug('7300 : Entering copy_attribs_to_Req', 2);
       my_debug('7302 : p_line_index'||p_line_index, 1);
       my_debug('7303 : pricing attrib count '||px_Req_line_attr_tbl.count, 1);
    END IF;

	i := p_pricing_contexts_Tbl.First;
	While i is not null loop

           IF (IS_ALREADY_THERE(px_Req_line_attr_tbl,px_Req_qual_tbl,p_line_index
                      ,p_pricing_contexts_Tbl(i).context_name
                      ,p_pricing_contexts_Tbl(i).Attribute_Name) = 'N') then


            		l_attr_index := l_attr_index +1;
                    IF (l_debug = 'Y') THEN
                       my_debug('7304 : attrib added table index'||l_attr_index, 1);
                    END IF;

		            px_Req_line_attr_tbl(l_attr_index).VALIDATED_FLAG := 'N';
		            px_Req_line_attr_tbl(l_attr_index).line_index := p_line_index;

			        -- Product and Pricing Contexts go into pricing contexts...
			        px_Req_line_attr_tbl(l_attr_index).PRICING_CONTEXT :=
								p_pricing_contexts_Tbl(i).context_name;
			        px_Req_line_attr_tbl(l_attr_index).PRICING_ATTRIBUTE :=
							p_pricing_contexts_Tbl(i).Attribute_Name;
			        px_Req_line_attr_tbl(l_attr_index).PRICING_ATTR_VALUE_FROM :=
							p_pricing_contexts_Tbl(i).attribute_value;
                   IF (l_debug = 'Y') THEN
                      my_debug('7320 : context name'||p_pricing_contexts_Tbl(i).context_name, 1);
                      my_debug('7322 : context attrib'||p_pricing_contexts_Tbl(i).Attribute_Name, 1);
                      my_debug('7324 : context value'||p_pricing_contexts_Tbl(i).attribute_value, 1);
                   END IF;

             END IF;

		i := p_pricing_contexts_Tbl.Next(i);
	end loop;
-- Copy the qualifiers
	i := p_qualifier_contexts_Tbl.First;
	While i is not null loop
		If NOT(p_qualifier_contexts_Tbl(i).context_name ='MODLIST' and
			p_qualifier_contexts_Tbl(i).Attribute_Name ='QUALIFIER_ATTRIBUTE4' )then
                 IF (IS_ALREADY_THERE(px_Req_line_attr_tbl,px_Req_qual_tbl,p_line_index
                                  ,p_qualifier_contexts_Tbl(i).context_name
                                  ,p_qualifier_contexts_Tbl(i).Attribute_Name) = 'N') then
		                  l_qual_index := l_qual_index +1;
		                  px_Req_qual_tbl(l_qual_index).VALIDATED_FLAG := 'N';
                          px_Req_qual_tbl(l_qual_index).line_index := p_line_index;
		                  px_Req_qual_tbl(l_qual_index).QUALIFIER_CONTEXT :=
					           p_qualifier_contexts_Tbl(i).context_name;
		                  px_Req_qual_tbl(l_qual_index).QUALIFIER_ATTRIBUTE :=
					           p_qualifier_contexts_Tbl(i).Attribute_Name;
		                  px_Req_qual_tbl(l_qual_index).QUALIFIER_ATTR_VALUE_FROM :=
					   	       p_qualifier_contexts_Tbl(i).attribute_value;
                 END IF;

		End If;
		i := p_qualifier_contexts_Tbl.Next(i);
	end loop;
   IF (l_debug = 'Y') THEN
      my_debug('7490 : pricing attrib count '||px_Req_line_attr_tbl.count, 1);
   END IF;

    IF (l_debug = 'Y') THEN
       my_debug('7500 : Exiting copy_attribs_to_Req', 2);
    END IF;
    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;

end copy_attribs_to_Req;

---------------------------------------------------------------------------
--Procedure - Copy_Attribs
-- This proc. copies the PA and QA to request line's
-- qulaifier and pricing attribute tables.
--p_line_index - Index of the request line
--p_pricing_contexts_Tbl - Pricing context table from build_context
--p_qualifier_contexts_Tbl- Qualifier context table from build_context
--px_Req_line_attr_tbl - Pricing context table for request line
--px_Req_qual_tbl - Qualifier context table for request line
--p_check - call is_already_there or not. possible 'Y','N' Default 'Y'
----------------------------------------------------------------------------
procedure copy_attribs(
        p_line_index				               number
       ,p_check                                    varchar2
       ,p_pricing_contexts_Tbl 		               QP_PREQ_GRP.LINE_ATTR_TBL_TYPE
       ,p_qualifier_contexts_Tbl 	               QP_PREQ_GRP.QUAL_TBL_TYPE
       ,px_Req_line_attr_tbl		in out nocopy  QP_PREQ_GRP.LINE_ATTR_TBL_TYPE
       ,px_Req_qual_tbl			    in out nocopy  QP_PREQ_GRP.QUAL_TBL_TYPE
)is
i			    pls_integer := 0;
l_attr_index	pls_integer := nvl(px_Req_line_attr_tbl.last,0);
l_qual_index	pls_integer := nvl(px_Req_qual_tbl.last,0);
new_line_index number;
begin
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('copy_attribs');
    END IF;
    IF (l_debug = 'Y') THEN
       my_debug('7600 : Entering copy_attribs', 2);
    END IF;

    IF (l_debug = 'Y') THEN
       my_debug('7610 : Qualifier Attribs to be copied:'||p_qualifier_contexts_Tbl.count,1);
    END IF;
  i:=p_qualifier_contexts_Tbl.first;
  while i is not null loop
         IF (l_debug = 'Y') THEN
            my_debug('7612 :index:'||p_qualifier_contexts_Tbl(i).line_index,1);
            my_debug('7614 :Qualifier Context:'||p_qualifier_contexts_Tbl(i).qualifier_context,1);
            my_debug('7616 :Qualifier Attribute:'||p_qualifier_contexts_Tbl(i).qualifier_attribute,1);
            my_debug('7618 :Qualifier Value:'||p_qualifier_contexts_Tbl(i).qualifier_attr_value_from,1);
            my_debug('7620 :validated:'||p_qualifier_contexts_Tbl(i).validated_flag,1);
            my_debug('7622 :status code:'||p_qualifier_contexts_Tbl(i).status_code,1);
            my_debug('7624 :status text:'||p_qualifier_contexts_Tbl(i).status_text,1);
         END IF;

   i:=p_qualifier_contexts_Tbl.next(i);

   end loop;
     IF (l_debug = 'Y') THEN
        my_debug('7626 :Qualifier attribs already there before copy:'||px_Req_qual_tbl.count,1);
     END IF;
  i:=px_Req_qual_tbl.first;
  while i is not null loop

        IF (l_debug = 'Y') THEN
           my_debug('7628 :index:'||px_Req_qual_tbl(i).line_index);
           my_debug('7630 :Qualifier Context:'||px_Req_qual_tbl(i).qualifier_context);
           my_debug('7632 :Qualifier Attribute:'||px_Req_qual_tbl(i).qualifier_attribute);
           my_debug('7634 :Qualifier Value:'||px_Req_qual_tbl(i).qualifier_attr_value_from);
           my_debug('7636 :validated:'||px_Req_qual_tbl(i).validated_flag);
           my_debug('7638 :status code:'||px_Req_qual_tbl(i).status_code);
           my_debug('7640 :status text:'||px_Req_qual_tbl(i).status_text);
        END IF;

        i:=px_Req_qual_tbl.next(i);
   end loop;



  IF (l_debug = 'Y') THEN
     my_debug('7642 : Pricing Attribs to be copied:'||p_Pricing_contexts_Tbl.count,1);
  END IF;
  i:=p_Pricing_contexts_Tbl.first;
  while i is not null loop
         IF (l_debug = 'Y') THEN
            my_debug('7644 :index:'||p_Pricing_contexts_Tbl(i).line_index,1);
            my_debug('7646 :Pricing Context:'||p_Pricing_contexts_Tbl(i).Pricing_context,1);
            my_debug('76 :Pricing Attribute:'||p_Pricing_contexts_Tbl(i).Pricing_attribute,1);
            my_debug('7800 :Pricing Value:'||p_Pricing_contexts_Tbl(i).Pricing_attr_value_from,1);
            my_debug('7810 :validated:'||p_Pricing_contexts_Tbl(i).validated_flag,1);
            my_debug('7820 :status code:'||p_Pricing_contexts_Tbl(i).status_code,1);
            my_debug('7830 :status text:'||p_Pricing_contexts_Tbl(i).status_text,1);
         END IF;

   i:=p_Pricing_contexts_Tbl.next(i);

   end loop;
     IF (l_debug = 'Y') THEN
        my_debug('7840 :Pricing attribs already there before copy:'||px_Req_line_attr_tbl.count,1);
     END IF;
  i:=px_Req_line_attr_tbl.first;
  while i is not null loop

        IF (l_debug = 'Y') THEN
           my_debug('7850 :index:'||px_Req_line_attr_tbl(i).line_index);
           my_debug('7860 :Pricing Context:'||px_Req_line_attr_tbl(i).Pricing_context);
           my_debug('7870 :Pricing Attribute:'||px_Req_line_attr_tbl(i).Pricing_attribute);
           my_debug('7880 :Pricing Value:'||px_Req_line_attr_tbl(i).Pricing_attr_value_from);
           my_debug('7890 :validated:'||px_Req_line_attr_tbl(i).validated_flag);
           my_debug('7892 :status code:'||px_Req_line_attr_tbl(i).status_code);
           my_debug('7894 :status text:'||px_Req_line_attr_tbl(i).status_text);
        END IF;

        i:=px_Req_line_attr_tbl.next(i);
   end loop;

	i := p_pricing_contexts_Tbl.First;
	While i is not null loop
	 --Bug 2543687
           IF (p_check in( 'N','NS')) OR
           --Tope Bug 2272022 --Modified to compare/copy index from record

             /* (IS_ALREADY_THERE(px_Req_line_attr_tbl,px_Req_qual_tbl,p_line_index
                      ,p_pricing_contexts_Tbl(i).pricing_context
                     ,p_pricing_contexts_Tbl(i).pricing_attribute) = 'N')
              */

              (IS_ALREADY_THERE(px_Req_line_attr_tbl,px_Req_qual_tbl,p_pricing_contexts_Tbl(i).line_index
                     ,p_pricing_contexts_Tbl(i).pricing_context
                     ,p_pricing_contexts_Tbl(i).pricing_attribute) = 'N')

                 then

            		l_attr_index := l_attr_index +1;
		            px_Req_line_attr_tbl(l_attr_index).line_index := p_pricing_contexts_Tbl(i).line_index;

			        -- Product and Pricing Contexts go into pricing contexts...
   		            px_Req_line_attr_tbl(l_attr_index).VALIDATED_FLAG := p_pricing_contexts_Tbl(i).validated_flag;
			        px_Req_line_attr_tbl(l_attr_index).PRICING_CONTEXT :=
								p_pricing_contexts_Tbl(i).PRICING_CONTEXT;
			        px_Req_line_attr_tbl(l_attr_index).PRICING_ATTRIBUTE :=
							p_pricing_contexts_Tbl(i).PRICING_ATTRIBUTE;
			        px_Req_line_attr_tbl(l_attr_index).PRICING_ATTR_VALUE_FROM :=
							p_pricing_contexts_Tbl(i).PRICING_ATTR_VALUE_FROM;
             END IF;

		i := p_pricing_contexts_Tbl.Next(i);
	end loop;
-- Copy the qualifiers
	i := p_qualifier_contexts_Tbl.First;
	While i is not null loop
       ---Bug 2543687
     If p_check = 'NS' Then
         new_line_index := p_qualifier_contexts_Tbl(i).line_index;
     Else
         new_line_index := p_line_index;
     End If;

		--???? is this check needed
       --- If NOT(p_qualifier_contexts_Tbl(i).QUALIFIER_CONTEXT ='MODLIST' and
		--	p_qualifier_contexts_Tbl(i).QUALIFIER_ATTRIBUTE ='QUALIFIER_ATTRIBUTE4' )then

      	 IF (IS_ALREADY_THERE(px_Req_line_attr_tbl,px_Req_qual_tbl,new_line_index
                                  ,p_qualifier_contexts_Tbl(i).QUALIFIER_CONTEXT
                                  ,p_qualifier_contexts_Tbl(i).QUALIFIER_ATTRIBUTE) = 'N') then

		                  l_qual_index := l_qual_index +1;
                          px_Req_qual_tbl(l_qual_index).line_index := new_line_index;
       		              px_Req_qual_tbl(l_qual_index).VALIDATED_FLAG := p_qualifier_contexts_Tbl(i).validated_flag;
		                  px_Req_qual_tbl(l_qual_index).QUALIFIER_CONTEXT :=
					           p_qualifier_contexts_Tbl(i).QUALIFIER_CONTEXT;
		                  px_Req_qual_tbl(l_qual_index).QUALIFIER_ATTRIBUTE :=
					           p_qualifier_contexts_Tbl(i).QUALIFIER_ATTRIBUTE;
		                  px_Req_qual_tbl(l_qual_index).QUALIFIER_ATTR_VALUE_FROM :=
					   	       p_qualifier_contexts_Tbl(i).QUALIFIER_ATTR_VALUE_FROM;
                 END IF;

	--	End If;
		i := p_qualifier_contexts_Tbl.Next(i);
	end loop;
  --dbms_output.put_line('after copyattribs'||px_Req_qual_tbl.count);
  i:=px_Req_qual_tbl.first;
  while i is not null loop

         --dbms_output.put_line('index '||px_Req_qual_tbl(i).line_index);
          --dbms_output.put_line('starting SAN QA '||'-'||px_Req_qual_tbl(i).qualifier_context);
          --dbms_output.put_line('starting SAN QA '||'-'||px_Req_qual_tbl(i).qualifier_attribute);
          --dbms_output.put_line('starting SAN QA '||'-'||px_Req_qual_tbl(i).qualifier_attr_value_from);
          --dbms_output.put_line('validated '||px_Req_qual_tbl(i).validated_flag);
          --dbms_output.put_line('status code '||px_Req_qual_tbl(i).status_code);
          --dbms_output.put_line('status text '||px_Req_qual_tbl(i).status_text);

        i:=px_Req_qual_tbl.next(i);
   end loop;
    IF (l_debug = 'Y') THEN
       my_debug('7900 : Exiting copy_attribs', 2);
    END IF;
    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;

end copy_ATTRIBS;

--  This Procedure will return the user enterable pricing attributes in contracts
---------------------------------------------------------------------------
--Procedure - Load_User_Defined_Pattrs
-- This Procedure will return the user enterable pricing attributes in contracts
--p_line_index - Index of the request line
--px_Req_line_attr_tbl - Pricing context table for request line
--px_Req_qual_tbl - Qualifier context table for request line
----------------------------------------------------------------------------
Procedure Load_User_Defined_Pattrs(p_chr_id   NUMBER,
                                   p_line_index NUMBER,
                                   px_Req_line_attr_tbl IN OUT NOCOPY QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
                                   px_Req_qual_tbl IN OUT NOCOPY QP_PREQ_GRP.QUAL_TBL_TYPE,
                                   x_return_status   IN OUT NOCOPY varchar2,
                                   p_cle_id  IN  NUMBER DEFAULT NULL
) IS
  cursor okc_pattr_cur(p_chr_id number) is
  select pricing_context,
	    pricing_attribute1,  pricing_attribute2,  pricing_attribute3,  pricing_attribute4,
	    pricing_attribute5,  pricing_attribute6,  pricing_attribute7,  pricing_attribute8,
	    pricing_attribute9,  pricing_attribute10, pricing_attribute11, pricing_attribute12,
	    pricing_attribute13, pricing_attribute14, pricing_attribute15, pricing_attribute16,
	    pricing_attribute17, pricing_attribute18, pricing_attribute19, pricing_attribute20,
	    pricing_attribute21, pricing_attribute22, pricing_attribute23, pricing_attribute24,
	    pricing_attribute25, pricing_attribute26, pricing_attribute27, pricing_attribute28,
	    pricing_attribute29, pricing_attribute30, pricing_attribute31, pricing_attribute32,
	    pricing_attribute33, pricing_attribute34, pricing_attribute35, pricing_attribute36,
	    pricing_attribute37, pricing_attribute38, pricing_attribute39, pricing_attribute40,
	    pricing_attribute41, pricing_attribute42, pricing_attribute43, pricing_attribute44,
	    pricing_attribute45, pricing_attribute46, pricing_attribute47, pricing_attribute48,
	    pricing_attribute49, pricing_attribute50, pricing_attribute51, pricing_attribute52,
	    pricing_attribute53, pricing_attribute54, pricing_attribute55, pricing_attribute56,
	    pricing_attribute57, pricing_attribute58, pricing_attribute59, pricing_attribute60,
	    pricing_attribute61, pricing_attribute62, pricing_attribute63, pricing_attribute64,
	    pricing_attribute65, pricing_attribute66, pricing_attribute67, pricing_attribute68,
	    pricing_attribute69, pricing_attribute70, pricing_attribute71, pricing_attribute72,
	    pricing_attribute73, pricing_attribute74, pricing_attribute75, pricing_attribute76,
	    pricing_attribute77, pricing_attribute78, pricing_attribute79, pricing_attribute80,
	    pricing_attribute81, pricing_attribute82, pricing_attribute83, pricing_attribute84,
	    pricing_attribute85, pricing_attribute86, pricing_attribute87, pricing_attribute88,
	    pricing_attribute89, pricing_attribute90, pricing_attribute91, pricing_attribute92,
	    pricing_attribute93, pricing_attribute94, pricing_attribute95, pricing_attribute96,
	    pricing_attribute97, pricing_attribute98, pricing_attribute99, pricing_attribute100
        ,Qualifier_context,
	    qualifier_attribute1,  qualifier_attribute2,  qualifier_attribute3,  qualifier_attribute4,
	    qualifier_attribute5,  qualifier_attribute6,  qualifier_attribute7,  qualifier_attribute8,
	    qualifier_attribute9,  qualifier_attribute10, qualifier_attribute11, qualifier_attribute12,
	    qualifier_attribute13, qualifier_attribute14, qualifier_attribute15, qualifier_attribute16,
	    qualifier_attribute17, qualifier_attribute18, qualifier_attribute19, qualifier_attribute20,
	    qualifier_attribute21, qualifier_attribute22, qualifier_attribute23, qualifier_attribute24,
	    qualifier_attribute25, qualifier_attribute26, qualifier_attribute27, qualifier_attribute28,
	    qualifier_attribute29, qualifier_attribute30, qualifier_attribute31, qualifier_attribute32,
	    qualifier_attribute33, qualifier_attribute34, qualifier_attribute35, qualifier_attribute36,
	    qualifier_attribute37, qualifier_attribute38, qualifier_attribute39, qualifier_attribute40,
	    qualifier_attribute41, qualifier_attribute42, qualifier_attribute43, qualifier_attribute44,
	    qualifier_attribute45, qualifier_attribute46, qualifier_attribute47, qualifier_attribute48,
	    qualifier_attribute49, qualifier_attribute50, qualifier_attribute51, qualifier_attribute52,
	    qualifier_attribute53, qualifier_attribute54, qualifier_attribute55, qualifier_attribute56,
	    qualifier_attribute57, qualifier_attribute58, qualifier_attribute59, qualifier_attribute60,
	    qualifier_attribute61, qualifier_attribute62, qualifier_attribute63, qualifier_attribute64,
	    qualifier_attribute65, qualifier_attribute66, qualifier_attribute67, qualifier_attribute68,
	    qualifier_attribute69, qualifier_attribute70, qualifier_attribute71, qualifier_attribute72,
	    qualifier_attribute73, qualifier_attribute74, qualifier_attribute75, qualifier_attribute76,
	    qualifier_attribute77, qualifier_attribute78, qualifier_attribute79, qualifier_attribute80,
	    qualifier_attribute81, qualifier_attribute82, qualifier_attribute83, qualifier_attribute84,
	    qualifier_attribute85, qualifier_attribute86, qualifier_attribute87, qualifier_attribute88,
	    qualifier_attribute89, qualifier_attribute90, qualifier_attribute91, qualifier_attribute92,
	    qualifier_attribute93, qualifier_attribute94, qualifier_attribute95, qualifier_attribute96,
	    qualifier_attribute97, qualifier_attribute98, qualifier_attribute99, qualifier_attribute100
    from okc_price_att_values_v
   where chr_id = p_chr_id and cle_id is null;


  cursor okc_pattr_cle_cur(p_chr_id number, p_cle_id number) is
  select pricing_context,
	    pricing_attribute1,  pricing_attribute2,  pricing_attribute3,  pricing_attribute4,
	    pricing_attribute5,  pricing_attribute6,  pricing_attribute7,  pricing_attribute8,
	    pricing_attribute9,  pricing_attribute10, pricing_attribute11, pricing_attribute12,
	    pricing_attribute13, pricing_attribute14, pricing_attribute15, pricing_attribute16,
	    pricing_attribute17, pricing_attribute18, pricing_attribute19, pricing_attribute20,
	    pricing_attribute21, pricing_attribute22, pricing_attribute23, pricing_attribute24,
	    pricing_attribute25, pricing_attribute26, pricing_attribute27, pricing_attribute28,
	    pricing_attribute29, pricing_attribute30, pricing_attribute31, pricing_attribute32,
	    pricing_attribute33, pricing_attribute34, pricing_attribute35, pricing_attribute36,
	    pricing_attribute37, pricing_attribute38, pricing_attribute39, pricing_attribute40,
	    pricing_attribute41, pricing_attribute42, pricing_attribute43, pricing_attribute44,
	    pricing_attribute45, pricing_attribute46, pricing_attribute47, pricing_attribute48,
	    pricing_attribute49, pricing_attribute50, pricing_attribute51, pricing_attribute52,
	    pricing_attribute53, pricing_attribute54, pricing_attribute55, pricing_attribute56,
	    pricing_attribute57, pricing_attribute58, pricing_attribute59, pricing_attribute60,
	    pricing_attribute61, pricing_attribute62, pricing_attribute63, pricing_attribute64,
	    pricing_attribute65, pricing_attribute66, pricing_attribute67, pricing_attribute68,
	    pricing_attribute69, pricing_attribute70, pricing_attribute71, pricing_attribute72,
	    pricing_attribute73, pricing_attribute74, pricing_attribute75, pricing_attribute76,
	    pricing_attribute77, pricing_attribute78, pricing_attribute79, pricing_attribute80,
	    pricing_attribute81, pricing_attribute82, pricing_attribute83, pricing_attribute84,
	    pricing_attribute85, pricing_attribute86, pricing_attribute87, pricing_attribute88,
	    pricing_attribute89, pricing_attribute90, pricing_attribute91, pricing_attribute92,
	    pricing_attribute93, pricing_attribute94, pricing_attribute95, pricing_attribute96,
	    pricing_attribute97, pricing_attribute98, pricing_attribute99, pricing_attribute100
        ,Qualifier_context,
	    qualifier_attribute1,  qualifier_attribute2,  qualifier_attribute3,  qualifier_attribute4,
	    qualifier_attribute5,  qualifier_attribute6,  qualifier_attribute7,  qualifier_attribute8,
	    qualifier_attribute9,  qualifier_attribute10, qualifier_attribute11, qualifier_attribute12,
	    qualifier_attribute13, qualifier_attribute14, qualifier_attribute15, qualifier_attribute16,
	    qualifier_attribute17, qualifier_attribute18, qualifier_attribute19, qualifier_attribute20,
	    qualifier_attribute21, qualifier_attribute22, qualifier_attribute23, qualifier_attribute24,
	    qualifier_attribute25, qualifier_attribute26, qualifier_attribute27, qualifier_attribute28,
	    qualifier_attribute29, qualifier_attribute30, qualifier_attribute31, qualifier_attribute32,
	    qualifier_attribute33, qualifier_attribute34, qualifier_attribute35, qualifier_attribute36,
	    qualifier_attribute37, qualifier_attribute38, qualifier_attribute39, qualifier_attribute40,
	    qualifier_attribute41, qualifier_attribute42, qualifier_attribute43, qualifier_attribute44,
	    qualifier_attribute45, qualifier_attribute46, qualifier_attribute47, qualifier_attribute48,
	    qualifier_attribute49, qualifier_attribute50, qualifier_attribute51, qualifier_attribute52,
	    qualifier_attribute53, qualifier_attribute54, qualifier_attribute55, qualifier_attribute56,
	    qualifier_attribute57, qualifier_attribute58, qualifier_attribute59, qualifier_attribute60,
	    qualifier_attribute61, qualifier_attribute62, qualifier_attribute63, qualifier_attribute64,
	    qualifier_attribute65, qualifier_attribute66, qualifier_attribute67, qualifier_attribute68,
	    qualifier_attribute69, qualifier_attribute70, qualifier_attribute71, qualifier_attribute72,
	    qualifier_attribute73, qualifier_attribute74, qualifier_attribute75, qualifier_attribute76,
	    qualifier_attribute77, qualifier_attribute78, qualifier_attribute79, qualifier_attribute80,
	    qualifier_attribute81, qualifier_attribute82, qualifier_attribute83, qualifier_attribute84,
	    qualifier_attribute85, qualifier_attribute86, qualifier_attribute87, qualifier_attribute88,
	    qualifier_attribute89, qualifier_attribute90, qualifier_attribute91, qualifier_attribute92,
	    qualifier_attribute93, qualifier_attribute94, qualifier_attribute95, qualifier_attribute96,
	    qualifier_attribute97, qualifier_attribute98, qualifier_attribute99, qualifier_attribute100

    from okc_price_att_values_v
   where cle_id = p_cle_id;

--Commenting Line below b/c chr_id is not populated for price attr for lines
   --and chr_id=p_chr_id;

   l_row      okc_pattr_cur%rowtype;
  Procedure Load_Tbl(p_prc_context Varchar2,
                     p_prc_attr Varchar2,
                     p_prc_attr_value Varchar2) Is
    i NUMBER;
  Begin
    --okc_debug.Set_Indentation('Load_Tbl');
    --my_debug('8000 : Entering Load_Tbl', 2);
    If p_prc_attr_value Is Not Null
       and (UPPER(substr(p_prc_attr,1,1))= 'P' )
       Then
      i := nvl(px_Req_line_attr_tbl.last,0) +1;
      px_Req_line_attr_tbl(i).Line_Index := p_Line_Index;
      px_Req_line_attr_tbl(i).Validated_Flag := 'Y';
      px_Req_line_attr_tbl(i).pricing_context := p_prc_context;
      px_Req_line_attr_tbl(i).Pricing_Attribute := p_prc_attr;
      px_Req_line_attr_tbl(i).Pricing_Attr_Value_From :=p_prc_attr_value;
      ELSIf p_prc_attr_value Is Not Null
      and (UPPER(substr(p_prc_attr,1,1))= 'Q' )
      Then
      --?????check for validated_flag for promos
      i := nvl(px_Req_qual_tbl.last,0) +1;
      px_Req_qual_tbl(i).Line_Index := p_Line_Index;
      px_Req_qual_tbl(i).Validated_Flag := 'Y';
      px_Req_qual_tbl(i).qualifier_context := p_prc_context;
      px_Req_qual_tbl(i).qualifier_Attribute := p_prc_attr;
      px_Req_qual_tbl(i).qualifier_attr_Value_From :=p_prc_attr_value;

    End If;
   -- my_debug('8200 : Exiting Load_Tbl', 2);
   -- okc_debug.Reset_Indentation;

  End;
BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('Load_User_Defined_Pattrs');
    END IF;
    IF (l_debug = 'Y') THEN
       my_debug('8300 : Entering Load_User_Defined_Pattrs', 2);
    END IF;

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    If p_cle_id is null then
         open okc_pattr_cur(p_chr_id);
    Else
         open okc_pattr_cle_cur(p_chr_id,p_cle_id);
    END IF;
    LOOP
           If p_cle_id is null then
                Fetch okc_pattr_cur into l_row;
                Exit when okc_pattr_cur%NOTFOUND;
           Else
                Fetch okc_pattr_cle_cur into l_row;
                Exit when okc_pattr_cle_cur%NOTFOUND;
           END IF;
         --  here PRICING_ATTRIBUTE... is cse sensitive. It should always be uppercase
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE1', l_row.PRICING_ATTRIBUTE1);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE2', l_row.PRICING_ATTRIBUTE2);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE3', l_row.PRICING_ATTRIBUTE3);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE4', l_row.PRICING_ATTRIBUTE4);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE5', l_row.PRICING_ATTRIBUTE5);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE6', l_row.PRICING_ATTRIBUTE6);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE7', l_row.PRICING_ATTRIBUTE7);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE8', l_row.PRICING_ATTRIBUTE8);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE9', l_row.PRICING_ATTRIBUTE9);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE10', l_row.PRICING_ATTRIBUTE10);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE11', l_row.PRICING_ATTRIBUTE11);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE12', l_row.PRICING_ATTRIBUTE12);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE13', l_row.PRICING_ATTRIBUTE13);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE14', l_row.PRICING_ATTRIBUTE14);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE15', l_row.PRICING_ATTRIBUTE15);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE16', l_row.PRICING_ATTRIBUTE16);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE17', l_row.PRICING_ATTRIBUTE17);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE18', l_row.PRICING_ATTRIBUTE18);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE19', l_row.PRICING_ATTRIBUTE19);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE20', l_row.PRICING_ATTRIBUTE20);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE21', l_row.PRICING_ATTRIBUTE21);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE22', l_row.PRICING_ATTRIBUTE22);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE23', l_row.PRICING_ATTRIBUTE23);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE24', l_row.PRICING_ATTRIBUTE24);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE25', l_row.PRICING_ATTRIBUTE25);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE26', l_row.PRICING_ATTRIBUTE26);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE27', l_row.PRICING_ATTRIBUTE27);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE28', l_row.PRICING_ATTRIBUTE28);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE29', l_row.PRICING_ATTRIBUTE29);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE30', l_row.PRICING_ATTRIBUTE30);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE31', l_row.PRICING_ATTRIBUTE31);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE32', l_row.PRICING_ATTRIBUTE32);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE33', l_row.PRICING_ATTRIBUTE33);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE34', l_row.PRICING_ATTRIBUTE34);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE35', l_row.PRICING_ATTRIBUTE35);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE36', l_row.PRICING_ATTRIBUTE36);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE37', l_row.PRICING_ATTRIBUTE37);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE38', l_row.PRICING_ATTRIBUTE38);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE39', l_row.PRICING_ATTRIBUTE39);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE40', l_row.PRICING_ATTRIBUTE40);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE41', l_row.PRICING_ATTRIBUTE41);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE42', l_row.PRICING_ATTRIBUTE42);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE43', l_row.PRICING_ATTRIBUTE43);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE44', l_row.PRICING_ATTRIBUTE44);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE45', l_row.PRICING_ATTRIBUTE45);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE46', l_row.PRICING_ATTRIBUTE46);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE47', l_row.PRICING_ATTRIBUTE47);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE48', l_row.PRICING_ATTRIBUTE48);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE49', l_row.PRICING_ATTRIBUTE49);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE50', l_row.PRICING_ATTRIBUTE50);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE51', l_row.PRICING_ATTRIBUTE51);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE52', l_row.PRICING_ATTRIBUTE52);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE53', l_row.PRICING_ATTRIBUTE53);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE54', l_row.PRICING_ATTRIBUTE54);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE55', l_row.PRICING_ATTRIBUTE55);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE56', l_row.PRICING_ATTRIBUTE56);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE57', l_row.PRICING_ATTRIBUTE57);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE58', l_row.PRICING_ATTRIBUTE58);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE59', l_row.PRICING_ATTRIBUTE59);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE60', l_row.PRICING_ATTRIBUTE60);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE61', l_row.PRICING_ATTRIBUTE61);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE62', l_row.PRICING_ATTRIBUTE62);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE63', l_row.PRICING_ATTRIBUTE63);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE64', l_row.PRICING_ATTRIBUTE64);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE65', l_row.PRICING_ATTRIBUTE65);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE66', l_row.PRICING_ATTRIBUTE66);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE67', l_row.PRICING_ATTRIBUTE67);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE68', l_row.PRICING_ATTRIBUTE68);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE69', l_row.PRICING_ATTRIBUTE69);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE70', l_row.PRICING_ATTRIBUTE70);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE71', l_row.PRICING_ATTRIBUTE71);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE72', l_row.PRICING_ATTRIBUTE72);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE73', l_row.PRICING_ATTRIBUTE73);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE74', l_row.PRICING_ATTRIBUTE74);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE75', l_row.PRICING_ATTRIBUTE75);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE76', l_row.PRICING_ATTRIBUTE76);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE77', l_row.PRICING_ATTRIBUTE77);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE78', l_row.PRICING_ATTRIBUTE78);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE79', l_row.PRICING_ATTRIBUTE79);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE80', l_row.PRICING_ATTRIBUTE80);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE81', l_row.PRICING_ATTRIBUTE81);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE82', l_row.PRICING_ATTRIBUTE82);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE83', l_row.PRICING_ATTRIBUTE83);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE84', l_row.PRICING_ATTRIBUTE84);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE85', l_row.PRICING_ATTRIBUTE85);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE86', l_row.PRICING_ATTRIBUTE86);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE87', l_row.PRICING_ATTRIBUTE87);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE88', l_row.PRICING_ATTRIBUTE88);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE89', l_row.PRICING_ATTRIBUTE89);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE90', l_row.PRICING_ATTRIBUTE90);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE91', l_row.PRICING_ATTRIBUTE91);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE92', l_row.PRICING_ATTRIBUTE92);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE93', l_row.PRICING_ATTRIBUTE93);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE94', l_row.PRICING_ATTRIBUTE94);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE95', l_row.PRICING_ATTRIBUTE95);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE96', l_row.PRICING_ATTRIBUTE96);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE97', l_row.PRICING_ATTRIBUTE97);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE98', l_row.PRICING_ATTRIBUTE98);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE99', l_row.PRICING_ATTRIBUTE99);
         LOAD_TBL(l_row.pricing_context, 'PRICING_ATTRIBUTE100', l_row.PRICING_ATTRIBUTE100);
         --qualifiers here QUALIFIER_ATTRIBUTE... is cse sensitive. It should always be uppercase
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE1', l_row.qualifier_ATTRIBUTE1);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE2', l_row.qualifier_ATTRIBUTE2);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE3', l_row.qualifier_ATTRIBUTE3);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE4', l_row.qualifier_ATTRIBUTE4);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE5', l_row.QUALIFIER_ATTRIBUTE5);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE6', l_row.QUALIFIER_ATTRIBUTE6);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE7', l_row.QUALIFIER_ATTRIBUTE7);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE8', l_row.QUALIFIER_ATTRIBUTE8);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE9', l_row.QUALIFIER_ATTRIBUTE9);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE10', l_row.QUALIFIER_ATTRIBUTE10);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE11', l_row.QUALIFIER_ATTRIBUTE11);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE12', l_row.QUALIFIER_ATTRIBUTE12);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE13', l_row.QUALIFIER_ATTRIBUTE13);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE14', l_row.QUALIFIER_ATTRIBUTE14);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE15', l_row.QUALIFIER_ATTRIBUTE15);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE16', l_row.QUALIFIER_ATTRIBUTE16);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE17', l_row.QUALIFIER_ATTRIBUTE17);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE18', l_row.QUALIFIER_ATTRIBUTE18);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE19', l_row.QUALIFIER_ATTRIBUTE19);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE20', l_row.QUALIFIER_ATTRIBUTE20);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE21', l_row.QUALIFIER_ATTRIBUTE21);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE22', l_row.QUALIFIER_ATTRIBUTE22);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE23', l_row.QUALIFIER_ATTRIBUTE23);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE24', l_row.QUALIFIER_ATTRIBUTE24);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE25', l_row.QUALIFIER_ATTRIBUTE25);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE26', l_row.QUALIFIER_ATTRIBUTE26);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE27', l_row.QUALIFIER_ATTRIBUTE27);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE28', l_row.QUALIFIER_ATTRIBUTE28);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE29', l_row.QUALIFIER_ATTRIBUTE29);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE30', l_row.QUALIFIER_ATTRIBUTE30);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE31', l_row.QUALIFIER_ATTRIBUTE31);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE32', l_row.QUALIFIER_ATTRIBUTE32);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE33', l_row.QUALIFIER_ATTRIBUTE33);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE34', l_row.QUALIFIER_ATTRIBUTE34);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE35', l_row.QUALIFIER_ATTRIBUTE35);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE36', l_row.QUALIFIER_ATTRIBUTE36);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE37', l_row.QUALIFIER_ATTRIBUTE37);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE38', l_row.QUALIFIER_ATTRIBUTE38);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE39', l_row.qualifier_ATTRIBUTE39);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE40', l_row.qualifier_ATTRIBUTE40);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE41', l_row.qualifier_ATTRIBUTE41);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE42', l_row.qualifier_ATTRIBUTE42);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE43', l_row.qualifier_ATTRIBUTE43);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE44', l_row.qualifier_ATTRIBUTE44);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE45', l_row.qualifier_ATTRIBUTE45);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE46', l_row.qualifier_ATTRIBUTE46);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE47', l_row.qualifier_ATTRIBUTE47);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE48', l_row.qualifier_ATTRIBUTE48);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE49', l_row.qualifier_ATTRIBUTE49);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE50', l_row.qualifier_ATTRIBUTE50);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE51', l_row.qualifier_ATTRIBUTE51);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE52', l_row.qualifier_ATTRIBUTE52);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE53', l_row.qualifier_ATTRIBUTE53);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE54', l_row.qualifier_ATTRIBUTE54);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE55', l_row.qualifier_ATTRIBUTE55);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE56', l_row.qualifier_ATTRIBUTE56);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE57', l_row.qualifier_ATTRIBUTE57);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE58', l_row.qualifier_ATTRIBUTE58);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE59', l_row.qualifier_ATTRIBUTE59);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE60', l_row.qualifier_ATTRIBUTE60);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE61', l_row.qualifier_ATTRIBUTE61);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE62', l_row.qualifier_ATTRIBUTE62);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE63', l_row.qualifier_ATTRIBUTE63);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE64', l_row.qualifier_ATTRIBUTE64);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE65', l_row.qualifier_ATTRIBUTE65);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE66', l_row.qualifier_ATTRIBUTE66);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE67', l_row.qualifier_ATTRIBUTE67);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE68', l_row.qualifier_ATTRIBUTE68);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE69', l_row.qualifier_ATTRIBUTE69);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE70', l_row.qualifier_ATTRIBUTE70);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE71', l_row.qualifier_ATTRIBUTE71);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE72', l_row.qualifier_ATTRIBUTE72);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE73', l_row.qualifier_ATTRIBUTE73);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE74', l_row.qualifier_ATTRIBUTE74);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE75', l_row.qualifier_ATTRIBUTE75);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE76', l_row.qualifier_ATTRIBUTE76);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE77', l_row.qualifier_ATTRIBUTE77);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE78', l_row.qualifier_ATTRIBUTE78);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE79', l_row.qualifier_ATTRIBUTE79);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE80', l_row.qualifier_ATTRIBUTE80);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE81', l_row.qualifier_ATTRIBUTE81);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE82', l_row.qualifier_ATTRIBUTE82);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE83', l_row.qualifier_ATTRIBUTE83);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE84', l_row.qualifier_ATTRIBUTE84);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE85', l_row.qualifier_ATTRIBUTE85);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE86', l_row.qualifier_ATTRIBUTE86);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE87', l_row.qualifier_ATTRIBUTE87);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE88', l_row.qualifier_ATTRIBUTE88);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE89', l_row.qualifier_ATTRIBUTE89);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE90', l_row.qualifier_ATTRIBUTE90);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE91', l_row.qualifier_ATTRIBUTE91);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE92', l_row.qualifier_ATTRIBUTE92);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE93', l_row.qualifier_ATTRIBUTE93);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE94', l_row.qualifier_ATTRIBUTE94);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE95', l_row.qualifier_ATTRIBUTE95);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE96', l_row.qualifier_ATTRIBUTE96);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE97', l_row.qualifier_ATTRIBUTE97);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE98', l_row.qualifier_ATTRIBUTE98);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE99', l_row.qualifier_ATTRIBUTE99);
         LOAD_TBL(l_row.qualifier_context, 'QUALIFIER_ATTRIBUTE100', l_row.qualifier_ATTRIBUTE100);
     END LOOP;
     If okc_pattr_cur%isopen then
           close okc_pattr_cur;
     ELSIF okc_pattr_cle_cur%isopen then
           close okc_pattr_cle_cur;
     END IF;
    IF (l_debug = 'Y') THEN
       my_debug('8700 : Exiting Load_User_Defined_Pattrs', 2);
    END IF;
    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;


  EXCEPTION
    when others then
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
       If okc_pattr_cur%isopen then
           close okc_pattr_cur;
       ELSIF okc_pattr_cle_cur%isopen then
           close okc_pattr_cle_cur;
       END IF;
    IF (l_debug = 'Y') THEN
       my_debug('8800 : Exiting Load_User_Defined_Pattrs', 4);
    END IF;
    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;

END Load_User_Defined_Pattrs;

----------------------------------------------------------------------------
-- PROCEDURE BUILD_CHR_CONTEXT
-- This procedure will populate the global table with the data sources
-- and values for them defined at header level
----------------------------------------------------------------------------
PROCEDURE BUILD_CHR_CONTEXT(
          p_api_version             IN         NUMBER ,
          p_init_msg_list           IN         VARCHAR2 ,
          p_request_type_code       IN         VARCHAR2 ,
          p_chr_id                  IN         NUMBER,
          p_pricing_type            IN         VARCHAR2    ,
          p_line_index              IN         NUMBER ,
          x_pricing_contexts_Tbl    OUT NOCOPY QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
          x_qualifier_contexts_Tbl  OUT NOCOPY QP_PREQ_GRP.QUAL_TBL_TYPE,
          x_return_status           OUT NOCOPY VARCHAR2,
          x_msg_count               OUT NOCOPY NUMBER,
          x_msg_data                OUT NOCOPY VARCHAR2) IS

          l_return_status varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
          l_api_name constant VARCHAR2(30) := 'BUILD_CHR_CONTEXT';
          l_pricing_contexts_Tbl     QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
          l_qualifier_contexts_Tbl   QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
          k pls_integer;
          l_price_list_id  number := null;
          l_count pls_integer := 0;
          i pls_integer;
Begin
     IF (l_debug = 'Y') THEN
        okc_debug.Set_Indentation('BUILD_CHR_CONTEXT');
     END IF;
     IF (l_debug = 'Y') THEN
        my_debug('9000 : Entering BUILD_CHR_CONTEXT', 2);
     END IF;

    --dbms_output.put_line('start build_chr_context');

           x_return_status := OKC_API.G_RET_STS_SUCCESS;

           l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PROCESS',
                                               x_return_status);
           IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                    raise OKC_API.G_EXCEPTION_ERROR;
           END IF;

           -- put values from attached rules in global table
           l_return_status:=attach_rules(p_chr_id);
           --dbms_output.put_line('2return status'||l_return_status);

           IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
                RAISE OKC_API.G_EXCEPTION_ERROR;
           END IF;
           -- put values from attached party roles in global table
           l_return_status:=attach_party_roles(p_chr_id);
           --dbms_output.put_line('3return status'||l_return_status);

           IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
                RAISE OKC_API.G_EXCEPTION_ERROR;
           END IF;
           Load_User_Defined_Pattrs(p_chr_id ,
                                   p_line_index ,
                                   x_pricing_contexts_Tbl,
                                   x_qualifier_contexts_Tbl,
                                   x_return_status);
           --dbms_output.put_line('4return status'||x_return_status);

           IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
                RAISE OKC_API.G_EXCEPTION_ERROR;
           END IF;
                      --call pricing build context
           --dbms_output.put_line('5return status'||x_return_status);

           Begin
              /*    --dbms_output.put_line('okc_price_pub.g_rul_tbl');
                  k:=okc_price_pub.g_rul_tbl.first;
                  while k is not null loop
                       --dbms_output.put_line('okc_price_pub.g_rul_tbl'||k||'-'||okc_price_pub.g_rul_tbl(k).code);
                       --dbms_output.put_line('okc_price_pub.g_rul_tbl'||k||'-'||okc_price_pub.g_rul_tbl(k).current_source);
                       --dbms_output.put_line('okc_price_pub.g_rul_tbl'||k||'-'||okc_price_pub.g_rul_tbl(k).source_value);
                       k:=okc_price_pub.g_rul_tbl.next(k);
                   END LOOP;
                  --dbms_output.put_line('okc_price_pub.g_prle_tbl');
                  k:=okc_price_pub.g_prle_tbl.first;

                   while k is not null loop
                       --dbms_output.put_line('okc_price_pub.g_prle_tbl'||k||'-'||okc_price_pub.g_prle_tbl(k).code);
                       --dbms_output.put_line('okc_price_pub.g_prle_tbl'||k||'-'||okc_price_pub.g_prle_tbl(k).current_source);
                       --dbms_output.put_line('okc_price_pub.g_prle_tbl'||k||'-'||okc_price_pub.g_prle_tbl(k).source_value);
                       k:=okc_price_pub.g_prle_tbl.next(k);
                   END LOOP;

*/
                  -- populate global record g_contract_info
                  OKC_PRICE_PUB.G_CONTRACT_INFO:=null;
                  Begin
                      select INV_ORGANIZATION_ID,price_list_id,authoring_org_id,nvl(pricing_date,sysdate)
                      into OKC_PRICE_PUB.G_CONTRACT_INFO.INV_ORG_ID , l_price_list_id,g_authoring_org_id,OKC_PRICE_PUB.G_CONTRACT_INFO.PRICING_DATE
                      from okc_k_headers_b
                      where id = p_chr_id;

                   EXCEPTION
                     when no_data_found then
                          IF (l_debug = 'Y') THEN
                             my_debug('9020 : NO authoring org id found', 1);
                          END IF;
                 END;
-- Bug:2695614 Changes for Price Hold
               Begin
                      select chr_id_referred
                      into OKC_PRICE_PUB.G_CONTRACT_INFO.governing_contract_id
                      from okc_governances
                      where dnz_chr_id = p_chr_id
                      and cle_id is null
                      and rownum=1;

                   EXCEPTION
                     when no_data_found then
                          IF (l_debug = 'Y') THEN
                             my_debug('9020 : No Governing Contract Found', 1);
                          END IF;
                 END;

-- end Bug:2695614
			  -- Modified for Bug 2292742

                 --OKC_PRICE_PUB.G_CONTRACT_INFO.PRICING_DATE:=SYSDATE;
			  g_hdr_pricing_date := OKC_PRICE_PUB.G_CONTRACT_INFO.PRICING_DATE;
                  --populate global variable sold_to_org_id. made it global as it is used
                  -- at many places for build context functions
                 OKC_PRICE_PUB.G_CONTRACT_INFO.SOLD_TO_ORG_ID :=
                              GET_RUL_SOURCE_VALUE(OKC_PRICE_PUB.G_RUL_TBL,'CAN','OKX_CUSTACCT');

                -- add header level pricelist as an attrib if found
                IF  l_price_list_id is not null then
                        g_hdr_pricelist:= l_price_list_id;
                        l_count := x_qualifier_contexts_Tbl.count +1;
                         x_qualifier_contexts_Tbl(l_count).LINE_INDEX := p_line_index;
                         x_qualifier_contexts_Tbl(l_count).QUALIFIER_CONTEXT :='MODLIST';
                         x_qualifier_contexts_Tbl(l_count).QUALIFIER_ATTRIBUTE :='QUALIFIER_ATTRIBUTE4';
                         x_qualifier_contexts_Tbl(l_count).QUALIFIER_ATTR_VALUE_FROM := to_char(l_price_list_id); -- Price List Id
                         x_qualifier_contexts_Tbl(l_count).COMPARISON_OPERATOR_CODE := '=';
                         --x_qualifier_contexts_Tbl(l_count).VALIDATED_FLAG :='Y';
                         x_qualifier_contexts_Tbl(l_count).VALIDATED_FLAG :='N'; --Bug 2760904: we need QP to validate the price list
               END IF;
                 IF (l_debug = 'Y') THEN
                    my_debug('9030 : G_CONTRACT_INFO.PRICING_DATE for header'||OKC_PRICE_PUB.G_CONTRACT_INFO.PRICING_DATE,1);
                    my_debug('9040 : G_CONTRACT_INFO.INV_ORG_ID for header'||OKC_PRICE_PUB.G_CONTRACT_INFO.INV_ORG_ID, 1);
                    my_debug('9050 : G_CONTRACT_INFO.SOLD_TO_ORG_ID for header'||OKC_PRICE_PUB.G_CONTRACT_INFO.SOLD_TO_ORG_ID, 1);
                    my_debug('9060 : G_CONTRACT_INFO.Inventory id for header'||OKC_PRICE_PUB.G_CONTRACT_INFO.INVENTORY_ITEM_ID, 1);
                    my_debug('9070 : G_CONTRACT_INFO.top_model_line for header'||OKC_PRICE_PUB.G_CONTRACT_INFO.TOP_MODEL_LINE_ID, 1);
                    my_debug('9072 : Price list id for header'||l_price_list_id, 1);
                 END IF;

                -- call build context
                IF (l_debug = 'Y') THEN
                   my_debug('9060 : Before Call Build Context for header for request type'||p_request_type_code, 1);
                END IF;
                QP_Attr_Mapping_PUB.Build_Contexts(p_request_type_code => p_request_type_code,
			                                         p_pricing_type	=>	p_pricing_type,
			                                         x_price_contexts_result_tbl => l_pricing_contexts_Tbl,
			                                         x_qual_contexts_result_tbl  => l_qualifier_Contexts_Tbl);
                IF (l_debug = 'Y') THEN
                   my_debug('9070 : After Call Build Context for header', 1);
                END IF;
                -- copy header values to copy them to line global tbls, in case not found on line
                  g_hdr_rul_tbl:=okc_price_pub.g_rul_tbl;
                  g_hdr_prle_tbl:=okc_price_pub.g_prle_tbl;
                  If g_hdr_rul_tbl.count >0 then
                    i:=g_hdr_rul_tbl.first-1;
                    g_hdr_rul_tbl(i).code :='CHR_ID';
                    g_hdr_rul_tbl(i).source_value := p_chr_id;
                  end if;
                  If g_hdr_prle_tbl.count >0 then
                    i:=g_hdr_prle_tbl.first-1;
                    g_hdr_prle_tbl(i).code :='CHR_ID';
                    g_hdr_prle_tbl(i).source_value := p_chr_id;
                  end if;

                  okc_price_pub.g_rul_tbl.DELETE;
                  okc_price_pub.g_prle_tbl.DELETE;
                  OKC_PRICE_PUB.G_CONTRACT_INFO:=null;

              Exception
                  When Others then
                      --dbms_output.put_line('error'||substr(sqlerrm,1,240));
                      OKC_API.set_message(p_app_name      => g_app_name,
                                      p_msg_name      => 'OKC_QP_INT_ERROR',
                                      p_token1        => 'Proc',
                                      p_token1_value  => 'Build_Context for Header',
                                      p_token2        => 'SQLCODE',
                                      p_token2_value  => SQLCODE,
                                      p_token3        => 'Err_TEXT',
                                      p_token3_value  => SQLERRM);
                      Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           End; --call pricing build context
           -- copy build context attribs to request table

           copy_attribs_to_Req(
                  p_line_index
                 ,l_pricing_contexts_Tbl
                 ,l_qualifier_contexts_Tbl
                 ,x_pricing_contexts_Tbl
                 ,x_qualifier_contexts_Tbl);

   OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       my_debug('9600 : Exiting BUILD_CHR_CONTEXT', 2);
    END IF;
    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION

          WHEN OKC_API.G_EXCEPTION_ERROR THEN
              x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                       'OKC_API.G_RET_STS_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');
               IF (l_debug = 'Y') THEN
                  my_debug('9700 : Exiting BUILD_CHR_CONTEXT', 4);
               END IF;
               IF (l_debug = 'Y') THEN
                  okc_debug.Reset_Indentation;
               END IF;

         WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
              x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                       'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');
                IF (l_debug = 'Y') THEN
                   my_debug('9800 : Exiting BUILD_CHR_CONTEXT', 4);
                END IF;
               IF (l_debug = 'Y') THEN
                  okc_debug.Reset_Indentation;
               END IF;

         WHEN OTHERS THEN
              OKC_API.set_message(p_app_name      => g_app_name,
                                 p_msg_name      => g_unexpected_error,
                                 p_token1        => g_sqlcode_token,
                                 p_token1_value  => sqlcode,
                                 p_token2        => g_sqlerrm_token,
                                 p_token2_value  => sqlerrm);
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            IF (l_debug = 'Y') THEN
               my_debug('9900 : Exiting BUILD_CHR_CONTEXT', 4);
            END IF;
            IF (l_debug = 'Y') THEN
               okc_debug.Reset_Indentation;
            END IF;

END BUILD_CHR_CONTEXT;

---------------------------------------------------------------------------
--Procedure - get_line_ids
-- This Procedure will return the ids of the line that will make a request line
--p_cle_id - Id of the priced line
--x_line_tbl- This table will hold the line ids rec for all the lines that
-- make a request line.For related lines, it will hold both the PI as well BPI
----------------------------------------------------------------------------
Procedure get_line_ids (p_chr_id                 NUMBER,
                        p_cle_id                 NUMBER ,
                        x_return_status   IN OUT NOCOPY varchar2,
                        x_line_tbl        OUT NOCOPY    line_TBL_TYPE,
                        x_bpi_ind          OUT NOCOPY    NUMBER ,
                        x_pi_ind           OUT NOCOPY    NUMBER
) IS

     Cursor l_item_csr(p_cle_id NUMBER,p_chr_id NUMBER) is
        SELECT object1_id1, object1_id2, jtot_object1_code, uom_code,number_of_items
        FROM okc_k_items
        where cle_id = p_cle_id and dnz_chr_id=p_chr_id;

     Cursor l_item_csr1(p_cle_id NUMBER) is
        SELECT number_of_items
        FROM okc_k_items
        where Cle_id = p_cle_id and dnz_chr_id=p_chr_id;


--Bug 2543687
    Cursor l_cle_pl(p_cle_id NUMBER) is
	 Select price_list_id from okc_k_lines_b
		   where id = p_cle_id;


     TYPE Cur_tab_type is table of okc_k_lines_b.currency_code%type;
     TYPE Date_tbl_type is table of DATE INDEX BY BINARY_INTEGER;

    l_id                num_tbl_type;
    l_cur               Cur_tab_type;
    l_pricelist_id      num_tbl_type;
    l_price_tbl         num_tbl_type;
    l_list_price_tbl    num_tbl_type;
    l_unit_price_tbl    num_tbl_type;
    l_top_model_tbl     num_tbl_type;
    l_prc_date_tbl      Date_tbl_type;
    l_end_date_tbl      Date_tbl_type;
    l_cle_id_tbl       num_tbl_type;

    l_p                flag_tab_type;
    l_pi               flag_tab_type;
    l_bpi              flag_tab_type;
    l_srvc             flag_tab_type;
    l_item_row  l_item_csr%rowtype;

    l_p_ind  number :=0; -- should always be 1 as we assume that we are getting the id of priced item
    i pls_integer :=0;
    l_item_row1 l_item_csr1%rowtype;
 BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('get_line_ids');
    END IF;
    IF (l_debug = 'Y') THEN
       my_debug('10000 : Entering get_line_ids', 2);
    END IF;
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     x_bpi_ind :=0;
     x_pi_ind  :=0;
     OKC_PRICE_PUB.G_CONTRACT_INFO.top_model_line_id:=null;
     select id,currency_code,price_level_ind
     ,item_to_price_yn,price_basis_yn,nvl(service_item_yn,'N'),price_list_id,price_negotiated,line_list_price,price_unit,config_top_model_line_id,nvl(pricing_date,g_hdr_pricing_date),end_date,cle_id
     BULK COLLECT INTO l_id,l_cur, l_p
      ,l_pi, l_bpi,l_srvc,l_pricelist_id,l_price_tbl,l_list_price_tbl,l_unit_price_tbl, l_top_model_tbl,l_prc_date_tbl,l_end_date_tbl,l_cle_id_tbl
     from okc_k_lines_b
     connect by prior cle_id = id
     start with id=p_cle_id;
     IF (l_debug = 'Y') THEN
        my_debug('10005 : select rowcount for lines fetched'||SQL%ROWCOUNT, 1);
     END IF;

     IF (l_debug = 'Y') THEN
        my_debug('10010 :priced line in question'||p_cle_id);
     END IF;

     IF l_id.count>0 then
        i:= l_id.FIRST;
        While i is not null loop
             -- for configurator lines, we just want to include the config line in question and its parents
             -- from top model line upwards. If there are any other parents in between, they have to be
             -- ignored.
             If  ((l_top_model_tbl(i) is null)
                 OR  (l_top_model_tbl(i) is not null and (l_id(i) = l_top_model_tbl(i) OR  l_id(i) = p_cle_id)))
             then   --#filter dummy config parents
                 OPEN l_item_csr(l_id(i),p_chr_id);
                 Fetch l_item_csr into l_item_row;
                 -- set p_yn , pi_yn flag to 'N' for top model dummy config line
                 If (l_top_model_tbl(i) is not null and l_id(i) = l_top_model_tbl(i)) then
                     l_p(i) := 'N';
                     l_pi(i) := 'N';
                     OKC_PRICE_PUB.G_CONTRACT_INFO.top_model_line_id :=l_item_row.object1_id1;
                 END IF;

                 x_line_tbl(i).id             := l_id(i);
                 x_line_tbl(i).currency       := l_cur(i);
                 x_line_tbl(i).p_yn           := l_p(i);
                 x_line_tbl(i).service_yn     := l_srvc(i);

			  If( l_end_date_tbl(i)  is not null AND
                   (l_prc_date_tbl(i) > l_end_date_tbl(i))) then
                   x_line_tbl(i).pricing_date   := sysdate;
                 Else
				x_line_tbl(i).pricing_date   := l_prc_date_tbl(i);
                 End If;
--Bug Tope
                 If l_item_row.jtot_object1_code in  ('OKX_COVLINE','OKX_CUSTITEM','OKX_CUSTPROD')
                    AND ( l_pricelist_id(i) is  null OR l_pricelist_id(i) = OKC_API.G_MISS_NUM ) THEN
                    For cle_pl_rec in l_cle_pl(l_cle_id_tbl(i)) Loop
                      l_pricelist_id(i):= cle_pl_rec.price_list_id;
                       -- my_debug('price for the serv is '|| cle_pl_rec.price_list_id);
                    End Loop;
                 End If;

                 If l_pricelist_id(i) is not null then
                    x_line_tbl(i).pricelist_id   := l_pricelist_id(i);
                 ELSE
                    x_line_tbl(i).pricelist_id   := g_hdr_pricelist;
                 END IF;

                 IF (l_debug = 'Y') THEN
                    my_debug('10015 :id of line in question'||l_id(i));
                    my_debug('10017 :currency '||l_cur(i));
                    my_debug('10019 :priced flag on line'||l_p(i));
                    my_debug('10021 :pricelist id'||l_pricelist_id(i));
                    my_debug('10023 :item_to_price flag'||l_pi(i));
                    my_debug('10025 :bprice basis  flag'||l_bpi(i));
                 END IF;

                 -- the condition below should never arise if code is correct
                 If l_p(i)='Y' and i <> 1 then
                   close l_item_csr;
                   RAISE l_exception_stop;
                 END IF;
                 -- we are right now setting all pi and bpi 'N' so that after loop finishes
                 -- we will set the highest pi index as 'Y' and highest 'BPI' as 'Y'
                 -- This we are doing because of recursive line styles
                 x_line_tbl(i).pi_yn          := 'N';
                 x_line_tbl(i).bpi_yn         := 'N';
                 IF l_pi(i) = 'Y' then
                  x_pi_ind := i;
                 END IF;
                 IF l_bpi(i) = 'Y' then
                  x_bpi_ind := i;
                 END IF;

                 x_line_tbl(i).qty            := l_item_row.number_of_items;

 --Tope Bug 2386767
                 ---IF l_item_row.jtot_object1_code = 'OKX_COVLINE' Then
                 IF l_item_row.jtot_object1_code = 'OKX_COVLINE' AND g_qa_mode <> 'Y' Then  --abkumar Bug 2503412
                   IF (l_debug = 'Y') THEN
                      my_debug('id1 is '||l_item_row.object1_id1);
                   END IF;
			    Open l_item_csr1(l_item_row.object1_id1);
                   Fetch l_item_csr1 into l_item_row1;

                   If l_item_csr1%found and ((l_item_row1.number_of_items <> x_line_tbl(i).qty)
				   and (l_item_row1.number_of_items is not null)) Then
                         x_line_tbl(i).qty            := l_item_row1.number_of_items ;

                         Update okc_k_items
                         set number_of_items=l_item_row1.number_of_items
                         where cle_id = x_line_tbl(i).id
                         and dnz_chr_id = p_chr_id;
                         IF (l_debug = 'Y') THEN
                            my_debug ('Updated with Service qty'||l_item_row1.number_of_items);
                         END IF;
                    End If;
				Close l_item_csr1;
                  End IF;
---
                 x_line_tbl(i).uom_code       := l_item_row.uom_code;
                 x_line_tbl(i).object_code    := l_item_row.jtot_object1_code;
                 x_line_tbl(i).id1            := l_item_row.object1_id1;
                 x_line_tbl(i).id2            := l_item_row.object1_id2;
                 If x_line_tbl(i).qty is not null and l_list_price_tbl(i)is not null and l_price_tbl(i) is not null then
                    If l_unit_price_tbl(i) is null then
                        x_line_tbl(i).unit_price  := l_list_price_tbl(i);
                    Else
                        x_line_tbl(i).unit_price  := l_unit_price_tbl(i);
                    End If;
                    --???? round off errors
                    x_line_tbl(i).updated_price  := nvl(l_price_tbl(i),0)/x_line_tbl(i).qty;
                 End if;
                 close l_item_csr;
             END IF; -- # end filter dummy config parents
             i:= l_id.next(i);
        END LOOP;
     END IF; -- l_id.count
     If l_item_csr%isopen then
           close l_item_csr;
     END IF;

     If x_pi_ind <>0 then
         x_line_tbl(x_pi_ind).pi_yn:='Y';
     END IF;
     IF x_bpi_ind <> 0 then
         x_line_tbl(x_bpi_ind).bpi_yn:='Y';
     END IF;
    IF (l_debug = 'Y') THEN
       my_debug('10700 : Exiting get_line_ids', 2);
    END IF;
    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;


  EXCEPTION
    WHEN l_exception_stop then
       --dbms_output.put_line('some thing wrong in code. This should not be reached');
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
       If l_item_csr%isopen then
           close l_item_csr;
       END IF;
    IF (l_debug = 'Y') THEN
       my_debug('10800 : Exiting get_line_ids', 4);
    END IF;
    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;

    when others then
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
       If l_item_csr%isopen then
           close l_item_csr;
       END IF;
    IF (l_debug = 'Y') THEN
       my_debug('10900 : Exiting get_line_ids', 4);
    END IF;
    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;

END get_line_ids;


----------------------------------------------------------------------------
-- PROCEDURE BUILD_CLE_CONTEXT
-- This procedure will populate the global table with the data sources
-- and values for them defined at line level
-- p_cle_id - The Priced Line Id.
----------------------------------------------------------------------------

PROCEDURE BUILD_CLE_CONTEXT(
          p_api_version             IN         NUMBER ,
          p_init_msg_list           IN         VARCHAR2 ,
          p_request_type_code       IN         VARCHAR2 ,
          p_chr_id                  IN         NUMBER,
          P_line_tbl                IN         line_TBL_TYPE,
          p_pricing_type            IN         VARCHAR2    ,
          p_line_index              IN         NUMBER    ,
          p_service_price           IN VARCHAR2 ,
          p_service_price_list      IN VARCHAR2 DEFAULT NULL,
          x_pricing_contexts_Tbl    IN OUT NOCOPY  QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
          x_qualifier_contexts_Tbl  IN OUT NOCOPY  QP_PREQ_GRP.QUAL_TBL_TYPE,
          x_return_status           OUT NOCOPY VARCHAR2,
          x_msg_count               OUT NOCOPY NUMBER,
          x_msg_data                OUT NOCOPY VARCHAR2) IS

          i pls_integer :=0;
          l_return_status varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
          l_api_name constant VARCHAR2(30) := 'BUILD_CLE_CONTEXT';
          l_pricing_contexts_Tbl     QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
          l_qualifier_contexts_Tbl   QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type;
          k pls_integer;
          line_attr_rec               QP_PREQ_GRP.LINE_ATTR_REC_TYPE;
          qual_rec                    QP_PREQ_GRP.QUAL_REC_TYPE;


          l_lse_rec     global_lse_rec_type;
          l_prle_rec    global_rprle_rec_type;
          t pls_integer :=0;
          inv_id1     number := 0;
          pricelist   number;

		Cursor covered_prod_csr(p_id number) is
		 Select inventory_item_id
		 from okx_customer_products_v
		 where id1=p_id
		 and status='A'
		 and organization_id=g_authoring_org_id;
Begin
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('BUILD_CLE_CONTEXT');
    END IF;
    IF (l_debug = 'Y') THEN
       my_debug('11000 : Entering BUILD_CLE_CONTEXT', 2);
    END IF;

           x_return_status := OKC_API.G_RET_STS_SUCCESS;

           l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PROCESS',
                                               x_return_status);
           IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                    raise OKC_API.G_EXCEPTION_ERROR;
           END IF;

          IF (l_debug = 'Y') THEN
             my_debug('11010 : number of lines in heirarchy '||p_line_tbl.count,1);
          END IF;
          If p_line_tbl.count > 0 then
               i:= p_line_tbl.first;
               while i is not null loop -- lines loop
                      IF (l_debug = 'Y') THEN
                         my_debug('11020 : index number '||i,1);
                         my_debug('11030 : Id of line under process '||p_line_tbl(i).id,1);
                         my_debug('11035 : value of pi_yn flag '||p_line_tbl(i).pi_yn,1);
                         my_debug('11036 : value of bpi_yn flag '||p_line_tbl(i).bpi_yn,1);
                         my_debug('11037 : value of pricing_date  '||p_line_tbl(i).pricing_date,1);
                      END IF;

                       If p_line_tbl(i).pi_yn ='N' and p_line_tbl(i).bpi_yn = 'N'
                       then
                       --right now only id1 is going. Free format line styles
                       -- are mapped with hypothetical object code 'OKX_FREE'
                           If p_line_tbl(i).object_code is not null then --object_code not null
                              l_lse_rec.current_source := p_line_tbl(i).object_code;
                              l_lse_rec.source_value   := p_line_tbl(i).id1;
                              l_return_status :=ADD_TO_GLOBAL_LSE_TBL(l_lse_rec);

                               IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                                  RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                               ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
                                 RAISE OKC_API.G_EXCEPTION_ERROR;
                               END IF;
                           ELSIF p_line_tbl(i).object_code is null then --object_code not null
                                -- the following pricing context ALL is being sent as for some cases
                                -- like top line priced free format line styles the item is not comimg
                                -- from inventory and the user still wants to price it.
                                -- So , we send this generic parameter, so that if in Pricing there
                                -- is some price defined for all items when price for item to be priced
                                -- cannot be found, this will fetch that price.
                                 line_attr_rec.line_index := p_line_index;
                                 line_attr_rec.PRICING_CONTEXT :='ITEM';
                                 line_attr_rec.PRICING_ATTRIBUTE :='PRICING_ATTRIBUTE3';
                                 line_attr_rec.PRICING_ATTR_VALUE_FROM  := 'ALL'; -- generic value
                                 line_attr_rec.VALIDATED_FLAG :='N';
                                 x_pricing_contexts_Tbl(nvl(x_pricing_contexts_Tbl.last,0)+1):= line_attr_rec;
                                 OKC_PRICE_PUB.G_CONTRACT_INFO.inventory_item_id := null;
                                 -- Along with send ITEM_ALL attrib, we will map free line styles
                                 -- with dummy object code 'OKX_FREE', so that if the user has defined
                                 -- some attrib in pricing context ITEM which picks varchar2 value and
                                 -- then using it has defined a unit price for that attrib in price list
                                 -- it gets picked. Here we are populating the global lse table with
                                 -- object code 'OKX_FREE' and value in column name instead of Id1.
                                 BEGIN
                                    select name into l_lse_rec.source_value
                                    FROM okc_k_lines_v
                                    where id=p_line_tbl(i).id;

                                    l_lse_rec.current_source := 'OKX_FREE';
                                    l_return_status :=ADD_TO_GLOBAL_LSE_TBL(l_lse_rec);

                                    IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                                        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                                    ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
                                        RAISE OKC_API.G_EXCEPTION_ERROR;
                                    END IF;

                                   EXCEPTION
                                    WHEN NO_DATA_FOUND then
                                      null;
                                  END;

                                 IF (l_debug = 'Y') THEN
                                    my_debug('11049 : object code not found ',1);
                                 END IF;
                            End if; --end object_code is not null
                        -- For covered line/product/item build attributes tbl
                            If p_service_price =   'Y' and p_line_tbl(i).p_yn='Y' then
                              line_attr_rec.line_index := p_line_index;
                              line_attr_rec.PRICING_CONTEXT :='ITEM';
                              line_attr_rec.PRICING_ATTRIBUTE :='PRICING_ATTRIBUTE1';
                            -- For covered lines get inventory id from lines
                              If p_line_tbl(i).object_code = 'OKX_COVLINE' then

                               select object1_id1 into inv_id1
                               from okc_k_items
                               where cle_id = p_line_tbl(1).id1;

                               line_attr_rec.PRICING_ATTR_VALUE_FROM  := inv_id1;
                               OKC_PRICE_PUB.G_CONTRACT_INFO.inventory_item_id := inv_id1;
                              ------Elsif  p_line_tbl(i).object_code in ('OKX_CUSTPOD','OKX_CUSTITEM') then
                              Elsif  p_line_tbl(i).object_code in ('OKX_CUSTPROD','OKX_CUSTITEM') then
						  Open covered_prod_csr(p_line_tbl(i).id1);
						  Fetch covered_prod_csr into inv_id1;
						  Close  covered_prod_csr;
						  IF (l_debug = 'Y') THEN
   						  my_debug('11049 inventory id covered :'|| inv_id1);
						  END IF;
                                line_attr_rec.PRICING_ATTR_VALUE_FROM  := inv_id1 ;
                                OKC_PRICE_PUB.G_CONTRACT_INFO.inventory_item_id := inv_id1;
                              End If;
                              line_attr_rec.VALIDATED_FLAG :='N';
                              x_pricing_contexts_Tbl(nvl(x_pricing_contexts_Tbl.last,0)+1):= line_attr_rec;
                              IF (l_debug = 'Y') THEN
                                 my_debug('11050 : Item Id '||p_line_tbl(i).id1,1);
                              END IF;
                            End If;
                       ELSIF p_line_tbl(i).pi_yn ='Y'  then
                            line_attr_rec.line_index := p_line_index;
                            line_attr_rec.PRICING_CONTEXT :='ITEM';
                            line_attr_rec.PRICING_ATTRIBUTE :='PRICING_ATTRIBUTE1';


                             -- Inventory Item Id
                            line_attr_rec.PRICING_ATTR_VALUE_FROM  := p_line_tbl(i).id1;

                            line_attr_rec.VALIDATED_FLAG :='N';
                            OKC_PRICE_PUB.G_CONTRACT_INFO.inventory_item_id := p_line_tbl(i).id1;
                            x_pricing_contexts_Tbl(nvl(x_pricing_contexts_Tbl.last,0)+1):= line_attr_rec;
                            IF (l_debug = 'Y') THEN
                               my_debug('11050 : Item Id '||p_line_tbl(i).id1,1);
                            END IF;

 -- Bug:2695614 Changes for Price Hold
                            Begin
                                select chr_id_referred
                                into OKC_PRICE_PUB.G_CONTRACT_INFO.governing_contract_id
                                from okc_governances
                                where dnz_chr_id = p_chr_id
                                and cle_id =p_line_tbl(i).id
                                and rownum=1;

                       EXCEPTION
                         when no_data_found then
                              IF (l_debug = 'Y') THEN
                                 my_debug('9020 : Governing Contract not Found', 1);
                              END IF;
                       END;

--End Bug:2695614

                      ELSIF p_line_tbl(i).bpi_yn ='Y' then
                       -- assuming pi and bpi will never be there on the same line
                          If p_line_tbl(i).object_code is not null then
                             --here we will pass OKX_MTL_SYSTEM_ITEM as object_code and not actual object code
                             --as the BPI can be a product or something else and then product can come from many views
                             -- with different names but the common thing
                             --in all these views is that they all have usage 'OKX_MTL_SYSTEM_ITEM'
                             -- we could have hardcoded the passing but didnot
                             -- because of BPI as the source of BPI could be a product or something else
                             --as well like Customer Item. Hence decided to map this to item if it is
                             -- product
                             BEGIN
                               select 'OKX_MTL_SYSTEM_ITEM' into l_lse_rec.current_source
                               from JTF_OBJECT_USAGES
                               where object_code= p_line_tbl(i).object_code
                               and OBJECT_USER_CODE = 'OKX_MTL_SYSTEM_ITEM';
                               IF (l_debug = 'Y') THEN
                                  my_debug('11060 : rowcount for OBJECT_USER_CODE '||SQL%ROWCOUNT,1);
                               END IF;
                               -- since this is an inventory item, assigning it to inventory_id
                               OKC_PRICE_PUB.G_CONTRACT_INFO.inventory_item_id := p_line_tbl(i).id1;

                               EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                    IF (l_debug = 'Y') THEN
                                       my_debug('11060 : OKX_MTL_SYSTEM_ITEM not assigned '||p_line_tbl(i).object_code,1);
                                    END IF;
                                    l_lse_rec.current_source := p_line_tbl(i).object_code;

                              END;
                              l_lse_rec.source_value   := p_line_tbl(i).id1;
                              l_return_status :=ADD_TO_GLOBAL_LSE_TBL(l_lse_rec);

                               IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                                  RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                               ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
                                 RAISE OKC_API.G_EXCEPTION_ERROR;
                               END IF;
                          End if; -- if p_line_tbl(i).object_code is not null
                       END IF; -- pi_yn<> 'Y'
                       --attach pricelist if availavble
                       --attach for pi as well when pricing for service
                       IF (p_line_tbl(i).p_yn ='Y'  or  (p_service_price = 'Y' and (p_line_tbl(i).pi_yn ='Y')))
                          Then
                          /**********
                          and (p_line_tbl(i).pricelist_id is not null )and  (p_line_tbl(i).pricelist_id <> OKC_API.G_MISS_NUM) then
                            qual_rec.LINE_INDEX := p_line_index;
                            qual_rec.QUALIFIER_CONTEXT :='MODLIST';
                            qual_rec.QUALIFIER_ATTRIBUTE :='QUALIFIER_ATTRIBUTE4';
                            --qual_rec.QUALIFIER_ATTR_VALUE_FROM := to_char(p_line_tbl(i).pricelist_id); -- Price List Id
                           ***********/
                           --commented out for Bug 2774859: the service line may not have a price list attached to it
                           --in which case, we go on to get the price list from the covered line


                           --bug 2543687
                             If p_line_tbl(i).p_yn = 'Y' and p_service_price = 'Y' and
                               p_line_tbl(i).object_code in ('OKX_COVLINE')Then
                               begin

                                 select price_list_id into  pricelist from okc_k_lines_b
                                 where id = p_line_tbl(i).id1;
                                 If pricelist is not null Then
                                      qual_rec.QUALIFIER_ATTR_VALUE_FROM := pricelist;
                                 Else
                                      qual_rec.QUALIFIER_ATTR_VALUE_FROM := to_char(p_line_tbl(i).pricelist_id);
                                 End If;
                               Exception
                                  when others then
                                     IF (l_debug = 'Y') THEN
								my_debug(' No price list in non service item');
                                     END IF;
                               End;
                            Elsif p_service_price = 'Y' and  (p_line_tbl(i).pi_yn ='Y') and p_service_price_list is not null then
                                    qual_rec.QUALIFIER_ATTR_VALUE_FROM := p_service_price_list;
                            Else
                                 qual_rec.QUALIFIER_ATTR_VALUE_FROM := to_char(p_line_tbl(i).pricelist_id);
                            End If;
--2543687



                             /** Bug 2774859: the service line may not have a price list attached to it
                                 in which case, we have already got the price list from the covered line
                                 which we need to attach to the service line  **/
                             If  ( qual_rec.QUALIFIER_ATTR_VALUE_FROM is not null ) and
                                 ( qual_rec.QUALIFIER_ATTR_VALUE_FROM <> OKC_API.G_MISS_CHAR) then

                                 qual_rec.LINE_INDEX := p_line_index;
                                 qual_rec.QUALIFIER_CONTEXT :='MODLIST';
                                 qual_rec.QUALIFIER_ATTRIBUTE :='QUALIFIER_ATTRIBUTE4';


                                 qual_rec.COMPARISON_OPERATOR_CODE := '=';
                                 --qual_rec.VALIDATED_FLAG :='Y';
                                 qual_rec.VALIDATED_FLAG :='N'; --Bug 2760904: we need QP to validate the price list

                                 x_qualifier_contexts_Tbl(nvl(x_qualifier_contexts_Tbl.last,0)+1):= qual_rec;
                            End If;


                            /********
                            qual_rec.COMPARISON_OPERATOR_CODE := '=';
                            --qual_rec.VALIDATED_FLAG :='Y';
                            qual_rec.VALIDATED_FLAG :='N'; --Bug 2760904: we need QP to validate the price list

                            x_qualifier_contexts_Tbl(nvl(x_qualifier_contexts_Tbl.last,0)+1):= qual_rec;
                            ***********/

                       END IF;
                      --assign pricing_date
                       OKC_PRICE_PUB.G_CONTRACT_INFO.PRICING_DATE:=p_line_tbl(i).pricing_date;

             --If x_qualifier_contexts_tbl.count >0 then
                     IF (l_debug = 'Y') THEN
                        my_debug('11070 :Pricelist specified '||p_line_tbl(i).pricelist_id,1);
                     END IF;

                       -- put values from attached rules in global table
                      l_return_status:=attach_rules(p_chr_id,p_line_tbl(i).id);
                     -- --dbms_output.put_line('2 cle return status'||l_return_status);

                      IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                      ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
                           RAISE OKC_API.G_EXCEPTION_ERROR;
                      END IF;
                      -- put values from attached party roles in global table
                      l_return_status:=attach_party_roles(p_chr_id,p_line_tbl(i).id);
                     -- --dbms_output.put_line('3 cle return status'||l_return_status);

                      IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                      ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
                           RAISE OKC_API.G_EXCEPTION_ERROR;
                      END IF;

                      Load_User_Defined_Pattrs(p_chr_id ,
                                               p_line_index ,
                                               x_pricing_contexts_Tbl,
                                               x_qualifier_contexts_Tbl,
                                               x_return_status,
                                               p_line_tbl(i).id);
                     -- --dbms_output.put_line('4 cle return status'||x_return_status);
                      IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                      ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
                           RAISE OKC_API.G_EXCEPTION_ERROR;
                      END IF;
                      --call pricing build context
                     -- --dbms_output.put_line('5 cle return status'||x_return_status);
                      i:=p_line_tbl.next(i);
               END LOOP;--lines loop

               --attach the header level values for party roles and rules if not already there on line
               IF g_hdr_rul_tbl.count >0 then --hdr_rul if
                 i:=g_hdr_rul_tbl.first;
                 If g_hdr_rul_tbl(i).source_value=p_chr_id and
                    g_hdr_rul_tbl(i).code= 'CHR_ID' then
                    i:=g_hdr_rul_tbl.next(i);
                    while i is not null loop
                      l_prle_rec:=g_hdr_rul_tbl(i);
                           l_return_status:= add_to_global_tbl(okc_price_pub.g_rul_tbl,l_prle_rec);
                           IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                               RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                           ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
                               RAISE OKC_API.G_EXCEPTION_ERROR;
                           END IF;
                      i:=g_hdr_rul_tbl.next(i);
                    End loop;
                 end if;
               END IF; --end hdr_rul if

               IF g_hdr_prle_tbl.count >0 then --#prle if
                 i:=g_hdr_prle_tbl.first;
                 If g_hdr_prle_tbl(i).source_value=p_chr_id and
                    g_hdr_prle_tbl(i).code= 'CHR_ID' then
                    i:=g_hdr_prle_tbl.next(i);
                    while i is not null loop
                      l_prle_rec:=g_hdr_prle_tbl(i);
                           l_return_status:= add_to_global_tbl(okc_price_pub.g_prle_tbl,l_prle_rec);
                           IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                               RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                           ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
                               RAISE OKC_API.G_EXCEPTION_ERROR;
                           END IF;
                      i:=g_hdr_prle_tbl.next(i);
                    End loop;
                 end if;
               END IF; --#hdr prle if

               Begin
                         /* --dbms_output.put_line('okc_price_pub.g_lse_tbl');
                          k:=okc_price_pub.g_lse_tbl.first;
                          while k is not null loop

                                --dbms_output.put_line('okc_price_pub.g_lse_tbl'||k||'-'||okc_price_pub.g_lse_tbl(k).current_source);
                                --dbms_output.put_line('okc_price_pub.g_lse_tbl'||k||'-'||okc_price_pub.g_lse_tbl(k).source_value);
                                k:=okc_price_pub.g_lse_tbl.next(k);
                          END LOOP;

                          --dbms_output.put_line('okc_price_pub.g_rul_tbl');
                          k:=okc_price_pub.g_rul_tbl.first;
                          while k is not null loop
                                --dbms_output.put_line('okc_price_pub.g_rul_tbl'||k||'-'||okc_price_pub.g_rul_tbl(k).code);
                                --dbms_output.put_line('okc_price_pub.g_rul_tbl'||k||'-'||okc_price_pub.g_rul_tbl(k).current_source);
                                --dbms_output.put_line('okc_price_pub.g_rul_tbl'||k||'-'||okc_price_pub.g_rul_tbl(k).source_value);
                                k:=okc_price_pub.g_rul_tbl.next(k);
                          END LOOP;
                          --dbms_output.put_line('okc_price_pub.g_prle_tbl');
                          k:=okc_price_pub.g_prle_tbl.first;

                          while k is not null loop
                              -- --dbms_output.put_line('okc_price_pub.g_prle_tbl'||k||'-'||okc_price_pub.g_prle_tbl(k).code);
                              -- --dbms_output.put_line('okc_price_pub.g_prle_tbl'||k||'-'||okc_price_pub.g_prle_tbl(k).current_source);
                              -- --dbms_output.put_line('okc_price_pub.g_prle_tbl'||k||'-'||okc_price_pub.g_prle_tbl(k).source_value);
                               k:=okc_price_pub.g_prle_tbl.next(k);
                          END LOOP;*/

                        -- populate global record g_contract_info
                       If OKC_PRICE_PUB.G_CONTRACT_INFO.INV_ORG_ID is null then

                           Begin
                             select INV_ORGANIZATION_ID
                             into OKC_PRICE_PUB.G_CONTRACT_INFO.INV_ORG_ID
                             from okc_k_headers_b
                             where id = p_chr_id;
                             IF (l_debug = 'Y') THEN
                                my_debug('11290 : rowcount'||SQL%ROWCOUNT, 1);
                             END IF;

                            EXCEPTION
                               when no_data_found then
                                IF (l_debug = 'Y') THEN
                                   my_debug('11300 : NO authoring org id found', 1);
                                END IF;
                            END;
                        END IF; --  If OKC_PRICE_PUB.G_CONTRACT_INFO.INV_ORG_ID is null

                        --OKC_PRICE_PUB.G_CONTRACT_INFO.PRICING_DATE:=SYSDATE;
                        --populate global variable sold_to_org_id. made it global as it is used
                        --OKC_PRICE_PUB.G_CONTRACT_INFO.PRICING_DATE:=p_line_tbl(i).pricing_date;
                        -- at many places for build context functions
                        If OKC_PRICE_PUB.G_RUL_TBL.count > 0 then
                            OKC_PRICE_PUB.G_CONTRACT_INFO.SOLD_TO_ORG_ID :=
                                   GET_RUL_SOURCE_VALUE(OKC_PRICE_PUB.G_RUL_TBL,'CAN','OKX_CUSTACCT');
                        END IF;
                        IF (l_debug = 'Y') THEN
                           my_debug('11310 : G_CONTRACT_INFO.PRICING_DATE for line '||OKC_PRICE_PUB.G_CONTRACT_INFO.PRICING_DATE,1);
                           my_debug('11320: G_CONTRACT_INFO.INV_ORG_ID fo line'||OKC_PRICE_PUB.G_CONTRACT_INFO.INV_ORG_ID, 1);
                           my_debug('11330: G_CONTRACT_INFO.SOLD_TO_ORG_ID for line'||OKC_PRICE_PUB.G_CONTRACT_INFO.SOLD_TO_ORG_ID, 1);
                           my_debug('11340 : G_CONTRACT_INFO.Inventory id for line'||OKC_PRICE_PUB.G_CONTRACT_INFO.INVENTORY_ITEM_ID, 1);
                           my_debug('11350 : G_CONTRACT_INFO.top_model_line for line'||OKC_PRICE_PUB.G_CONTRACT_INFO.TOP_MODEL_LINE_ID, 1);
                        END IF;


                        IF (l_debug = 'Y') THEN
                           my_debug('11400 : Before Calling Build context request type'||p_request_type_code, 1);
                        END IF;

                        QP_Attr_Mapping_PUB.Build_Contexts(p_request_type_code => p_request_type_code,
			                                                 p_pricing_type	=>	p_pricing_type,
			                                                 x_price_contexts_result_tbl => l_pricing_contexts_Tbl,
                                                           x_qual_contexts_result_tbl  => l_qualifier_Contexts_Tbl);


                        IF (l_debug = 'Y') THEN
                           my_debug('11402 : After Calling Build context request type', 1);
                        END IF;

                        okc_price_pub.g_rul_tbl.DELETE;
                        okc_price_pub.g_prle_tbl.DELETE;
                        okc_price_pub.g_lse_tbl.DELETE;
                        OKC_PRICE_PUB.G_CONTRACT_INFO.inventory_item_id:=null;

                   Exception
                      When Others then
                        --dbms_output.put_line('error'||substr(sqlerrm,1,240));
                        OKC_API.set_message(p_app_name      => g_app_name,
                                      p_msg_name      => 'OKC_QP_INT_ERROR',
                                      p_token1        => 'Proc',
                                      p_token1_value  => 'Build_Context for LINE',
                                      p_token2        => 'SQLCODE',
                                      p_token2_value  => SQLCODE,
                                      p_token3        => 'Err_TEXT',
                                      p_token3_value  => SQLERRM);
                        IF (l_debug = 'Y') THEN
                           my_debug('11450 : QP Build Context Error Exiting BUILD_CLE_CONTEXT', 2);
                        END IF;
                        Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;

               End; --call pricing build context
               -- copy build context attribs to request table
              -- --dbms_output.put_line('6 cle return status'||x_return_status);
              IF (l_debug = 'Y') THEN
                 my_debug('11596 : before copy attrib count '||x_qualifier_contexts_Tbl.count, 1);
              END IF;

               copy_attribs_to_Req(
                           p_line_index
                          ,l_pricing_contexts_Tbl
                          ,l_qualifier_contexts_Tbl
                          ,x_pricing_contexts_Tbl
                          ,x_qualifier_contexts_Tbl
                        );
            END IF;--p_line_tbl.count
            IF (l_debug = 'Y') THEN
               my_debug('11598 : after copy attrib count '||x_qualifier_contexts_Tbl.count, 1);
            END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       my_debug('11600 : Exiting BUILD_CLE_CONTEXT', 2);
    END IF;
    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;
    EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
              x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                       'OKC_API.G_RET_STS_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');
               IF (l_debug = 'Y') THEN
                  my_debug('11700 : Exiting BUILD_CLE_CONTEXT', 4);
               END IF;
               IF (l_debug = 'Y') THEN
                  okc_debug.Reset_Indentation;
               END IF;

         WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
              x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                       'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');
           IF (l_debug = 'Y') THEN
              my_debug('11800 : Exiting BUILD_CLE_CONTEXT', 4);
           END IF;
           IF (l_debug = 'Y') THEN
              okc_debug.Reset_Indentation;
           END IF;

         WHEN OTHERS THEN
              OKC_API.set_message(p_app_name      => g_app_name,
                                 p_msg_name      => g_unexpected_error,
                                 p_token1        => g_sqlcode_token,
                                 p_token1_value  => sqlcode,
                                 p_token2        => g_sqlerrm_token,
                                 p_token2_value  => sqlerrm);
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
           IF (l_debug = 'Y') THEN
              my_debug('11900 : Exiting BUILD_CLE_CONTEXT', 4);
           END IF;
           IF (l_debug = 'Y') THEN
              okc_debug.Reset_Indentation;
           END IF;

END BUILD_CLE_CONTEXT;

----------------------------------------------------------------------------
-- CREATE_REQUEST_LINE
-- This procedure creates a request line for the sent in line recs
----------------------------------------------------------------------------
PROCEDURE Create_request_line( p_api_version           IN            NUMBER,
                               p_init_msg_list         IN            VARCHAR2,
                               p_control_rec           IN            OKC_CONTROL_REC_TYPE,
                               p_chr_id                IN            NUMBER,
                               p_line_tbl              IN            line_tbl_type,
                               p_pi_ind                IN            NUMBER ,
                               p_bpi_ind               IN            NUMBER ,
                               p_pricing_event         IN            varchar2 ,
                               p_hdr_prc_contexts_Tbl  IN            QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
                               p_hdr_qual_contexts_Tbl IN            QP_PREQ_GRP.QUAL_TBL_TYPE,
                               px_req_line_tbl         IN OUT NOCOPY        QP_PREQ_GRP.LINE_TBL_TYPE ,
                               px_Req_related_lines_tbl  IN OUT NOCOPY      QP_PREQ_GRP.RELATED_LINES_TBL_TYPE,
                               x_pricing_contexts_Tbl     OUT NOCOPY QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
                               x_qualifier_contexts_Tbl   OUT NOCOPY QP_PREQ_GRP.QUAL_TBL_TYPE,
                               x_return_status            OUT NOCOPY        varchar2,
                               x_msg_count                OUT NOCOPY        NUMBER,
                               x_msg_data                 OUT NOCOPY        VARCHAR2) IS

     l_return_status           varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_related_lines_Index     pls_integer :=0;
     l_bpi_ind                 number := p_bpi_ind;
     l_line_index	           pls_integer := nvl(px_req_line_tbl.count,0);
     l_line_tbl                line_tbl_type := p_line_tbl;
     l_num_loops               number :=2;
BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('Create_request_line');
    END IF;
    IF (l_debug = 'Y') THEN
       my_debug('12000 : Entering Create_request_line', 2);
    END IF;

     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     -- create request line for a given line. The p_line_tbl here has the list of lines
     -- in the same heirarchy. One of these lines should hold Priced flag and one should have
     -- item_to_price_flag. If there is a relationship between two lines the index of that
     -- line would be stored in bpi_ind. The relationship right now defaults to SERVICE
     IF (l_debug = 'Y') THEN
        my_debug('12010 : l_line_tbl line count'||l_line_tbl.count, 1);
        my_debug('12015 : BPI index'||l_bpi_ind, 1);
     END IF;
     IF l_line_tbl.count>0 then

       Loop -- This loop should be running maximum twice- first time it runs for pi
       -- and second time it runs for bpi if bpi_ind is >0
           l_num_loops := l_num_loops -1;
           IF (l_debug = 'Y') THEN
              my_debug('12020 : l_num_loops'||l_num_loops, 1);
           END IF;

           l_line_index := l_line_index+1;
           IF (l_debug = 'Y') THEN
              my_debug('12021 : line index'||l_line_index, 1);
           END IF;

           -- here for recognition of which req line belongs to which priced line
           -- populate line id for pi request line with the id of 'P' as we are
           -- interested in the price of 'P'. IF there is a related line as well
           -- Then in that request line's line id we will put the id of
           -- line holding BPI.
           If l_num_loops =0  and l_bpi_ind >0 then -- that means bpi is there and populating bpi right now
      	       px_req_line_tbl(l_line_index).Line_id := l_line_tbl(l_bpi_ind).id;--???? for bpi
               IF (l_debug = 'Y') THEN
                  my_debug('12030 :If bpi then bpi line id'||l_line_tbl(l_bpi_ind).id, 1);
               END IF;

           ELSE
           	   px_req_line_tbl(l_line_index).Line_id := l_line_tbl(1).id;--???? assuming p is the first rec
               --??? assumming bpi cannot be at the same level as p. This would change soon based on OKO requirements
               l_line_tbl.delete(l_bpi_ind);
               IF (l_debug = 'Y') THEN
                  my_debug('12035 : deleted BPI entry-'||l_bpi_ind, 1);
               END IF;

               IF (l_debug = 'Y') THEN
                  my_debug('12040 :If not BPI then priced line id'|| l_line_tbl(1).id, 1);
               END IF;

           END IF;
	       px_req_line_tbl(l_line_index).REQUEST_TYPE_CODE := p_control_rec.p_Request_Type_Code;
	       px_req_line_tbl(l_line_index).LINE_INDEX     := l_line_index;
	       px_req_line_tbl(l_line_index).LINE_TYPE_CODE  := 'LINE';
		  --To honour pricing date
           px_req_line_tbl(l_line_index).PRICING_EFFECTIVE_DATE := l_line_tbl(1).pricing_date;
           --px_req_line_tbl(l_line_index).PRICING_EFFECTIVE_DATE := trunc(sysdate);--???? is sysdate fine?
   	       px_req_line_tbl(l_line_index).LINE_QUANTITY   := l_Line_tbl(1).qty ;
           IF (l_debug = 'Y') THEN
              my_debug('12050 :negotiated price overriden or not flag'|| p_control_rec.p_negotiated_changed, 1);
           END IF;
           If p_control_rec.p_negotiated_changed = 'Y' then
   	           px_req_line_tbl(l_line_index).UPDATED_ADJUSTED_UNIT_PRICE:= l_line_tbl(1).updated_price;
           END IF;
   	     --  px_req_line_tbl(l_line_index).ADJUSTED_UNIT_PRICE:= l_line_tbl(1).unit_price;

          px_req_line_tbl(l_line_index).LINE_UOM_CODE   := l_Line_tbl(1).uom_code;
          --????do we need to send whatever info about adjustements on line is alredy there
	      px_req_line_tbl(l_line_index).CURRENCY_CODE := l_Line_tbl(1).currency;
          px_req_line_tbl(l_line_index).PRICE_FLAG := 'Y';

           --??? donno if relevant in our case
     /*
     -- uom begin
	If p_Line_rec.unit_list_price_per_pqty <> FND_API.G_MISS_NUM Then
		px_req_line_tbl(l_line_index).UNIT_PRICE := p_Line_rec.unit_list_price_per_pqty;
	Else
		 px_req_line_tbl(l_line_index).UNIT_PRICE := Null;
	End If;
        -- uom end
	px_req_line_tbl(l_line_index).PERCENT_PRICE := p_Line_rec.unit_list_percent;

        If (p_Line_rec.service_period = p_Line_rec.Order_quantity_uom) Then
  	  px_req_line_tbl(l_line_index).UOM_QUANTITY := p_Line_rec.service_duration;
        Else
          INV_CONVERT.INV_UM_CONVERSION(From_Unit => p_Line_rec.service_period
                                       ,To_Unit   => p_Line_rec.Order_quantity_uom
                                       ,Item_ID   => p_Line_rec.Inventory_item_id
                                       ,Uom_Rate  => l_Uom_rate);
          px_req_line_tbl(l_line_index).UOM_QUANTITY := p_Line_rec.service_duration * l_uom_rate;
        End If;
     */
           --???? do we want to give discounts on configured items through this?
           --dbms_output.put_line('here comes calc flag'||p_control_rec.p_calc_flag||l_line_tbl.count );
           If p_control_rec.p_calc_flag <> 'C' then
              IF (l_debug = 'Y') THEN
                 my_debug('12060 :Before calling Build _cle_context attrib count'||x_pricing_contexts_Tbl.count, 1);
              END IF;

           --build context for the line
              BUILD_CLE_CONTEXT(
                p_api_version             => p_api_version,
                p_init_msg_list           => p_init_msg_list,
                p_request_type_code       => p_control_rec.p_Request_Type_Code,
                p_chr_id                  => p_chr_id,
                P_line_tbl                => l_line_tbl,
                p_line_index              => l_line_index,
                x_pricing_contexts_Tbl    => x_pricing_contexts_Tbl,
                x_qualifier_contexts_Tbl  => x_qualifier_contexts_Tbl,
                x_return_status           => l_return_status,
                x_msg_count               => x_msg_count,
                x_msg_data                => x_msg_data);
              IF (l_debug = 'Y') THEN
                 my_debug('12062 :After calling Build _cle_context return status '||l_return_status, 1);
              END IF;

              IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
                   RAISE OKC_API.G_EXCEPTION_ERROR;
              END IF;
              --attach header attribs

               If (p_hdr_prc_contexts_Tbl.count >0 or p_hdr_qual_contexts_Tbl.count>0) then
                       IF (l_debug = 'Y') THEN
                          my_debug('12063 :header priceing attrib '||p_hdr_prc_contexts_Tbl.count, 1);
                          my_debug('12064 :header qual attrib '||p_hdr_qual_contexts_Tbl.count, 1);
                       END IF;

                copy_attribs(
                     l_line_index
                    ,'Y'
                    ,p_hdr_prc_contexts_Tbl
                    ,p_hdr_qual_contexts_Tbl
                    ,x_pricing_contexts_Tbl
                    ,x_qualifier_contexts_Tbl);
              END IF;
           End If; -- p_calc_flag
         IF l_num_loops >0 and l_bpi_ind > 0 then
             IF (l_debug = 'Y') THEN
                my_debug('12070 :l_bpi_ind is greater than 0 '||l_bpi_ind, 1);
             END IF;

              l_line_tbl := p_line_tbl;
              IF (l_debug = 'Y') THEN
                 my_debug('12072 :l_line_tbl reassigned from p_line_tbl ', 1);
                 my_debug('12074 :item_to_price_ind '||p_pi_ind, 1);
              END IF;

                IF p_pi_ind > 1 then -- that means P is not same level as PI
                    l_line_tbl.delete(p_pi_ind);
                ELSE -- that means p and pi at same level
                    -- make sure pi flag is not set on priced line. as we plan to pick the
                    -- item from bpi flag
                    l_line_tbl(1).pi_yn:='B';--B means it was both- P as well as PI
                END IF;
                -- Populate the Relationship this we are doing before defining the 2nd request line
	            l_related_lines_Index	:= px_Req_related_lines_tbl.count+1;
	            px_Req_related_lines_tbl(l_related_lines_Index).Line_Index := l_line_index;
	            px_Req_related_lines_tbl(l_related_lines_Index).Related_Line_Index := l_line_index+1;
                -- Right now hardcoding relationship to service
	            px_Req_related_lines_tbl(l_related_lines_Index).Relationship_Type_Code:= QP_PREQ_GRP.G_SERVICE_LINE;
                -- make p_bpi_ind=0 to exit the loop next time around
                --l_bpi_ind :=0;
         ELSE
               l_num_loops:=0;
         END IF;--l_bpi_ind>0
         EXIT WHEN l_num_loops =0;
      END LOOP;
    END IF; -- l_line_tbl.count
    IF (l_debug = 'Y') THEN
       my_debug('12800 : Exiting Create_request_line', 2);
    END IF;
    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
      when others then
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    IF (l_debug = 'Y') THEN
       my_debug('12900 : Exiting Create_request_line', 4);
    END IF;
    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;

END CREATE_REQUEST_LINE;

----------------------------------------------------------------------------
-- CREATE_REQUEST_LINE_SERVICE
-- This procedure creates 2 request line for the sent in line recs
-- This is used only for OKO service Lines, as we need to send to QP both the
--- Service item and the covered line/product/item
----------------------------------------------------------------------------
PROCEDURE Create_request_line_service
                              ( p_api_version           IN            NUMBER,
                               p_init_msg_list         IN            VARCHAR2,
                               p_control_rec           IN            OKC_CONTROL_REC_TYPE,
                               p_chr_id                IN            NUMBER,
                               p_line_tbl              IN            line_tbl_type,
                               p_pi_ind                IN            NUMBER ,
                               p_bpi_ind               IN            NUMBER ,
                               p_pricing_event         IN            varchar2 ,
                               p_hdr_prc_contexts_Tbl  IN            QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
                               p_hdr_qual_contexts_Tbl IN            QP_PREQ_GRP.QUAL_TBL_TYPE,
                               px_req_line_tbl         IN OUT NOCOPY        QP_PREQ_GRP.LINE_TBL_TYPE ,
                               px_Req_related_lines_tbl  IN OUT NOCOPY      QP_PREQ_GRP.RELATED_LINES_TBL_TYPE,
                               x_pricing_contexts_Tbl     OUT NOCOPY QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
                               x_qualifier_contexts_Tbl   OUT NOCOPY QP_PREQ_GRP.QUAL_TBL_TYPE,
                               x_return_status            OUT NOCOPY        varchar2,
                               x_msg_count                OUT NOCOPY        NUMBER,
                               x_msg_data                 OUT NOCOPY        VARCHAR2)  IS

     l_return_status           varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_related_lines_Index     pls_integer :=0;
     l_bpi_ind                 number := p_bpi_ind;
     l_line_index	           pls_integer := nvl(px_req_line_tbl.count,0);
     l_line_tbl                line_tbl_type := p_line_tbl;
     l_num_loops               number := 2;
     i pls_integer :=0;
     p_list_id                 VARCHAR2(30);
BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('Create_request_line_service');
    END IF;
    IF (l_debug = 'Y') THEN
       my_debug('12000 : Entering Create_request_line_service', 2);
    END IF;

     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     -- create request line for a given line. The p_line_tbl here has the list of lines
     -- in the same heirarchy. One of these lines should hold Priced flag and one should have
     -- item_to_price_flag. The price of item_to_price depends of price of priced
     --  The relationship right now defaults to SERVICE
     IF (l_debug = 'Y') THEN
        my_debug('12010 : l_line_tbl line count'||l_line_tbl.count, 1);
     END IF;
    IF l_line_tbl.count>0 then
       i := l_line_tbl.first;

       While i is not null Loop

         If i = l_line_tbl.first or i= p_pi_ind then
            l_line_index := l_line_index+1;
           IF i = l_line_tbl.first then
            -- first line contains priced line
            -- create request line for covered line/product/item with id of pi

              px_req_line_tbl(l_line_index).LINE_INDEX     := l_line_index;
              px_req_line_tbl(l_line_index).line_id        := l_line_tbl(p_pi_ind).id;
              p_list_id := NULL;
           else
            --create request line for service item with id of P

             px_req_line_tbl(l_line_index).line_id        := l_line_tbl(l_line_tbl.first).id;
             px_req_line_tbl(l_line_index).line_index     := l_line_index;
		   p_list_id := l_line_tbl(l_line_tbl.first).pricelist_id;
           end if;

	       px_req_line_tbl(l_line_index).REQUEST_TYPE_CODE := p_control_rec.p_Request_Type_Code;
	       px_req_line_tbl(l_line_index).LINE_TYPE_CODE  := 'LINE';

           -- px_req_line_tbl(l_line_index).PRICING_EFFECTIVE_DATE := trunc(sysdate);--???? is sysdate fine?
            px_req_line_tbl(l_line_index).PRICING_EFFECTIVE_DATE := l_line_tbl(1).pricing_date;
   	       px_req_line_tbl(l_line_index).LINE_QUANTITY   := l_Line_tbl(i).qty ;

           IF (l_debug = 'Y') THEN
              my_debug('12050 :negotiated price overriden or not flag'|| p_control_rec.p_negotiated_changed, 1);
           END IF;
           If p_control_rec.p_negotiated_changed = 'Y' then
   	           px_req_line_tbl(l_line_index).UPDATED_ADJUSTED_UNIT_PRICE:= l_line_tbl(i).updated_price;
           END IF;

          px_req_line_tbl(l_line_index).LINE_UOM_CODE   := l_Line_tbl(i).uom_code;
          --????do we need to send whatever info about adjustements on line is alredy there
	      px_req_line_tbl(l_line_index).CURRENCY_CODE := l_Line_tbl(i).currency;
          px_req_line_tbl(l_line_index).PRICE_FLAG := 'Y';

           --??? donno if relevant in our case
     /*
     -- uom begin
	If p_Line_rec.unit_list_price_per_pqty <> FND_API.G_MISS_NUM Then
		px_req_line_tbl(l_line_index).UNIT_PRICE := p_Line_rec.unit_list_price_per_pqty;
	Else
		 px_req_line_tbl(l_line_index).UNIT_PRICE := Null;
	End If;
        -- uom end
	px_req_line_tbl(l_line_index).PERCENT_PRICE := p_Line_rec.unit_list_percent;

        If (p_Line_rec.service_period = p_Line_rec.Order_quantity_uom) Then
  	  px_req_line_tbl(l_line_index).UOM_QUANTITY := p_Line_rec.service_duration;
        Else
          INV_CONVERT.INV_UM_CONVERSION(From_Unit => p_Line_rec.service_period
                                       ,To_Unit   => p_Line_rec.Order_quantity_uom
                                       ,Item_ID   => p_Line_rec.Inventory_item_id
                                       ,Uom_Rate  => l_Uom_rate);
          px_req_line_tbl(l_line_index).UOM_QUANTITY := p_Line_rec.service_duration * l_uom_rate;
        End If;
     */
           --???? do we want to give discounts on configured items through this?
           --dbms_output.put_line('here comes calc flag'||p_control_rec.p_calc_flag||l_line_tbl.count );
           If p_control_rec.p_calc_flag <> 'C' then
              IF (l_debug = 'Y') THEN
                 my_debug('12060 :Before calling Build _cle_context attrib count'||x_pricing_contexts_Tbl.count, 1);
              END IF;
--           Before calling build_cle_context delete record not being processed
             If i= 1 then
               l_line_tbl.delete(p_pi_ind);
             Else
               l_line_tbl.delete(l_line_tbl.first);
             end if;

           --build context for the line
              BUILD_CLE_CONTEXT(
                p_api_version             => p_api_version,
                p_init_msg_list           => p_init_msg_list,
                p_request_type_code       => p_control_rec.p_Request_Type_Code,
                p_chr_id                  => p_chr_id,
                P_line_tbl                => l_line_tbl,
                p_line_index              => l_line_index,
                p_service_price           => 'Y',
			 p_service_price_list      => p_list_id,
                x_pricing_contexts_Tbl    => x_pricing_contexts_Tbl,
                x_qualifier_contexts_Tbl  => x_qualifier_contexts_Tbl,
                x_return_status           => l_return_status,
                x_msg_count               => x_msg_count,
                x_msg_data                => x_msg_data);

                IF (l_debug = 'Y') THEN
                   my_debug('12062 :After calling Build _cle_context return status '||l_return_status, 1);
                END IF;

            --Repopulate line table
              l_line_tbl:= p_line_tbl;

              IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
                   RAISE OKC_API.G_EXCEPTION_ERROR;
              END IF;
              --attach header attribs

               If (p_hdr_prc_contexts_Tbl.count >0 or p_hdr_qual_contexts_Tbl.count>0) then
                       IF (l_debug = 'Y') THEN
                          my_debug('12063 :header priceing attrib '||p_hdr_prc_contexts_Tbl.count, 1);
                          my_debug('12064 :header qual attrib '||p_hdr_qual_contexts_Tbl.count, 1);
                       END IF;

                copy_attribs(
                     l_line_index
                    ,'Y'
                    ,p_hdr_prc_contexts_Tbl
                    ,p_hdr_qual_contexts_Tbl
                    ,x_pricing_contexts_Tbl
                    ,x_qualifier_contexts_Tbl);
              END IF;
           End If; -- p_calc_flag
           IF i = l_line_tbl.first  then
             -- Populate the Relationship this we are doing before defining the 2nd request line
	        l_related_lines_Index	:= px_Req_related_lines_tbl.count+1;
	        px_Req_related_lines_tbl(l_related_lines_Index).Line_Index := l_line_index; --index of cov line
	        px_Req_related_lines_tbl(l_related_lines_Index).Related_Line_Index := l_line_index+1; -- index of  service item
            -- Right now hardcoding relationship to service
	        px_Req_related_lines_tbl(l_related_lines_Index).Relationship_Type_Code:= QP_PREQ_GRP.G_SERVICE_LINE;
           end if;
        end if; --If for pi/p
        i := l_line_tbl.next(i);

      END LOOP;
    END IF; -- l_line_tbl.count
    IF (l_debug = 'Y') THEN
       my_debug('12800 : Exiting Create_request_line_service', 2);
    END IF;
    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
      when others then
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    IF (l_debug = 'Y') THEN
       my_debug('12900 : Exiting Create_request_line', 4);
    END IF;
    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;

END CREATE_REQUEST_LINE_service;



----------------------------------------------------------------------------
-- Process_Adjustment_DETAILS
-- This procedure will check all the lines that get returned from pricing
-- and take appropriate action.
--Modified for pricing of service lines
----------------------------------------------------------------------------
PROCEDURE PROCESS_ADJUSTMENT_DETAILS(
          p_api_version               IN            NUMBER,
          p_init_msg_list             IN            VARCHAR2 DEFAULT OKC_API.G_FALSE ,
          p_CHR_ID                     IN     NUMBER,
          p_Control_Rec			    IN     OKC_CONTROL_REC_TYPE,
          p_req_line_tbl               IN     QP_PREQ_GRP.LINE_TBL_TYPE,
          p_Req_LINE_DETAIL_tbl        IN     QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
          p_Req_LINE_DETAIL_qual_tbl   IN     QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE,
          p_Req_LINE_DETAIL_attr_tbl   IN     QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE,
          p_Req_RELATED_LINE_TBL       IN     QP_PREQ_GRP.RELATED_LINES_TBL_TYPE,
          p_CLE_PRICE_tbl		    IN     CLE_PRICE_tbl_TYPE,
		p_service_qty_tbl            IN     NUM_TBL_TYPE,
          x_return_status               OUT  NOCOPY VARCHAR2,
          x_msg_count                   OUT NOCOPY NUMBER,
          x_msg_data                    OUT NOCOPY VARCHAR2) IS

       i pls_integer :=0;
       j pls_integer :=0;
       k pls_integer :=0;

       l_patv_rec          OKC_PRICE_ADJUSTMENT_PUB.patv_rec_type;
       l_patv_dummy_rec          OKC_PRICE_ADJUSTMENT_PUB.patv_rec_type;

       lx_patv_rec         OKC_PRICE_ADJUSTMENT_PUB.patv_rec_type;
       l_patv_tbl          OKC_PRICE_ADJUSTMENT_PUB.patv_tbl_type;
       l_new_pat_tbl       num_tbl_type;
      -- l_new_detail_tbl    num_tbl_type;
       l_pacv_tbl          OKC_PRICE_ADJUSTMENT_PUB.pacv_tbl_type;
       l_paav_tbl          OKC_PRICE_ADJUSTMENT_PUB.paav_tbl_type;
       lx_pacv_tbl          OKC_PRICE_ADJUSTMENT_PUB.pacv_tbl_type;
       lx_paav_tbl          OKC_PRICE_ADJUSTMENT_PUB.paav_tbl_type;

        TYPE CHAR_TBL_TYPE is TABLE of varchar2(240) INDEX BY BINARY_INTEGER;


       TYPE Price_break_rec is RECORD (
		   Line_detail_index NUMBER,
		   Pat_id   NUMBER,
		   CLE_ID  NUMBER,
		   CHR_ID NUMBER,
		   list_line_type_code VARCHAR2(30) );

       TYPE PRICE_BREAK_TBL IS TABLE OF Price_break_rec INDEX BY   BINARY_INTEGER;

       l_price_break_tbl price_break_tbl;
       l_id_tbl            num_tbl_type;
       l_pat_id_tbl       NUM_TBL_TYPE;
       l_line_no_tbl      CHAR_TBL_TYPE;
       l_list_hdr_tbl     NUM_TBL_TYPE;
       l_obj_tbl          NUM_TBL_TYPE;

       l_id_tmp_tbl       NUM_TBL_TYPE;
       l_pat_tmp_tbl      NUM_TBL_TYPE;
       l_line_tmp_tbl     CHAR_TBL_TYPE;
       l_list_tmp_tbl     NUM_TBL_TYPE;
       l_obj_tmp_tbl      NUM_TBL_TYPE;

      l_id number :=0;

      l_found boolean :=false;
      p_qty number;

      lx_serviced_rec_yn               VARCHAR2(1);
      lx_process_child_yn               VARCHAR2(1);


   FUNCTION clean_adj_assocs(p_id_tbl num_tbl_type) RETURN varchar2 IS
    l_return_status varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
    k pls_integer :=0;
    l pls_integer :=0;
    j pls_integer :=0;

    l_id_tbl  num_tbl_type;
   BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('clean_adj_assocs');
    END IF;
    IF (l_debug = 'Y') THEN
       my_debug('13300 : Entering clean_adj_assocs', 2);
    END IF;

     k:=p_id_tbl.first;
     while k is not null loop
           select id
           bulk collect into l_id_tbl
           from okc_price_adj_assocs
           where pat_id = p_id_tbl(k) or pat_id_from = p_id_tbl(k);
           IF (l_debug = 'Y') THEN
              my_debug('13310 : select rowcount'||SQL%ROWCOUNT, 1);
           END IF;

           l:=l_id_tbl.first;
           while l is not null loop
              j:=j+1;
              l_pacv_tbl(j).id:=l_id_tbl(l);
             l:=l_id_tbl.next(l);
           end loop;
           k:=p_id_tbl.next(k);
     end loop;
     OKC_PRICE_ADJUSTMENT_PUB.delete_price_adj_assoc(
       p_api_version      => p_api_version,
       x_return_status    => l_return_status ,
       x_msg_count        => x_msg_count,
       x_msg_data         => x_msg_data,
       p_pacv_tbl         => l_pacv_tbl);
      l_pacv_tbl.delete;
    IF (l_debug = 'Y') THEN
       my_debug('13400 : Exiting clean_adj_assocs', 2);
    END IF;
    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;

     return (l_return_status);
 EXCEPTION
  when others then
   OKC_API.set_message(p_app_name      => g_app_name,
                       p_msg_name      => g_unexpected_error,
                       p_token1        => g_sqlcode_token,
                       p_token1_value  => sqlcode,
                       p_token2        => g_sqlerrm_token,
                       p_token2_value  => sqlerrm);
   l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    IF (l_debug = 'Y') THEN
       my_debug('13500 : Exiting clean_adj_assocs', 4);
    END IF;
    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;

   return (l_return_status);

 END clean_adj_assocs;
 FUNCTION clean_adj_attrib(p_id_tbl num_tbl_type) RETURN varchar2 IS
    l_return_status varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
    k pls_integer :=0;
    l pls_integer :=0;
    j pls_integer :=0;

    l_id_tbl  num_tbl_type;
   BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('clean_adj_attrib');
    END IF;
    IF (l_debug = 'Y') THEN
       my_debug('13600 : Entering clean_adj_attrib', 2);
    END IF;

     k:=p_id_tbl.first;
     while k is not null loop
           select id
           bulk collect into l_id_tbl
           from okc_price_adj_attribs
           where pat_id = p_id_tbl(k);
            IF (l_debug = 'Y') THEN
               my_debug('13610 : select rowcount'||SQL%ROWCOUNT, 1);
            END IF;

           l:=l_id_tbl.first;
           while l is not null loop
              j:=j+1;
              l_paav_tbl(j).id:=l_id_tbl(l);
             l:=l_id_tbl.next(l);
           end loop;
           k:=p_id_tbl.next(k);
     end loop;
     OKC_PRICE_ADJUSTMENT_PUB.delete_price_adj_attrib(
       p_api_version      => p_api_version,
       x_return_status    => l_return_status ,
       x_msg_count        => x_msg_count,
       x_msg_data         => x_msg_data,
       p_paav_tbl         => l_paav_tbl);
       l_paav_tbl.delete;
    IF (l_debug = 'Y') THEN
       my_debug('13700 : Exiting clean_adj_attrib', 2);
    END IF;
    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;

     return (l_return_status);
 EXCEPTION
  when others then
   OKC_API.set_message(p_app_name      => g_app_name,
                       p_msg_name      => g_unexpected_error,
                       p_token1        => g_sqlcode_token,
                       p_token1_value  => sqlcode,
                       p_token2        => g_sqlerrm_token,
                       p_token2_value  => sqlerrm);
   l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
   IF (l_debug = 'Y') THEN
      my_debug('13800 : Exiting clean_adj_attrib', 4);
   END IF;
   IF (l_debug = 'Y') THEN
      okc_debug.Reset_Indentation;
   END IF;

   return (l_return_status);

 END clean_adj_attrib;

 FUNCTION create_adj_attrib RETURN varchar2 IS
    l_return_status varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
    k pls_integer :=0;
    l pls_integer :=0;
    j pls_integer :=0;
    l_is_there boolean :=false;
   BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('create_adj_attrib');
    END IF;
    IF (l_debug = 'Y') THEN
       my_debug('14000 : Entering create_adj_attrib', 2);
    END IF;

     k:=p_Req_LINE_DETAIL_qual_tbl.first;
     while k is not null loop
           l_is_there := false;
           l:=l_new_pat_tbl.first;
           while l is not null loop
               if p_req_line_detail_tbl(l).line_detail_index = p_Req_LINE_DETAIL_qual_tbl(k).line_detail_index then
                   l_is_there := true;
                   exit;
               end if;
            l:=l_new_pat_tbl.next(l);
           end loop;
           IF (l_debug = 'Y') THEN
              my_debug('14040 :qualpat_line detail index'||p_Req_LINE_DETAIL_qual_tbl(k).line_detail_index);
              my_debug('14050 :qualpat_ qualifier contxet'||p_Req_LINE_DETAIL_qual_tbl(k).Qualifier_Context);
              my_debug('14060 :qualpat_ qualifier attribute'||p_Req_LINE_DETAIL_qual_tbl(k).Qualifier_Attribute);
              my_debug('14070 :qualpat_idattr value'||p_Req_LINE_DETAIL_qual_tbl(k).Qualifier_Attr_Value_From);
           END IF;


           If l_is_there then
               IF (l_debug = 'Y') THEN
                  my_debug('14080 : line detail index found'||l, 1);
                  my_debug('14082 :pat_id'||l_new_pat_tbl(l));
               END IF;

               	j := j+1;
                l_paav_tbl(j).pat_id := l_new_pat_tbl(l);
	            l_paav_tbl(j).flex_title := 'QP_ATTR_DEFNS_QUALIFIER';
	            l_paav_tbl(j).pricing_context :=
				                      p_Req_LINE_DETAIL_qual_tbl(k).Qualifier_Context;
	            l_paav_tbl(j).pricing_attribute :=
				                    p_Req_LINE_DETAIL_qual_tbl(k).Qualifier_Attribute;
	            l_paav_tbl(j).pricing_attr_value_from :=
				                    p_Req_LINE_DETAIL_qual_tbl(k).Qualifier_Attr_Value_From;
            	l_paav_tbl(j).pricing_attr_value_To :=
			                    	p_Req_LINE_DETAIL_qual_tbl(k).Qualifier_Attr_Value_To;
	            l_paav_tbl(j).comparison_operator :=
				                    p_Req_LINE_DETAIL_qual_tbl(k).comparison_operator_Code;

                IF (l_debug = 'Y') THEN
                   my_debug('14082 :index'||j);
                END IF;

               IF (l_debug = 'Y') THEN
                  my_debug('14082 :pat_id'||l_paav_tbl(j).pat_id);
               END IF;

            else
                IF (l_debug = 'Y') THEN
                   my_debug('14200 : adjustment corresponding to qualifier not saved');
                END IF;
              null;
           End If;

           k:=p_Req_LINE_DETAIL_qual_tbl.next(k);
     end loop;

     k:=p_Req_LINE_DETAIL_attr_tbl.first;
     while k is not null loop
           l_is_there := false;
           l:=l_new_pat_tbl.first;
           while l is not null loop
               if p_req_line_detail_tbl(l).line_detail_index = p_Req_LINE_DETAIL_attr_tbl(k).line_detail_index then
                   l_is_there := true;
                   exit;
               end if;
            l:=l_new_pat_tbl.next(l);
           end loop;
           IF (l_debug = 'Y') THEN
              my_debug('14240 :prcpat_line detail index'||p_Req_LINE_DETAIL_attr_tbl(k).line_detail_index);
              my_debug('14250 :prcpat_id1 contxet'||p_Req_LINE_DETAIL_attr_tbl(k).PRICING_Context);
              my_debug('14260 :prcpat_id1 pricing attribute'||p_Req_LINE_DETAIL_attr_tbl(k).PRICING_Attribute);
              my_debug('14270 :prcpat_idattr vale'||p_Req_LINE_DETAIL_attr_tbl(k).PRICING_Attr_Value_From);
           END IF;


           If l_is_there then
                IF (l_debug = 'Y') THEN
                   my_debug('14280 : line detail index found'||l, 1);
                   my_debug('14282 :pat_id'||l_new_pat_tbl(l));
                END IF;

               	j := j+1;
                l_paav_tbl(j).pat_id := l_new_pat_tbl(l);
	            l_paav_tbl(j).flex_title := 'QP_ATTR_DEFNS_PRICING';
	            l_paav_tbl(j).pricing_context :=
				                      p_Req_LINE_DETAIL_attr_tbl(k).PRICING_Context;
	            l_paav_tbl(j).pricing_attribute :=
				                    p_Req_LINE_DETAIL_attr_tbl(k).PRICING_Attribute;
	            l_paav_tbl(j).pricing_attr_value_from :=
				                    p_Req_LINE_DETAIL_attr_tbl(k).PRICING_Attr_Value_From;
            	l_paav_tbl(j).pricing_attr_value_To :=
			                    	p_Req_LINE_DETAIL_attr_tbl(k).PRICING_Attr_Value_To;

            else

                IF (l_debug = 'Y') THEN
                   my_debug('14300 : adjustment corresponding to pricing attribute not saved');
                END IF;
                null;
           End If;

           k:=p_Req_LINE_DETAIL_attr_tbl.next(k);
     end loop;
    IF (l_debug = 'Y') THEN
       my_debug('14350 : before calling OKC_PRICE_ADJUSTMENT_PUB.create_price_adj_attrib count '||l_paav_tbl.count, 1);
    END IF;
    If l_paav_tbl.count >0 then
        OKC_PRICE_ADJUSTMENT_PUB.create_price_adj_attrib(
        --OKC_PAA_PVT.INSERT_ROW(
          p_api_version      => p_api_version,
          x_return_status    => l_return_status ,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data,
          p_paav_tbl         => l_paav_tbl,
          x_paav_tbl         => lx_paav_tbl);
    IF (l_debug = 'Y') THEN
       my_debug('14352 : after calling OKC_PRICE_ADJUSTMENT_PUB.create_price_adj_attrib '||l_return_status, 1);
    END IF;

       l_paav_tbl.delete;
    End if; --l_paav_tbl.count
    IF (l_debug = 'Y') THEN
       my_debug('14500 : Exiting create_adj_attrib', 2);
    END IF;
    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;

     return l_return_status;
 EXCEPTION
  when others then
   OKC_API.set_message(p_app_name      => g_app_name,
                       p_msg_name      => g_unexpected_error,
                       p_token1        => g_sqlcode_token,
                       p_token1_value  => sqlcode,
                       p_token2        => g_sqlerrm_token,
                       p_token2_value  => sqlerrm);
   l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    IF (l_debug = 'Y') THEN
       my_debug('14600 : Exiting create_adj_attrib', 4);
    END IF;
    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;

   return (l_return_status);

 END create_adj_attrib;
 -------------------------------------------------------------------------
-- LOAD_ADJ_LINES
-------------------------------------------------------------------------
PROCEDURE LOAD_ADJ_LINES(
     p_Req_LINE_DETAIL_rec        IN     QP_PREQ_GRP.LINE_DETAIL_REC_TYPE,
     p_opr                         IN    varchar2 DEFAULT 'I' ,
	p_service_qty                 IN NUMBER DEFAULT 1,
     p_adj_id                      IN    NUMBER default 0,
     p_obj                         IN    NUMBER default 1,
     px_patv_rec                   IN OUT NOCOPY OKC_PRICE_ADJUSTMENT_PUB.patv_rec_type
) IS
Begin
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('LOAD_ADJ_LINES');
    END IF;
    IF (l_debug = 'Y') THEN
       my_debug('13000 : Entering LOAD_ADJ_LINES', 2);
    END IF;

  If p_opr = 'U' then
     px_patv_rec.ID                      := p_adj_id;
     px_patv_rec.object_version_number   := p_obj;
  End If;
  --dbms_output.put_line('load adjs'||p_Req_LINE_DETAIL_rec.line_detail_id);
  --px_patv_rec.CLE_ID                            := p_Req_LINE_DETAIL_rec.line_detail_id; --????? check if this is populated
  px_patv_rec.ACCRUAL_CONVERSION_RATE           := p_Req_LINE_DETAIL_rec.accrual_conversion_rate;
  px_patv_rec.ACCRUAL_FLAG                      := p_Req_LINE_DETAIL_rec.accrual_flag;
  px_patv_rec.ADJUSTED_AMOUNT                   := p_Req_LINE_DETAIL_rec.adjustment_amount*p_service_qty;
  px_patv_rec.APPLIED_FLAG                      := p_Req_LINE_DETAIL_rec.applied_flag;
  px_patv_rec.ARITHMETIC_OPERATOR               := p_Req_LINE_DETAIL_rec.operand_calculation_code;
  px_patv_rec.AUTOMATIC_FLAG                    := p_Req_LINE_DETAIL_rec.automatic_flag;
  px_patv_rec.BENEFIT_QTY                       := p_Req_LINE_DETAIL_rec.benefit_qty;
  px_patv_rec.BENEFIT_UOM_CODE                  := p_Req_LINE_DETAIL_rec.benefit_uom_code;
  px_patv_rec.CHARGE_SUBTYPE_CODE               := p_Req_LINE_DETAIL_rec.charge_subtype_code;
  px_patv_rec.CHARGE_TYPE_CODE                  := p_Req_LINE_DETAIL_rec.charge_type_code;
  px_patv_rec.EXPIRATION_DATE                   := p_Req_LINE_DETAIL_rec.expiration_date;
  px_patv_rec.INCLUDE_ON_RETURNS_FLAG           := p_Req_LINE_DETAIL_rec.include_on_returns_flag;
  px_patv_rec.LIST_HEADER_ID                    := p_Req_LINE_DETAIL_rec.list_header_id;
  px_patv_rec.LIST_LINE_ID                      := p_Req_LINE_DETAIL_rec.list_line_id;
  px_patv_rec.LIST_LINE_NO                      := p_Req_LINE_DETAIL_rec.list_line_no;
  px_patv_rec.LIST_LINE_TYPE_CODE               := p_Req_LINE_DETAIL_rec.list_line_type_code;
  px_patv_rec.MODIFIER_LEVEL_CODE               := p_Req_LINE_DETAIL_rec.modifier_level_code;
  px_patv_rec.MODIFIER_MECHANISM_TYPE_CODE      := p_Req_LINE_DETAIL_rec.created_from_list_type_code;
  px_patv_rec.OPERAND                           := p_Req_LINE_DETAIL_rec.operand_value;
  px_patv_rec.PRICE_BREAK_TYPE_CODE             := p_Req_LINE_DETAIL_rec.price_break_type_code;
  px_patv_rec.PRICING_GROUP_SEQUENCE            := p_Req_LINE_DETAIL_rec.pricing_group_sequence;
  px_patv_rec.PRICING_PHASE_ID                  := p_Req_LINE_DETAIL_rec.pricing_phase_id;
  px_patv_rec.PRORATION_TYPE_CODE               := p_Req_LINE_DETAIL_rec.proration_type_code;
  px_patv_rec.REBATE_TRANSACTION_TYPE_CODE      := p_Req_LINE_DETAIL_rec.rebate_transaction_type_code;
  px_patv_rec.RANGE_BREAK_QUANTITY              := p_Req_LINE_DETAIL_rec.line_quantity;
  px_patv_rec.SOURCE_SYSTEM_CODE                := p_Req_LINE_DETAIL_rec.source_system_code;
  px_patv_rec.SUBSTITUTION_ATTRIBUTE            := p_Req_LINE_DETAIL_rec.substitution_attribute;
  px_patv_rec.UPDATE_ALLOWED                   := p_Req_LINE_DETAIL_rec.override_flag;
  px_patv_rec.UPDATED_FLAG                      := p_Req_LINE_DETAIL_rec.updated_flag;

  IF (l_debug = 'Y') THEN
     my_debug('13200 : Exiting LOAD_ADJ_LINES', 2);
  END IF;
  IF (l_debug = 'Y') THEN
     okc_debug.Reset_Indentation;
  END IF;

END LOAD_ADJ_LINES;
--Added for pricing of service lines

--tope pbh changes  comment the function out
/*
FUNCTION IS_SERVICED_REQ_LINE(   p_req_line_rec                IN     QP_PREQ_GRP.LINE_rec_TYPE,
                                 p_Req_RELATED_LINE_TBL       IN     QP_PREQ_GRP.RELATED_LINES_TBL_TYPE)
                                 RETURN VARCHAR2 IS
   serviced_rec varchar2(1)  := 'N';
   i pls_integer := 0;

  BEGIN
       i := p_Req_RELATED_LINE_TBL.first;
       While i is not null loop
         If p_req_line_rec.line_index = p_req_related_line_tbl(i).line_index
          and p_Req_related_line_tbl(i).Relationship_Type_Code = QP_PREQ_GRP.G_SERVICE_LINE
         Then
           serviced_rec := 'Y';
           IF (l_debug = 'Y') THEN
              my_debug('line index '||p_req_line_rec.line_index||'No updates to id'||p_req_line_rec.line_id);
           END IF;
           exit;
         End If;
         i := p_Req_RELATED_LINE_TBL.next(i);
       End loop;
          return serviced_rec;
END IS_SERVICED_REQ_LINE;
*/

--tope pbh changes
PROCEDURE IS_SERVICED_REQ_LINE(p_req_line_rec IN     QP_PREQ_GRP.LINE_rec_TYPE,
			       detail_index                  IN NUMBER ,
			       l_serviced_rec_yn               OUT NOCOPY     VARCHAR2  ,
			       l_process_child_yn              OUT NOCOPY  VARCHAR2  )
IS
     i pls_integer         := 0;

   BEGIN
      i := p_Req_RELATED_LINE_TBL.first;
	 While i is not null loop
	    If p_req_line_rec.line_index = p_req_related_line_tbl(i).line_index
	       and p_Req_related_line_tbl(i).Relationship_Type_Code = QP_PREQ_GRP.G_SERVICE_LINE
	    Then
		  l_serviced_rec_yn := 'Y';
		  IF (l_debug = 'Y') THEN
   		  my_debug('line index '||p_req_line_rec.line_index||'No updates to id'||p_req_line_rec.line_id);
		  END IF;
		  exit;
	    End If;

	    IF p_req_related_line_tbl(i).related_line_detail_index = detail_index
	       and p_req_line_detail_tbl(detail_index).line_detail_type_code ='CHILD_DETAIL_LINE'
	   	  and p_req_line_detail_tbl(p_req_related_line_tbl(i).line_detail_index).applied_flag = 'Y'
		  and p_Req_related_line_tbl(i).Relationship_Type_Code = 'PBH_LINE'
	    Then
	       l_process_child_yn := 'Y';
		  IF (l_debug = 'Y') THEN
   		  my_debug(' process child line ');
		  END IF;
		  exit;
		End If;

		i := p_Req_RELATED_LINE_TBL.next(i);
	End loop;

END IS_SERVICED_REQ_LINE;
--tope pbh changes


BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('PROCESS_ADJUSTMENT_DETAILS');
    END IF;
    IF (l_debug = 'Y') THEN
       my_debug('14700 : Entering PROCESS_ADJUSTMENT_DETAILS', 2);
       my_debug('14702 : chr_id'||p_chr_id, 1);
    END IF;

---????The below search for pat_ids can be replaced with saving pat_ids in load_applied_adjustments
-- using a global pl/sql table but donot know how that will behave when we switch to html.
-- So check more on that and if feasible, change below for better performance
  IF (l_debug = 'Y') THEN
     my_debug('14702 : Number of lines to be processed'||p_cle_price_tbl.count, 2);
  END IF;
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  IF p_cle_price_tbl.count > 0 then
    i:=p_cle_price_tbl.first;
    IF (l_debug = 'Y') THEN
       my_debug('14704 :line Id whose adjustments are being fetched'||p_cle_price_tbl(i).id, 2);
    END IF;

    while i is not null loop
       select cle_id,id,list_line_no,list_header_id,object_version_number
       bulk collect into l_id_tmp_tbl,l_pat_tmp_tbl,l_line_tmp_tbl,l_list_tmp_tbl,l_obj_tmp_tbl
       from OKC_PRICE_ADJUSTMENTS
       where cle_id=p_cle_price_tbl(i).id and chr_id=p_chr_id;
         IF (l_debug = 'Y') THEN
            my_debug('14710 :line adjustments select rowcount'||SQL%ROWCOUNT, 1);
         END IF;

            k:= l_pat_tmp_tbl.first;
            j:= l_id_tbl.count;
            while k is not null loop
                j:=j+1;
                l_id_tbl(j):=l_id_tmp_tbl(k);
                l_pat_id_tbl(j):=l_pat_tmp_tbl(k);
                l_line_no_tbl(j) := l_line_tmp_tbl(k);
                l_list_hdr_tbl(j) := l_list_tmp_tbl(k);
                l_obj_tbl(j)    := l_obj_tmp_tbl(k);
              k:=l_pat_tmp_tbl.next(k);
            End Loop;
        i:=p_cle_price_tbl.next(i);
    End Loop;
  End If; --p_cle_price_tbl.count
  --  we always send the header line even when a line
  -- is repriced. When a line is repriced , we send header line's price_flag='N'
  --  We donot expect to get new header adjustments. Any mismacth
  -- will be caught when header is repriced again that is header line's price_flag='Y' or in QA
 If p_control_rec.p_level = 'H' and p_chr_id is not null then
 -- we donot want to touch the header adjustments if only one line is getting repriced
       select chr_id,id,list_line_no,list_header_id,object_version_number
       bulk collect into l_id_tmp_tbl,l_pat_tmp_tbl,l_line_tmp_tbl,l_list_tmp_tbl,l_obj_tmp_tbl
       from OKC_PRICE_ADJUSTMENTS
       where chr_id=p_chr_id and cle_id is null;
       IF (l_debug = 'Y') THEN
          my_debug('14750 : header adjustments select rowcount'||SQL%ROWCOUNT, 1);
       END IF;

            k:= l_pat_tmp_tbl.first;
            j:= l_id_tbl.count;
            while k is not null loop
                j:=j+1;
                l_id_tbl(j):=l_id_tmp_tbl(k);
                l_pat_id_tbl(j):=l_pat_tmp_tbl(k);
                l_line_no_tbl(j) := l_line_tmp_tbl(k);
                l_list_hdr_tbl(j) := l_list_tmp_tbl(k);
                l_obj_tbl(j)    := l_obj_tmp_tbl(k);
              k:=l_pat_tmp_tbl.next(k);
            End Loop;
  End if;

-- add the adjustments at top model dummy line Id. There could be some if the
-- line was first evaluated without configuring. These need to be deleted now
  IF (l_debug = 'Y') THEN
     my_debug('14740 :config flag'||p_control_rec.p_config_yn, 1);
     my_debug('14741 : top model line id'||p_control_rec.p_top_model_id, 1);
     my_debug('14741 : chr id'||p_chr_id, 1);
  END IF;
 If p_control_rec.p_config_yn = 'S' and p_control_rec.p_top_model_id is not null  then

       select cle_id,id,list_line_no,list_header_id,object_version_number
       bulk collect into l_id_tmp_tbl,l_pat_tmp_tbl,l_line_tmp_tbl,l_list_tmp_tbl,l_obj_tmp_tbl
       from OKC_PRICE_ADJUSTMENTS
       where cle_id=p_control_rec.p_top_model_id and chr_id=p_chr_id;
       IF (l_debug = 'Y') THEN
          my_debug('14745 : top dummy line adjustments select rowcount'||SQL%ROWCOUNT, 1);
       END IF;

            k:= l_pat_tmp_tbl.first;
            j:= l_id_tbl.count;
            while k is not null loop
                j:=j+1;
                l_id_tbl(j):=l_id_tmp_tbl(k);
                l_pat_id_tbl(j):=l_pat_tmp_tbl(k);
                l_line_no_tbl(j) := l_line_tmp_tbl(k);
                l_list_hdr_tbl(j) := l_list_tmp_tbl(k);
                l_obj_tbl(j)    := l_obj_tmp_tbl(k);
              k:=l_pat_tmp_tbl.next(k);
            End Loop;
        i:=p_cle_price_tbl.next(i);
  End if;

   x_return_status := clean_adj_assocs(l_pat_id_tbl);
   IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
          RAISE l_exception_stop;
   END IF;

   x_return_status := clean_adj_attrib(l_pat_id_tbl);
   IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
          RAISE l_exception_stop;
   END IF;

   IF (l_debug = 'Y') THEN
      my_debug('14755 :starting adjustment loop', 1);
   END IF;

   i:= p_req_line_detail_tbl.first;
   while i is not null loop --#1.1
       IF (l_debug = 'Y') THEN
          my_debug('14760 : Index of the request line detail under process '||i, 1);
          my_debug('14762 : status code '||p_req_line_tbl( p_req_line_detail_Tbl(i).line_index).status_code, 1);
          my_debug('14764 : process code '||p_req_line_tbl( p_req_line_detail_Tbl(i).line_index).processed_code, 1);
          my_debug('14766 : applied flag '||p_req_line_detail_tbl(i).applied_flag, 1);
          my_debug('14767 : created from list type code '||p_req_line_detail_Tbl(i).created_from_list_type_code, 1);
          my_debug('14768 : line OR header adjustment-'||p_req_line_tbl(p_req_line_detail_Tbl(i).line_index).line_Type_code, 1);
       END IF;


       --tope pbh changes
       IS_SERVICED_REQ_LINE(  p_req_line_tbl( p_req_line_detail_Tbl(i).line_index),
	                      i,
			      lx_serviced_rec_yn      ,
			      lx_process_child_yn    );
       --tope pbh changes



       if  p_req_line_tbl( p_req_line_detail_Tbl(i).line_index).status_code in (
				QP_PREQ_GRP.G_STATUS_UPDATED
                ,QP_PREQ_GRP.G_STATUS_GSA_VIOLATION
                ,QP_PREQ_GRP.G_STATUS_NEW
			 ,QP_PREQ_GRP.G_STATUS_UNCHANGED
                ,QP_PREQ_GRP.G_STATUS_SYSTEM_GENERATED )
			and (p_req_line_tbl(p_req_line_detail_Tbl(i).line_index).line_Type_code ='LINE'
                  and nvl(p_req_line_tbl( p_req_line_detail_Tbl(i).line_index).processed_code,'0')
			           <> QP_PREQ_GRP.G_BY_ENGINE
			  --commented out to support negative pricing
                 --   and ( p_req_line_tbl(p_req_line_detail_Tbl(i).line_index).unit_price >= 0
                 --        and p_req_line_tbl(p_req_line_detail_Tbl(i).line_index).Adjusted_unit_price >= 0))
                OR
                (p_req_line_tbl(p_req_line_detail_Tbl(i).line_index).line_Type_code ='ORDER'
                  and  p_control_rec.p_level='H'))

                --????? If we plan a UI for Price breaks, this condition might go
           -- tope pbh changes
           and ( p_req_line_detail_tbl(i).applied_flag= 'Y'
		     OR  nvl(lx_process_child_yn,'N')='Y' )
           -- do not process adjustment if request line created just for pricing service only
           --and is_serviced_req_line(p_req_line_tbl( p_req_line_detail_Tbl(i).line_index),p_req_related_line_tbl) = 'N'
		 and  nvl(lx_serviced_rec_yn,'N') = 'N'
	   then


		if p_req_line_detail_Tbl(i).created_from_list_type_code <> 'PRL' and  --#2
		   p_req_line_detail_Tbl(i).created_from_list_type_code <> 'AGR' and
		   p_req_line_detail_Tbl(i).list_line_type_code <> 'PLL' and
		   --Bug 2452258 Do not display freight charges as we donot handle them
		   p_req_line_detail_Tbl(i).list_line_type_code <> 'FREIGHT_CHARGE'
		then

          k:= l_id_tbl.first;
          l_found := false;
          IF (l_debug = 'Y') THEN
             my_debug('14772 : looking for line/header id'||p_req_line_tbl( p_req_line_detail_Tbl(i).line_index).line_id, 1);
          END IF;
         --Bug 2389314 Get qty of service line to display accurate adjustment value
          If p_service_qty_tbl.exists( p_req_line_detail_Tbl(i).line_index) Then
             p_qty :=  p_req_line_tbl( p_req_line_detail_Tbl(i).line_index).priced_quantity;
             IF (l_debug = 'Y') THEN
                my_debug('14773 : service qty'||p_qty);
             END IF;
          Elsif p_req_line_tbl( p_req_line_detail_Tbl(i).line_index).priced_quantity <> p_req_line_tbl( p_req_line_detail_Tbl(i).line_index).line_quantity Then
		    p_qty:=(p_req_line_tbl( p_req_line_detail_Tbl(i).line_index).priced_quantity/p_req_line_tbl( p_req_line_detail_Tbl(i).line_index).line_quantity);

		    IF (l_debug = 'Y') THEN
   		    my_debug('14773.1: priced qty '||p_qty);
		    END IF;
		Else
		    p_qty:=1;
          End If;

          while k is not null  loop

             If l_id_tbl(k) = p_req_line_tbl( p_req_line_detail_Tbl(i).line_index).line_id
                and p_req_line_detail_tbl(i).list_line_no = l_line_no_tbl(k) and
                  p_req_line_detail_tbl(i).list_header_id = l_list_hdr_tbl(k) then
                l_found := true;
                exit;
             END IF;
             k:=l_id_tbl.next(k);
          End loop;
          If l_found  then
              --add record for update
             IF (l_debug = 'Y') THEN
                my_debug('14774 : Update the record as found the adjustment at k '||k, 1);
             END IF;
             LOAD_ADJ_LINES(
               p_req_line_detail_tbl(i),
               'U',
               nvl(p_qty,1),
            --   l_pat_id_tbl(j),
              -- l_obj_tbl(j),
              l_pat_id_tbl(k),
              l_obj_tbl(k),
               l_patv_rec
               );
              l_pat_id_tbl.delete(k);
              l_patv_rec.chr_id :=p_chr_id;
              If p_req_line_tbl( p_req_line_detail_Tbl(i).line_index).line_id <> p_chr_id then
               l_patv_rec.cle_id :=p_req_line_tbl( p_req_line_detail_Tbl(i).line_index).line_id;
              End if;

             IF (l_debug = 'Y') THEN
                my_debug('14776 : Before calling update price adjustment '||x_return_status, 1);
             END IF;

              OKC_PRICE_ADJUSTMENT_PUB.update_price_adjustment(
                    p_api_version      => p_api_version,
                    x_return_status    => x_return_status ,
                    x_msg_count        => x_msg_count,
                    x_msg_data         => x_msg_data,
                    p_patv_rec         => l_patv_rec,
                    x_patv_rec         => lx_patv_rec );
            IF (l_debug = 'Y') THEN
               my_debug('14778 : after calling update price adjustment '||x_return_status, 1);
            END IF;

             IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                   RAISE l_exception_stop;
             END IF;


             -- store the pat_id of pbh and child_detail_lines as we are going to use get associations
		   --tope pbh changes
		   If p_req_line_detail_Tbl(i).list_line_type_code ='PBH' OR
		      p_req_line_detail_Tbl(i).line_detail_type_code = 'CHILD_DETAIL_LINE'  Then

			 l_price_break_tbl(i).pat_id := lx_patv_rec.id;
			 l_price_break_tbl(i).line_detail_index := i;
			 l_price_break_tbl(i).cle_id := p_req_line_tbl( p_req_line_detail_Tbl(i).line_index).line_id;

			 IF p_req_line_detail_Tbl(i).list_line_type_code ='PBH' Then
			    l_price_break_tbl(i).list_line_type_code :=p_req_line_detail_Tbl(i).list_line_type_code ;
			 Else
			    l_price_break_tbl(i).list_line_type_code :=p_req_line_detail_Tbl(i).line_detail_type_code ;
			 end if;
		   End if;
	     --tope pbh

           else -- if not found
             IF (l_debug = 'Y') THEN
                my_debug('14779 : Insert the record as not found the adjustment', 1);
             END IF;

               LOAD_ADJ_LINES(
               p_Req_LINE_DETAIL_rec=>p_req_line_detail_tbl(i),
               px_patv_rec=>l_patv_rec,
               p_service_qty => nvl(p_qty,1)
               );
              l_patv_rec.chr_id :=p_chr_id;
              If p_req_line_tbl( p_req_line_detail_Tbl(i).line_index).line_id <> p_chr_id then
               l_patv_rec.cle_id :=p_req_line_tbl( p_req_line_detail_Tbl(i).line_index).line_id;
              End if;


            IF (l_debug = 'Y') THEN
               my_debug('14780 : before calling create price adjustment '||x_return_status, 1);
            END IF;

                OKC_PRICE_ADJUSTMENT_PUB.create_price_adjustment(
                    p_api_version      => p_api_version,
                    x_return_status    => x_return_status ,
                    x_msg_count        => x_msg_count,
                    x_msg_data         => x_msg_data,
                    p_patv_rec         => l_patv_rec,
                    x_patv_rec         => lx_patv_rec );
            IF (l_debug = 'Y') THEN
               my_debug('14781 : after calling create price adjustment '||x_return_status, 1);
            END IF;

                IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                  RAISE l_exception_stop;
                Else
		    --tope pbh
		    -- store the pat_id of pbh and child_detail_lines as we are going to use get associations
		    If p_req_line_detail_Tbl(i).list_line_type_code ='PBH' OR
			      p_req_line_detail_Tbl(i).line_detail_type_code = 'CHILD_DETAIL_LINE'  Then

			 l_price_break_tbl(i).pat_id := lx_patv_rec.id;
			 l_price_break_tbl(i).line_detail_index := i;
			 l_price_break_tbl(i).cle_id := p_req_line_tbl( p_req_line_detail_Tbl(i).line_index).line_id;
			 IF p_req_line_detail_Tbl(i).list_line_type_code ='PBH' Then
				    l_price_break_tbl(i).list_line_type_code :=p_req_line_detail_Tbl(i).list_line_type_code ;
			 Else
				    l_price_break_tbl(i).list_line_type_code :=p_req_line_detail_Tbl(i).line_detail_type_code ;
			 end if;
		    End if;
		    --tope pbh

                END IF;

           END IF; --l_found
            IF (l_debug = 'Y') THEN
               my_debug('14782 : record added to new adjustment table at index '||i, 1);
            END IF;

           l_new_pat_tbl(i):=lx_patv_rec.id;
           l_patv_rec:=l_patv_dummy_rec;
           lx_patv_rec:=l_patv_dummy_rec;
         END IF; --#2

         --???? insert logic for inserting price break relationships if needed.
      End If;--big if
      i:= p_req_line_detail_tbl.next(i);

   end loop;--#1.1



   -- tope pbh process adjustment associations

    declare

             cursor c1(p_pat_id_from number ,p_pat_id number ,p_cle_id number)  is
		   select id from okc_price_adj_assocs_v
		   where pat_id_from = p_pat_id_from
		   and pat_id =p_pat_id
		   and cle_id = p_cle_id;

		   p_pacv_rec okc_price_adjustment_pub.pacv_rec_type;
		   x_pacv_rec okc_price_adjustment_pub.pacv_rec_type;
		   l_id number;
		   p_pat_id_from number;
		   p_pat_id number;
		   p_cle_id number;

    begin
	/* x := l_price_break_tbl.first;
	while x is not null loop
          IF (l_debug = 'Y') THEN
             my_debug('x'||x);
   	     my_debug('TOPE pat id '||l_price_break_tbl(x).pat_id );
   	     my_debug('TOPE line_index '||l_price_break_tbl(x).line_detail_index );
   	     my_debug('TOPE cle_id '||l_price_break_tbl(x).cle_id );
   	     my_debug('TOPE type_code '||l_price_break_tbl(x).list_line_type_code );
          END IF;
          x := l_price_break_tbl.next(x);
	 end loop;
	*/

	i := p_Req_RELATED_LINE_TBL.first;
	while (i is not null) and (p_Req_RELATED_LINE_TBL(i).relationship_type_code= 'PBH_LINE') LOOP
	     --id of the adjustment header
	     If l_price_break_tbl.exists(p_Req_RELATED_LINE_TBL(i).line_detail_index) Then
	        p_pat_id_from  :=  l_price_break_tbl( p_Req_RELATED_LINE_TBL(i).line_detail_index).pat_id;

             --id of the child line
		   p_pat_id       :=  l_price_break_tbl( p_Req_RELATED_LINE_TBL(i).related_line_detail_index).pat_id;

		   -- line_id
		   p_cle_id       :=  l_price_break_tbl( p_Req_RELATED_LINE_TBL(i).related_line_detail_index).cle_id;

		   open c1(p_pat_id_from,p_pat_id,p_cle_id);
		   fetch c1 into l_id;
		   close c1;

             If l_id is null Then
			 p_pacv_rec.pat_id := p_pat_id;
			 p_pacv_rec.cle_id  := p_cle_id;
			 p_pacv_rec.pat_id_from := p_pat_id_from;

                okc_price_adjustment_pub.create_price_adj_assoc(
			     p_api_version      => p_api_version,
			     x_return_status    => x_return_status ,
			     p_init_msg_list    => p_init_msg_list ,
			     x_msg_data      => x_msg_data,
			     x_msg_count        => x_msg_count,
			     p_pacv_rec       =>   p_pacv_rec,
			     x_pacv_rec       =>   x_pacv_rec) ;

             Else
		      IF (l_debug = 'Y') THEN
   		      my_debug('already exists'||l_id);
		      END IF;
		   End If;
		End If;
		   l_id :=null;
		   i := p_Req_RELATED_LINE_TBL.next(i);
	End LOOP;
	end;
	---tope pbh CHANGES




           --????delete all the records with whatever ids left in l_pat_id_tbl;
           IF (l_debug = 'Y') THEN
              my_debug('14784 : delete the left over old price adjustments '||l_pat_id_tbl.count, 1);
           END IF;

           i:=l_pat_id_tbl.first;
           while i is not null loop
             l_patv_tbl(i).id := l_pat_id_tbl(i);
---Bug 2143816
             l_patv_tbl(i).chr_id := p_chr_id;
		   If l_id_tbl(i) <> p_chr_id then
     		    l_patv_tbl(i).cle_id := l_id_tbl(i);
             End If;
-----
             IF (l_debug = 'Y') THEN
                my_debug('14785 : id of the deleted adjustment '||l_patv_tbl(i).id, 1);
             END IF;

             i:=l_pat_id_tbl.next(i);
           end loop;

           IF (l_debug = 'Y') THEN
              my_debug('14786 :before calling delete price adjustments'||x_return_status, 1);
           END IF;

           IF l_patv_tbl.count > 0 then
               OKC_PRICE_ADJUSTMENT_PUB.delete_price_adjustment(
                    p_api_version      => p_api_version,
                    x_return_status    => x_return_status ,
                    x_msg_count        => x_msg_count,
                    x_msg_data         => x_msg_data,
                    p_patv_tbl         => l_patv_tbl);
               IF (l_debug = 'Y') THEN
                  my_debug('14787 :after calling delete price adjustments'||x_return_status, 1);
               END IF;

              IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                   RAISE l_exception_stop;
              END IF;
           END IF;
           --???create records in adj_assocs;
            IF (l_debug = 'Y') THEN
               my_debug('14790 :Before calling Create adjustment attribs'||x_return_status, 1);
            END IF;
           --create records in adj attribs
              x_return_status := create_adj_attrib;
            IF (l_debug = 'Y') THEN
               my_debug('14792 :after calling Create adjustment attribs'||x_return_status, 1);
            END IF;

              IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                  RAISE l_exception_stop;
              END IF;
              --?????process relationship recs
    IF (l_debug = 'Y') THEN
       my_debug('14800 : Exiting PROCESS_ADJUSTMENT_DETAILS', 2);
    END IF;


    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    when l_exception_stop then
       null;
       IF (l_debug = 'Y') THEN
          my_debug('14850 : Exiting PROCESS_ADJUSTMENT_DETAILS', 4);
       END IF;
       IF (l_debug = 'Y') THEN
          okc_debug.Reset_Indentation;
       END IF;

    When others then
         --dbms_output.put_line('came here'||sqlcode||substr(sqlerrm,1,235));
          OKC_API.set_message(p_app_name      => g_app_name,
                                   p_msg_name      => G_UNEXPECTED_ERROR,
                                   p_token1        => G_SQLCODE_TOKEN,
                                   p_token1_value  => SQLCODE,
                                   p_token2        => G_SQLERRM_TOKEN,
                                   p_token2_value  => SQLERRM);
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
       IF (l_debug = 'Y') THEN
          my_debug('14900 : Exiting PROCESS_ADJUSTMENT_DETAILS', 4);
       END IF;
       IF (l_debug = 'Y') THEN
          okc_debug.Reset_Indentation;
       END IF;


END PROCESS_ADJUSTMENT_DETAILS;
----------------------------------------------------------------------------
-- Process_Adjustments
-- This procedure will check all the lines that get returned from pricing
-- and take appropriate action.
-- Modified to price service lines
----------------------------------------------------------------------------
PROCEDURE PROCESS_ADJUSTMENTS(
          p_api_version                IN     NUMBER,
          p_init_msg_list              IN     VARCHAR2 DEFAULT OKC_API.G_FALSE,
          p_CHR_ID                     IN     NUMBER,
          p_Control_Rec			       IN     OKC_CONTROL_REC_TYPE,
          p_req_line_tbl               IN     QP_PREQ_GRP.LINE_TBL_TYPE,
          p_Req_LINE_DETAIL_tbl        IN     QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
          p_Req_LINE_DETAIL_qual_tbl   IN     QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE,
          p_Req_LINE_DETAIL_attr_tbl   IN     QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE,
          p_Req_RELATED_LINE_TBL       IN     QP_PREQ_GRP.RELATED_LINES_TBL_TYPE,
          px_CLE_PRICE_TBL		       IN OUT NOCOPY    CLE_PRICE_TBL_TYPE,
          x_return_status              OUT  NOCOPY VARCHAR2,
          x_msg_count                  OUT  NOCOPY NUMBER,
          x_msg_data                   OUT  NOCOPY VARCHAR2) IS

          I pls_integer :=0;
          J pls_integer :=0;
          K pls_integer :=0;

          l_prc1   varchar(240);
          l_prc2   varchar(240);
          l_line_rec    cle_price_REC_TYPE;
          l_dummy_rec   cle_price_REC_TYPE;
          l_return_status varchar2(1):= OKC_API.G_RET_STS_SUCCESS;
          l_sts        varchar2(1):='S';
          p_line_ind     number  := 0;
          p_found boolean  := false;
          t pls_integer  :=0;
          l_cle_price_tbl cle_price_tbl_type := px_cle_price_tbl;
          p_service_qty_tbl NUM_TBL_TYPE;
          CURSOR l_cur is
                 Select name
                 from okx_list_headers_v a,okx_qp_list_lines_v b
                 where
                 (b.id1 =  to_number(substr(p_req_line_tbl(i).status_text,1,
									instr(p_req_line_tbl(i).status_text,',')-1))
                 OR
                 b.id1 =  to_number(substr(p_req_line_tbl(i).status_text,
									instr(p_req_line_tbl(i).status_text,',')+1)))
                 and a.id1=b.list_header_id;


   Function is_service_subline(p_id number) return varchar2 is
      result  varchar2(1) := 'N';
	BEGIN

     IF (l_debug = 'Y') THEN
        my_debug('100:In is_service_subline ');
     END IF;

     Select nvl(service_item_yn,'N') service_item_yn into result
	From okc_k_lines_b
     where id = (Select cle_id from okc_k_lines_b where id =p_id);

     IF (l_debug = 'Y') THEN
        my_debug('101: Result is'||result);
     END IF;
     return result;

	Exception
	 when no_data_found then
        IF (l_debug = 'Y') THEN
           my_debug ('102: No data found');
        END IF;
	   return result ;
      when others then
	   IF (l_debug = 'Y') THEN
   	   my_debug('103: Other error');
	   END IF;
   END is_service_subline;


  BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('PROCESS_ADJUSTMENTS');
    END IF;
    IF (l_debug = 'Y') THEN
       my_debug('15000 : Entering PROCESS_ADJUSTMENTS', 2);
    END IF;

         --dbms_output.put_line('a1-starting process adjustments'||p_req_line_tbl.count);
          If px_cle_price_tbl.count =0  then
              IF p_control_rec.p_level = 'QA' then
                 -- this case might never be reached by QA but still putting the check
                   l_return_status:= OKC_API.G_RET_STS_SUCCESS;
              Else
                  OKC_API.set_message(p_app_name      => g_app_name,
                                      p_msg_name      => 'OKC_NO_QP_ROW');
                   l_return_status:= OKC_API.G_RET_STS_ERROR;

              End IF;
              Raise l_exception_stop;
          End If;
          i:=  p_req_line_tbl.first;
          While I is not null Loop --#1
                       p_found := false;
                       p_line_ind := 0;
    -- Check If line is in priced_tbl
   --- Using l_cle_price_tbl as px_cle_price_tbl gets updated later
                       t := l_cle_price_tbl.first;
                       While t is not null loop
                         if l_cle_price_tbl(t).id = p_req_line_tbl(i).line_id then
                            p_line_ind := t;
                            p_found := true;
                         exit ;
                         End If;
                         t:= l_cle_price_tbl.next(t);
                       End Loop;
                l_prc1:=null;
                If p_found  then
  				l_line_rec := px_cle_price_tbl(p_line_ind);
                    IF (l_debug = 'Y') THEN
                       my_debug('15005:index of request line being processed'||(p_req_line_tbl(i).line_index));
                       my_debug('15006:id of request line being processed'||(p_req_line_tbl(i).line_id));
                    END IF;
                else
                     l_line_rec := l_dummy_rec;
                     IF (l_debug = 'Y') THEN
                        my_debug('15010:check :is it generated line'||(p_req_line_tbl(i).line_index));
                     END IF;
                End if;

                If l_line_rec.id <> 0 then  --#1.1 That means found the rec. filter out nocopy free goods and header line
                  l_line_rec.ret_sts := 'E';
              	  if--#2
                      p_req_line_tbl(i).line_Type_code ='LINE' and  --#2
  	                  p_req_line_tbl(i).status_code in ( QP_PREQ_GRP.G_STATUS_INVALID_PRICE_LIST,
				              QP_PREQ_GRP.G_STS_LHS_NOT_FOUND,
				              QP_PREQ_GRP.G_STATUS_FORMULA_ERROR,
				              QP_PREQ_GRP.G_STATUS_OTHER_ERRORS,
				              OKC_API.G_RET_STS_UNEXP_ERROR,
				              OKC_API.G_RET_STS_ERROR,
				              QP_PREQ_GRP.G_STATUS_CALC_ERROR,
				              QP_PREQ_GRP.G_STATUS_UOM_FAILURE,
				              QP_PREQ_GRP.G_STATUS_INVALID_UOM,
				              QP_PREQ_GRP.G_STATUS_DUP_PRICE_LIST,
				              QP_PREQ_GRP.G_STATUS_INVALID_UOM_CONV,
				              QP_PREQ_GRP.G_STATUS_INVALID_INCOMP,
				              QP_PREQ_GRP.G_STATUS_BEST_PRICE_EVAL_ERROR,
			                  QP_PREQ_PUB.G_BACK_CALCULATION_STS)
	                then
                      IF (l_debug = 'Y') THEN
                         my_debug('15020: some error in request, code-'||p_req_line_tbl(i).status_code);
                         my_debug('15022: pricelist id on line-'||l_line_rec.pricelist_id);
                      END IF;
                      If l_line_rec.pricelist_id is not null then
		               Begin
	 		                 Select name
                             into l_prc1
			                 from okx_list_headers_v
                             where id1 = l_line_rec.pricelist_id;
                             IF (l_debug = 'Y') THEN
                                my_debug('15050 : select rowcount for pricelist name'||SQL%ROWCOUNT, 1);
                             END IF;

			                 Exception
                               When No_data_found then
                                 l_prc1 := l_line_rec.pricelist_id;
                                 IF (l_debug = 'Y') THEN
                                    my_debug('15051 : Exception no data found', 2);
                                 END IF;

		               End;
                      END IF;

                       If l_line_rec.line_num is null then
                       -- get the concatenated line number to show in error message
                           l_line_rec.line_num := OKC_CONTRACT_PUB.Get_concat_line_no(
                              p_cle_id       =>  l_line_rec.id ,
                              x_return_status => l_return_status
                           );
                           If l_return_status <> okc_api.g_ret_sts_success Then
                               l_line_rec.line_num := 'Unknown';
                           End If;

                       End if;
                       IF (l_debug = 'Y') THEN
                          my_debug('15060 : error line Id'||l_line_rec.id, 1);
                          my_debug('15062 : Error Line String'||l_line_rec.line_num, 1);
                       END IF;


                      --san  x_return_status := OKC_API.G_RET_STS_ERROR;
                      x_return_status :=G_SOME_LINE_ERRORED;
                       --?????change all pricing error names to OKC_QP_... later
                       If p_req_line_tbl(i).status_code  = QP_PREQ_GRP.G_STATUS_INVALID_PRICE_LIST
                             and l_prc1 is not null then --#3
                                OKC_API.set_message(p_app_name      => g_app_name,
                                   p_msg_name      => 'OKC_QP_INVALID_PRICE_LIST', --invalid pricelist/item combi
                                   p_token1        => 'line_num',
                                   p_token1_value  => l_line_rec.line_num,
                                   p_token2        => 'Price_list',
                                   p_token2_value  => l_prc1);
                       Elsif p_req_line_tbl(i).status_code = QP_PREQ_GRP.G_STS_LHS_NOT_FOUND
                             OR (p_req_line_tbl(i).status_code  = QP_PREQ_GRP.G_STATUS_INVALID_PRICE_LIST
                             AND l_prc1 is null ) Then
                                OKC_API.set_message(p_app_name      => g_app_name,
                                   p_msg_name      => 'OKC_QP_NO_PRICE_LIST', --pricelist not found
                                   p_token1        => 'LINE_NUM',
                                   p_token1_value  => l_line_rec.line_num);
  		               Elsif p_req_line_tbl(i).status_code = QP_PREQ_GRP.G_STATUS_FORMULA_ERROR then
                                OKC_API.set_message(p_app_name      => g_app_name,
                                   p_msg_name      => 'OKC_QP_FORMULA_ERROR', --Error in formula processing
                                   p_token1        => 'line_num',
                                   p_token1_value  => l_line_rec.line_num);
  		               Elsif p_req_line_tbl(i).status_code in
				          (QP_PREQ_GRP.G_STATUS_OTHER_ERRORS , FND_API.G_RET_STS_UNEXP_ERROR,
						       FND_API.G_RET_STS_ERROR)
		               then
                            OKC_API.set_message(p_app_name      => g_app_name,
                                   p_msg_name      => 'OKC_QP_PRICING_ERROR', --other errors in processing
                                   p_token1        => 'line_num',
                                   p_token1_value  => l_line_rec.line_num,
                                   p_token2        => 'Err_Text',
                                   p_token2_value  => p_req_line_tbl(i).status_text);

		               Elsif p_req_line_tbl(i).status_code = QP_PREQ_GRP.G_STATUS_INVALID_UOM then
                             OKC_API.set_message(p_app_name      => g_app_name,
                                   p_msg_name      => 'OKC_QP_INVALID_UOM', --invalid uom
                                   p_token1        => 'UOM',
                                   p_token1_value  => p_req_line_tbl(i).line_uom_code,
                                   p_token2        => 'line_num',
                                   p_token2_value  => l_line_rec.line_num);--????check priced or line uom here
                            --dbms_output.put_line('ddddd'||l_line_rec.line_num||'fff'||p_req_line_tbl(i).line_uom_code);
		               Elsif p_req_line_tbl(i).status_code = QP_PREQ_GRP.G_STATUS_DUP_PRICE_LIST then
                           BEGIN
					   ---Modified to show correct price lists in error message
						 l_prc1 := null;
                               --open l_cur;
                               For cur_rec in l_cur LOOP
                                  If l_prc1 is null then
							 l_prc1 := cur_rec.name;
                                   --Fetch l_cur into l_prc1;
                                  ELSE
					           l_prc2 := cur_rec.name;
                                   --FETCH l_cur into l_prc2;
                                  END IF;
                                  --Exit when l_cur%NOTFOUND;
                               END LOOP; --????test this
                               --close l_cur;
                               If l_prc1 is null then
                                  l_prc1 := p_req_line_tbl(i).status_text;
                               ELSIF l_prc2 is null then
                                  l_prc1 := p_req_line_tbl(i).status_text;
                               END IF;

                               Exception
                                     When others then
                                        l_prc1 := p_req_line_tbl(i).status_text;

  	                       End;

                           OKC_API.set_message(p_app_name      => g_app_name,
                                   p_msg_name      => 'OKC_QP_DUP_PRICELIST', --duplicate pricelist
                                   p_token1        => 'line_num',
                                   p_token1_value  => l_line_rec.line_num,
                                   p_token2        => 'Price1',
                                   p_token2_value  => l_prc1,
                                   p_token3        => 'Price2',
                                   p_token3_value  => l_prc2);

                                   l_prc1:=null;
                                   l_prc2:=null;
                                            --dbms_output.put_line('a3');


		               Elsif p_req_line_tbl(i).status_code = QP_PREQ_GRP.G_STATUS_INVALID_UOM_CONV then
                            OKC_API.set_message(p_app_name      => g_app_name,
                                   p_msg_name      => 'OKC_QP_INVAL_UOM_CONV', --invalid uom conversion
                                   p_token1        => 'line_num',
                                   p_token1_value  => l_line_rec.line_num,
                                   p_token2        => 'err_text',
                                   p_token2_value  => p_req_line_tbl(i).status_text);

                       Elsif p_req_line_tbl(i).status_code = QP_PREQ_GRP.G_STATUS_INVALID_INCOMP then
                            OKC_API.set_message(p_app_name      => g_app_name,
                                   p_msg_name      => 'OKC_QP_INVALID_INCOMP', --Unable to resolve incompatibility
                                   p_token1        => 'line_num',
                                   p_token1_value  => l_line_rec.line_num,
                                   p_token2        => 'err_text',
                                   p_token2_value  => p_req_line_tbl(i).status_text);
		               Elsif p_req_line_tbl(i).status_code = QP_PREQ_GRP.G_STATUS_BEST_PRICE_EVAL_ERROR then
                            OKC_API.set_message(p_app_name      => g_app_name,
                                   p_msg_name      => 'OKC_QP_BEST_PRICE', --error while evaluating best price
                                   p_token1        => 'line_num',
                                   p_token1_value  => l_line_rec.line_num,
                                   p_token2        => 'err_text',
                                   p_token2_value  => p_req_line_tbl(i).status_text);

  	                   Else
                            OKC_API.set_message(p_app_name      => g_app_name,
                                   p_msg_name      => 'OKC_PRICING_ERROR', --error while pricing
                                   p_token1        => 'line_num',
                                   p_token1_value  => l_line_rec.line_num,
                                   p_token2        => 'err_text',
                                   p_token2_value  => p_req_line_tbl(i).status_text);

                      END IF;--#3
                      --???? if one price fails, say negative price, then do we raise error and come out
				  --commenting out to support negative pricing
                  /* ELSIF  ( p_req_line_tbl(i).unit_price < 0 or p_req_line_tbl(i).Adjusted_unit_price < 0) then     --#2
                       IF l_line_rec.line_num is null then
                          -- get the concatenated line number to show in error message
                           l_line_rec.line_num := OKC_CONTRACT_PUB.Get_concat_line_no(
                              p_cle_id       =>  l_line_rec.id ,
                              x_return_status => l_return_status
                           );
                           If l_return_status <> okc_api.g_ret_sts_success Then
                               l_line_rec.line_num := 'Unknown';
                           End If;
                       END IF;
                       IF (l_debug = 'Y') THEN
                          my_debug('15450 : error line Id'||l_line_rec.id, 1);
                          my_debug('15460 : Error Line String'||l_line_rec.line_num, 1);
                       END IF;

		                   OKC_API.set_message(p_app_name      => g_app_name,
                                   p_msg_name      => 'OKC_QP_NEG_PRICE', --???Is it an error for us?
                                   p_token1        => 'line_num',
                                   p_token1_value  => l_line_rec.line_num,
                                   p_token2        => 'LIST_PRICE',
                                   p_token2_value  => p_req_line_tbl(i).unit_price,
                                   p_token3        => 'SELLING_PRICE',
                                   p_token3_value  => p_req_line_tbl(i).adjusted_unit_price);
                            --san x_return_status := OKC_API.G_RET_STS_ERROR;
                            x_return_status := G_SOME_LINE_ERRORED;
                      */
	               elsif p_req_line_tbl(i).line_Type_code ='LINE' and
                         p_req_line_tbl(i).status_code in
				                ( QP_PREQ_GRP.G_STATUS_UPDATED,
                                  QP_PREQ_GRP.G_STATUS_NEW,
                                  QP_PREQ_GRP.G_STATUS_SYSTEM_GENERATED,
                                  QP_PREQ_GRP.G_STATUS_GSA_VIOLATION,
                                  QP_PREQ_GRP.G_STATUS_UNCHANGED,
			                      QP_PREQ_PUB.G_BACK_CALCULATION_STS) and
	                     --???? change later nvl(p_req_line_tbl(i).processed_code,'0') = QP_PREQ_PUB.G_BACK_CALCULATION_STS then
                         -- right now this way because of a bug in QP. Later on QP might return this error  in retcode on request line
                         -- also   QP_PREQ_PUB.G_BACK_CALCULATION_STS might hold 'BACK CALCULATION ERROR' instaed of
                         -- 'BACK_CALCULATION_ERROR'. Right now processed code returns 'BACK CALCULATION ERROR'
                         -- while QP_PREQ_PUB.G_BACK_CALCULATION_STS has value 'BACK_CALCULATION_ERROR'
                                 nvl(p_req_line_tbl(i).processed_code,'0') = 'BACK CALCULATION ERROR' then
                       IF l_line_rec.line_num is null then
                          -- get the concatenated line number to show in error message
                          l_line_rec.line_num := OKC_CONTRACT_PUB.Get_concat_line_no(
                              p_cle_id       =>  l_line_rec.id ,
                              x_return_status => l_return_status
                           );
                           If l_return_status <> okc_api.g_ret_sts_success Then
                              l_line_rec.line_num := 'Unknown';
                           End If;
                       END IF;
                       IF (l_debug = 'Y') THEN
                          my_debug('15500 : error line Id'||l_line_rec.id, 1);
                          my_debug('15510 : Error Line String'||l_line_rec.line_num, 1);
                       END IF;

                           OKC_API.set_message(p_app_name      => g_app_name,
                                   p_msg_name      => 'OKC_BACK_CALC_ERROR',
                                   p_token1        => 'line_num',
                                   p_token1_value  => l_line_rec.line_num);
                           --san  x_return_status := OKC_API.G_RET_STS_ERROR;
                            x_return_status := G_SOME_LINE_ERRORED;


	               elsif p_req_line_tbl(i).line_Type_code ='LINE' and
                       p_req_line_tbl(i).status_code in
				                ( QP_PREQ_GRP.G_STATUS_UPDATED,
                                  QP_PREQ_GRP.G_STATUS_NEW,
                                  QP_PREQ_GRP.G_STATUS_SYSTEM_GENERATED,
                                  QP_PREQ_GRP.G_STATUS_GSA_VIOLATION,
                                  QP_PREQ_GRP.G_STATUS_UNCHANGED) and
	                     nvl(p_req_line_tbl(i).processed_code,'0') <> QP_PREQ_PUB.G_BY_ENGINE--????check this one
	                     and p_req_line_tbl(i).price_flag IN ('Y','P')
	                 then
                       --??? update line's unit price to null in case of error
                          --dbms_output.put_line('a2.5');

                        l_line_rec.ret_sts := 'S';

                        If is_service_subline(p_req_line_tbl(i).line_id) = 'N'   then
                          IF (l_debug = 'Y') THEN
                             my_debug(p_req_line_tbl(i).line_index||'not found'||p_req_line_tbl(i).line_id||'i'||i);
                          END IF;
                          If nvl(p_req_line_tbl(i).priced_quantity,0) <> nvl(p_req_line_tbl(i).line_quantity,0) then
                        ---???? unit price should be null in case of pbh
                                l_line_rec.unit_price := p_req_line_tbl(i).unit_price
                                                 * (p_req_line_tbl(i).priced_quantity/p_req_line_tbl(i).line_quantity);
                          Else
                        ---???? unit price should be null in case of pbh
                               l_line_rec.unit_price := p_req_line_tbl(i).unit_price;
                          End if;
                        --l_line_rec.qty:= p_req_line_tbl(i).priced_quantity ;
                        --l_line_rec.uom_code:= p_req_line_tbl(i).priced_uom_code ;
                          l_line_rec.negotiated_amt := p_req_line_tbl(i).adjusted_unit_price* p_req_line_tbl(i).priced_quantity ;
                  --      l_line_rec.list_price := l_line_rec.unit_price * p_req_line_tbl(i).priced_quantity;
                  -- Bug 2487799
			           l_line_rec.list_price := l_line_rec.unit_price * p_req_line_tbl(i).line_quantity;
                          l_line_rec.qty:= p_req_line_tbl(i).line_quantity ;
                          l_line_rec.uom_code := p_req_line_tbl(i).priced_uom_code;

                        Else

                            IF (l_debug = 'Y') THEN
                               my_debug('Service qty'||p_req_line_tbl(i).line_quantity );
                               my_debug('Service uom'||p_req_line_tbl(i).priced_uom_code);
                               my_debug('Cov uom'||p_req_line_tbl(i-1).priced_uom_code);
                               my_debug('Cov qty '||p_req_line_tbl(i-1).priced_quantity);
                               MY_DEBUG('Service adj_price'||p_req_line_tbl(i).adjusted_unit_price);
                               MY_DEBUG('Service unit_price'||p_req_line_tbl(i).unit_price);
                            END IF;

                           ---Multiply amounts by qty of service item
                           -- assign back qty and uom of covered line/item/products
                           -- using previous record, as covered line request is always before service line

                          If nvl(p_req_line_tbl(i).priced_quantity,0) <> nvl(p_req_line_tbl(i).line_quantity,0) then
                        ---???? unit price should be null in case of pbh
                                l_line_rec.unit_price :=( p_req_line_tbl(i).unit_price
                                                 * (p_req_line_tbl(i).priced_quantity/p_req_line_tbl(i).line_quantity))*p_req_line_tbl(i).line_quantity;
                          Else
                        ---???? unit price should be null in case of pbh
                               l_line_rec.unit_price := p_req_line_tbl(i).unit_price* p_req_line_tbl(i).line_quantity;
                          End if;
                          l_line_rec.negotiated_amt := p_req_line_tbl(i).adjusted_unit_price* p_req_line_tbl(i).priced_quantity*p_req_line_tbl(i-1).line_quantity;
					 l_line_rec.list_price := l_line_rec.unit_price * p_req_line_tbl(i-1).line_quantity;
                          l_line_rec.qty:= p_req_line_tbl(i-1).line_quantity ;
                          l_line_rec.uom_code:= p_req_line_tbl(i-1).line_uom_code;
                          --Bug 2389314
                          p_service_qty_tbl(p_req_line_tbl(i).line_index) := p_req_line_tbl(i).line_id;

                       End if;


                        l_line_rec.pricing_date := p_req_line_tbl(i).pricing_effective_date;

                        k:= p_req_line_detail_tbl.first;
                        while k is not null loop
                           If p_req_line_detail_tbl(k).line_index = p_req_line_tbl(i).line_index
                            and p_req_line_detail_tbl(k).list_line_type_code = 'PLL' then
                               l_line_rec.pricelist_id := p_req_line_detail_tbl(k).list_header_id;
                               l_line_rec.list_line_id := p_req_line_detail_tbl(k).list_line_id;
                               Exit;
                           ELSIF p_req_line_detail_tbl(k).line_index = p_req_line_tbl(i).line_index
                                 and   p_req_line_detail_tbl(k).created_from_list_type_code IN ('PRL','AGR')
                                 and  p_req_line_detail_tbl(k).list_line_type_code = 'PBH' then

                                 l_line_rec.pricelist_id := p_req_line_detail_tbl(k).list_header_id;
                                 l_line_rec.list_line_id := p_req_line_detail_tbl(k).list_line_id;
                                 --Bug 2565815
                                 IF p_req_line_detail_tbl(k).created_from_list_type_code = 'PRL' THEN
                                    --l_line_rec.list_price := l_line_rec.unit_price;
                                    --l_line_rec.unit_price := null;
                                    --l_line_rec.negotiated_amt := l_line_rec.negotiated_amt/p_req_line_tbl(i).line_quantity ;

                                     --Bug 2791272:  keep whatever value l_line_rec.unit_price already has for eg.
                                     --              qty of service line * unit price of service line
                                     --              i.e. we already have a calculated value in l_line_rec.unit_price
                                     --              which we want to retain
                                    /***
                                     commented out for above reason
                                    l_line_rec.unit_price := p_req_line_tbl(i).unit_price; --Added for bug fix
                                    ***/
                                    null;


                                 --Bug 2565815
                                 ELSE
                                    l_line_rec.list_price := l_line_rec.unit_price;
                                    l_line_rec.unit_price := null;
                                    l_line_rec.negotiated_amt := l_line_rec.negotiated_amt/p_req_line_tbl(i).line_quantity ;
                                 END IF;

                                 -- Bug 2604686  fixes formatting issue related to fix made for Bug 2565815
                                 IF l_line_rec.unit_price IS NOT NULL THEN
                                    l_line_rec.unit_price := ROUND(l_line_rec.unit_price,2);
                                 END IF;
                                 IF l_line_rec.list_price IS NOT NULL THEN
                                    l_line_rec.list_price := ROUND(l_line_rec.list_price,2);
                                 END IF;
                                 IF l_line_rec.negotiated_amt IS NOT NULL THEN
                                    l_line_rec.negotiated_amt := ROUND(l_line_rec.negotiated_amt,2);
                                 END IF;    --end Bug 2604686


                               Exit;

                           END IF;
                        k:=p_req_line_detail_tbl.next(k);
                        End loop;

                    END IF;--#2
                       --dbms_output.put_line('a4'||p_req_line_tbl(i).status_code);

                       l_line_rec.ret_code := p_req_line_tbl(i).status_code;
--Assign update record back to price table
                       px_cle_price_tbl(p_line_ind) := l_line_rec;


                 END IF; --#1.1
                 i:=  p_req_line_tbl.next(i);
          END LOOP; --#1



/* I := px_cle_price_tbl.first;
If i is not null then loop
IF (l_debug = 'Y') THEN
   my_debug('id '||i||px_cle_price_tbl(i).id);
   my_debug('line_index '||i||px_cle_price_tbl(i).line_index);
   my_debug('list price '||i||px_cle_price_tbl(i).list_price);
   my_debug('unit price '||i||px_cle_price_tbl(i).unit_price);
END IF;

--my_debug('TOPEK:pi tbl index'||l_services_tbl(i).srv_item_tbl_index);
exit when i = px_cle_price_tbl.last;
i := px_cle_price_tbl.next(i);
end loop;
end if;*/

          -- If we are trying to reprice the whole contract and even one request line came back with
          -- an error, we would rollback for all the lines as header level pricing should succeed
          -- either for all lines or none.
          If x_return_status <> OKC_API.G_RET_STS_SUCCESS and
          (p_control_rec.p_level in ( 'H','QA') OR p_control_rec.p_config_yn <> 'N') then
                l_return_status:= x_return_status;
                -- Though for header pricing we want to rollback even if one line failed
                If l_return_status = G_SOME_LINE_ERRORED then
                  l_return_status:= OKC_API.G_RET_STS_ERROR;
                END IF;
                IF p_control_rec.p_level in ( 'H','QA') then
                     OKC_API.set_message(p_app_name      => g_app_name,
                                     p_msg_name      => 'OKC_STOP_HDR_ADJS');
                END IF;
                Raise l_exception_stop;
          End If;

           --process adjustment details

           If p_control_rec.p_calc_flag = 'B'
              and p_control_rec.p_config_yn <> 'Y'
                  and p_control_rec.p_level <> 'QA'
           then
                      IF (l_debug = 'Y') THEN
                         my_debug('15685 :before process adjustment details Priced lines count'||px_cle_price_tbl.count);
                         my_debug('15686 :before process adjustment details l_return status'||l_return_status);
                      END IF;

                           PROCESS_ADJUSTMENT_DETAILS(p_api_version    =>  p_api_version,
                              p_CHR_ID                     => p_chr_id,
                              p_Control_Rec			       => p_control_rec,
                              p_req_line_tbl               => p_req_line_tbl,
                              p_Req_LINE_DETAIL_tbl        => p_req_line_detail_tbl,
                              p_Req_LINE_DETAIL_qual_tbl   => p_req_line_detail_qual_tbl,
                              p_Req_LINE_DETAIL_attr_tbl   => p_req_line_detail_attr_tbl,
                              p_Req_RELATED_LINE_TBL       => p_req_related_line_tbl,
                              p_CLE_PRICE_TBL		    => px_CLE_PRICE_TBL,
                              p_service_qty_tbl            => p_service_qty_tbl,
                              x_return_status              => l_return_status,
                              x_msg_count                  => x_msg_count,
                              x_msg_data                   => x_msg_data);
                       IF (l_debug = 'Y') THEN
                          my_debug('15690 :After process adjustment details return status:- '||l_return_status);
                       END IF;
                            If l_return_status <> OKC_API.G_RET_STS_SUCCESS then
                               raise l_exception_stop;
                            End if;
           END IF;
    IF (l_debug = 'Y') THEN
       my_debug('15700 : Exiting PROCESS_ADJUSTMENTS', 2);
    END IF;
    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;

   EXCEPTION
      When l_exception_stop then
         x_return_status := l_return_status;
    IF (l_debug = 'Y') THEN
       my_debug('15800 : Exiting PROCESS_ADJUSTMENTS', 4);
    END IF;
    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;

      When others then
         --dbms_output.put_line('came here'||sqlcode||substr(sqlerrm,1,235));
          OKC_API.set_message(p_app_name      => g_app_name,
                                   p_msg_name      => G_UNEXPECTED_ERROR,
                                   p_token1        => G_SQLCODE_TOKEN,
                                   p_token1_value  => SQLCODE,
                                   p_token2        => G_SQLERRM_TOKEN,
                                   p_token2_value  => SQLERRM);
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
     IF (l_debug = 'Y') THEN
        my_debug('15900 : Exiting PROCESS_ADJUSTMENTS', 4);
     END IF;
    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;

   END PROCESS_ADJUSTMENTS;

   ----------------------------------------------------------------------------
-- CALCULATE_PRICE
-- This procedure will calculate the price for the sent in line/header
-- px_cle_price_tbl returns the priced line ids and thier prices
-- p_level tells whether line level or header level
-- possible value 'L' line ,'H' the whole contract including header,'QA' only QA DEFAULT 'L'
--p_calc_flag   'B'(Both -calculate and search),'C'(Calculate Only), 'S' (Search only)
----------------------------------------------------------------------------
PROCEDURE CALCULATE_price(
          p_api_version                 IN          NUMBER ,
          p_init_msg_list               IN          VARCHAR2 ,
          p_CHR_ID                      IN          NUMBER,
          p_Control_Rec			        IN          OKC_CONTROL_REC_TYPE,
          px_req_line_tbl               IN  OUT NOCOPY   QP_PREQ_GRP.LINE_TBL_TYPE,
          px_Req_qual_tbl               IN  OUT NOCOPY   QP_PREQ_GRP.QUAL_TBL_TYPE,
          px_Req_line_attr_tbl          IN  OUT NOCOPY   QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
          px_Req_LINE_DETAIL_tbl        IN  OUT NOCOPY   QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
          px_Req_LINE_DETAIL_qual_tbl   IN  OUT NOCOPY   QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE,
          px_Req_LINE_DETAIL_attr_tbl   IN  OUT NOCOPY   QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE,
          px_Req_RELATED_LINE_TBL       IN  OUT NOCOPY   QP_PREQ_GRP.RELATED_LINES_TBL_TYPE,
          px_CLE_PRICE_TBL		        IN  OUT NOCOPY   CLE_PRICE_TBL_TYPE,
          x_return_status               OUT  NOCOPY VARCHAR2,
          x_msg_count             OUT  NOCOPY NUMBER,
          x_msg_data              OUT  NOCOPY VARCHAR2) IS

     l_return_status varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_api_name constant VARCHAR2(30) := 'CALCULATE PRICE';
     l_hdr_prc_contexts_Tbl    QP_PREQ_GRP.LINE_ATTR_TBL_TYPE;
     l_hdr_qual_contexts_Tbl  QP_PREQ_GRP.QUAL_TBL_TYPE;


     l_line_tbl line_tbl_type;
     l_id_tbl num_tbl_type;
     l_id1 varchar2(40);
     l_id2 varchar2(100);
     l_jtot1_code varchar2(30);

     l_bpi_ind pls_integer:=0;
     l_pi_ind  pls_integer:=0;

     l_pricing_event varchar2(10) := p_control_rec.qp_control_rec.pricing_event;


     l_Req_related_lines_tbl         QP_PREQ_GRP.RELATED_LINES_TBL_TYPE:=px_Req_RELATED_LINE_TBL;
     l_req_line_tbl                  QP_PREQ_GRP.LINE_TBL_TYPE:=px_req_line_tbl ;
     l_pricing_contexts_Tbl          QP_PREQ_GRP.LINE_ATTR_TBL_TYPE := px_Req_line_attr_tbl;
     l_qualifiers_contexts_Tbl       QP_PREQ_GRP.QUAL_TBL_TYPE := px_Req_qual_tbl;
     l_Req_LINE_DETAIL_tbl           QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE:= px_Req_LINE_DETAIL_tbl;
     l_Req_LINE_DETAIL_qual_tbl      QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE:= px_Req_LINE_DETAIL_qual_tbl;
     l_Req_LINE_DETAIL_attr_tbl      QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE:= px_Req_LINE_DETAIL_attr_tbl;

     l_prc_Tbl                       QP_PREQ_GRP.LINE_ATTR_TBL_TYPE;
     l_qual_Tbl                      QP_PREQ_GRP.QUAL_TBL_TYPE ;

     l_bpi_prc_Tbl                       QP_PREQ_GRP.LINE_ATTR_TBL_TYPE;
     l_bpi_qual_Tbl                      QP_PREQ_GRP.QUAL_TBL_TYPE ;

     l_index                        pls_integer;
     l_Req_LINE_index                number :=null;
     l_control_rec                   QP_PREQ_GRP.CONTROL_RECORD_TYPE:=p_control_rec.qp_control_rec;
     l_return_status_text            Varchar2(240);
     l_okc_control_rec               OKC_CONTROL_REC_TYPE := p_control_rec;
     l_line_index  pls_integer :=0;

     l_curr           varchar2(15);
     i pls_integer   :=0;
     j pls_integer   :=0;

     l_related_lines_index number :=0;
     l_priced_tbl   NUM_TBL_TYPE;
     l_price_list   number;
     l_check    VARCHAR(2) := 'N';

   FUNCTION load_applied_adjs(i pls_integer)
     Return varchar2 is
     l_return_status varchar2(1):= OKC_API.G_RET_STS_SUCCESS;
     cursor l_cle(p_id number,pchr_id number) is
        select *
        from okc_price_adjustments a
        where
           cle_id = p_id and chr_id=pchr_id
           and applied_flag='Y'
           --do not process child detail lines      -- tope pbh changes
	   and id not in (Select pat_id
		          from okc_price_adj_assocs_v
			  where  cle_id =p_id
			  and pat_id_from is not null
			  and pat_id = a.id);
	    --tope pbh changes



     cursor l_chr(p_id number) is
        select *
        from okc_price_adjustments
        where
           chr_id = p_id and cle_id is null --???ask sripriya do we just send manual.(what about overrides)
           and applied_flag='Y';


     cursor l_related_lines(p_pat_id number,p_cle_id number) is
     select  b.*
	from okc_price_adj_assocs_v a, okc_price_adjustments b
	where a.pat_id_from =p_pat_id
	and a.pat_id = b.id
	and a.cle_id =p_cle_id
	and a.cle_id = b.cle_id;


     cursor l_attribs(p_id number) is
       select flex_title,pricing_context,pricing_attribute,
              pricing_attr_value_from, pricing_attr_value_to,comparison_operator
       From okc_price_adj_attribs
       where pat_id=p_id;
       pbh_index number;
      l_row l_cle%rowtype;
      l_attrib_row l_attribs%rowtype;
      j  pls_integer := l_req_line_detail_tbl.count;
      k  pls_integer := l_req_line_detail_qual_tbl.count;
      l pls_integer := 0;

   Begin
       IF (l_debug = 'Y') THEN
          okc_debug.Set_Indentation('load_applied_adjs');
       END IF;
       IF (l_debug = 'Y') THEN
          my_debug('16000 : Entering load_applied_adjs', 2);
       END IF;

       If l_req_line_tbl(i).line_type_code = 'ORDER' then
         Open l_chr(l_req_line_tbl(i).line_id);
       Else
          open l_cle(l_req_line_tbl(i).line_id,p_chr_id);
       End if;
       Loop --#1
         j:=j+1;
         If l_req_line_tbl(i).line_type_code = 'ORDER' then
           Fetch l_chr into l_row;
           Exit when l_chr%NOTFOUND;
           l_req_line_detail_tbl(j).line_detail_type_code := 'ORDER';

         Else
            Fetch l_cle into l_row;
            Exit when l_cle%notfound;
            l_req_line_detail_tbl(j).line_detail_type_code := 'LINE';

         End if;
         l_req_line_detail_tbl (j).line_index := l_req_line_tbl(i).line_index;
         l_req_line_detail_tbl(j).line_detail_index := j;
      --???l_req_line_detail_tbl(j).inventory_item_id :=
         l_req_line_detail_tbl (j).list_line_no := l_row.list_line_no;
         l_req_line_detail_tbl(j).pricing_phase_id := l_row.pricing_phase_id;
         l_req_line_detail_tbl(j).list_header_id := l_row.list_header_id;
         l_req_line_detail_tbl(j).list_line_id := l_row.list_line_id;
         l_req_line_detail_tbl(j).list_line_type_code := l_row.list_line_type_code;
         l_req_line_detail_tbl(j).created_from_list_type_code:= l_row.modifier_mechanism_type_code;
         l_req_line_detail_tbl(j).automatic_flag := l_row.automatic_flag;
         l_req_line_detail_tbl(j).applied_flag := l_row.applied_flag;
         l_req_line_detail_tbl(j).updated_flag := l_row.updated_flag;
         l_req_line_detail_tbl(j).operand_calculation_code := l_row.arithmetic_operator;
         l_req_line_detail_tbl(j).operand_value := l_row.operand;
         l_req_line_detail_tbl(j).modifier_level_code := l_row.modifier_level_code;
         l_req_line_detail_tbl(j).override_flag := l_row.UPDATE_ALLOWED ;
         l_req_line_detail_tbl(j).line_quantity := l_row.range_break_quantity;

          For l_attrib_row in l_attribs(l_row.pat_id) loop
            k:=k+1;
            If l_attrib_row.flex_title = 'QP_ATTR_DEFNS_QUALIFIER' then
               	l_Req_LINE_DETAIL_qual_tbl(k).line_detail_index := j;
            	l_Req_LINE_DETAIL_qual_tbl(k).Qualifier_Context := l_attrib_row.pricing_context;
				l_Req_LINE_DETAIL_qual_tbl(k).Qualifier_Attribute:= l_attrib_row.pricing_attribute;
				l_Req_LINE_DETAIL_qual_tbl(k).Qualifier_Attr_Value_From:= l_attrib_row.pricing_attr_value_from;
			    l_Req_LINE_DETAIL_qual_tbl(k).Qualifier_Attr_Value_To:= l_attrib_row.pricing_attr_value_to;
				l_Req_LINE_DETAIL_qual_tbl(k).comparison_operator_Code:= l_attrib_row.comparison_operator;

            Elsif l_attrib_row.flex_title = 'QP_ATTR_DEFNS_PRICING' then
              	l_Req_LINE_DETAIL_attr_tbl(k).line_detail_index := j;
                l_Req_LINE_DETAIL_attr_tbl(k).PRICING_Context := l_attrib_row.pricing_context;
				l_Req_LINE_DETAIL_attr_tbl(k).PRICING_Attribute:= l_attrib_row.pricing_attribute;
				l_Req_LINE_DETAIL_attr_tbl(k).PRICING_Attr_Value_From:= l_attrib_row.pricing_attr_value_from;
			    l_Req_LINE_DETAIL_attr_tbl(k).PRICING_Attr_Value_To:= l_attrib_row.pricing_attr_value_to;

            End if;
         End loop; --l_attrib

         IF (l_debug = 'Y') THEN
            my_debug ('type_code'|| l_row.list_line_type_code);
         END IF;
         -- tope pbh changes
	 If l_row.list_line_type_code = 'PBH' Then
		   ---Update the qualifying child line with new operand
		   ---Set updated flag for all child lines to 'Y'
		   ---Remove in phase 3
		   /******************************
		   If l_row.updated_flag = 'Y' and l_row.operand is not null Then
			 For l_related_row in l_related_lines(l_row.id,l_row.cle_id) Loop
			     IF (l_debug = 'Y') THEN
   			     my_debug(' adjusted_amount line ' || l_related_row.adjusted_amount);
   			     my_debug(' range break line' || l_related_row.range_break_quantity);
                       my_debug('adjusted_amount hdr ' || l_row.adjusted_amount);
   			     my_debug('range break hdr' || l_row.range_break_quantity);
			     END IF;

                    If (nvl(l_related_row.range_break_quantity,-99) = l_row.range_break_quantity
			        and l_related_row.adjusted_amount is not null )

                    Then
			       Update okc_price_adjustments
				  set applied_flag = 'Y',
				      operand = l_row.operand,
					 updated_flag = 'Y'
				  where id = l_related_row.id;
				Else
				   Update okc_price_adjustments
				   set updated_flag = 'Y'
				   where id = l_related_row.id;
				End If;
			  End loop;
		     End If;
			********************************/
		     ---Remove in pase 3


               -- populate child lines and relationship lines

               pbh_index := j;
	       l_req_line_detail_tbl(j).price_break_type_code := l_row.price_break_type_code;
	       For l_related_row in l_related_lines(l_row.id,l_row.cle_id) Loop
			    j:= j+1;
			    l_req_line_detail_tbl(j).line_index := l_req_line_tbl(i).line_index;
			    l_req_line_detail_tbl(j).line_detail_index := j;

                            l_req_line_detail_tbl (j).list_line_no := l_related_row.list_line_no;
			    l_req_line_detail_tbl(j).pricing_phase_id := l_related_row.pricing_phase_id;
			    l_req_line_detail_tbl(j).list_header_id := l_related_row.list_header_id;
			    l_req_line_detail_tbl(j).list_line_id := l_related_row.list_line_id;
			    l_req_line_detail_tbl(j).list_line_type_code := l_related_row.list_line_type_code;
			    l_req_line_detail_tbl(j).created_from_list_type_code:= l_related_row.modifier_mechanism_type_code;
			    l_req_line_detail_tbl(j).automatic_flag := l_related_row.automatic_flag;
			    l_req_line_detail_tbl(j).applied_flag := l_related_row.applied_flag;
			    l_req_line_detail_tbl(j).updated_flag := l_related_row.updated_flag;
			    l_req_line_detail_tbl(j).operand_calculation_code := l_related_row.arithmetic_operator;
			    l_req_line_detail_tbl(j).operand_value := l_related_row.operand;
			    l_req_line_detail_tbl(j).modifier_level_code := l_related_row.modifier_level_code;
			    l_req_line_detail_tbl(j).override_flag := l_related_row.UPDATE_ALLOWED ;
			    l_req_line_detail_tbl(j).line_quantity := l_related_row.range_break_quantity;
			    l_req_line_detail_tbl(j).line_detail_type_code := 'CHILD_DETAIL_LINE';
			    l_req_line_detail_tbl(j).price_break_type_code := l_related_row.price_break_type_code;

                            --Populate relationship
			    l := nvl(l_Req_related_lines_tbl.last,0)+1;
			    l_req_related_lines_tbl(l).line_index :=  l_req_line_tbl(i).line_index ;
			    l_req_related_lines_tbl(l).LINE_DETAIL_INDEX := pbh_index;
			    l_req_related_lines_tbl(l).relationship_type_code := 'PBH_LINE';
			    --  l_req_related_lines_tbl(l).RELATED_LINE_INDEX     := ;
			    l_req_related_lines_tbl(l).related_line_detail_index := j;
               End loop;

            End If;
	    --Tope pbh changes


       End loop; --#1
       If l_chr%isopen then
          close l_chr;
       Elsif l_cle%isopen then
          close l_cle;
       End if;
      IF (l_debug = 'Y') THEN
         my_debug('16300 : Exiting load_applied_adjs', 2);
      END IF;
      IF (l_debug = 'Y') THEN
         okc_debug.Reset_Indentation;
      END IF;

      return l_return_status;
    exception
      When Others then
           OKC_API.set_message(p_app_name      => g_app_name,
                       p_msg_name      => g_unexpected_error,
                       p_token1        => g_sqlcode_token,
                       p_token1_value  => sqlcode,
                       p_token2        => g_sqlerrm_token,
                       p_token2_value  => sqlerrm);
            l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            If l_chr%isopen then
              close l_chr;
            Elsif l_cle%isopen then
              close l_cle;
            End if;
      IF (l_debug = 'Y') THEN
         my_debug('16400 : Exiting load_applied_adjs', 4);
      END IF;
      IF (l_debug = 'Y') THEN
         okc_debug.Reset_Indentation;
      END IF;

            return (l_return_status);
--????what about assocs(pbh)

   End load_applied_adjs;

Begin
--?????? validations- pricing config lines. p_chr_id is null
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('CALCULATE_PRICE');
    END IF;
    IF (l_debug = 'Y') THEN
       my_debug('16500 : Entering CALCULATE_PRICE', 2);
    END IF;

           x_return_status := OKC_API.G_RET_STS_SUCCESS;

           l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PROCESS',
                                               x_return_status);
           IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                    raise OKC_API.G_EXCEPTION_ERROR;
           END IF;

           IF p_control_rec.p_level = 'QA' THEN
              g_qa_mode := 'Y';
           ELSE
              g_qa_mode := 'N';
           END IF;

           IF l_okc_control_rec.p_calc_Flag <> 'C' then --calc flag
                -- header context has to be built anyways whether its header or line
                BUILD_CHR_CONTEXT(
                    p_api_version             => p_api_version,
                    p_init_msg_list           => p_init_msg_list,
                    p_request_type_code       => l_okc_control_rec.p_request_type_code,
                    p_chr_id                  => p_chr_id,
                    p_line_index              => 1,
                    x_pricing_contexts_Tbl    => l_hdr_prc_contexts_Tbl,
                    x_qualifier_contexts_Tbl  => l_hdr_qual_contexts_Tbl,
                    x_return_status           => x_return_status,
                    x_msg_count               => x_msg_count,
                    x_msg_data                => x_msg_data);
                  --dbms_output.put_line('4return status'||x_return_status);

                IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
                 RAISE OKC_API.G_EXCEPTION_ERROR;
                END IF;
               End If; -- p_calc_flag
              -- if not a configurated line
               If l_okc_control_rec.p_config_yn = 'N' then
                   --if already some priced lines are there in price tbl, move them to the tables
                   -- that we will use to send data
                    If px_cle_price_tbl.count <> 0 then
                         i:= px_cle_price_tbl.first;
                         while i is not null LOOP
                             l_priced_tbl(i)  := px_cle_price_tbl(i).id;
                             i:= px_cle_price_tbl.next(i);
                         END LOOP;
                         -- if no line was sent in, that means reprice all the lines
                         -- of the given conract. fetch them from database
                    ELSE
                          select id
                             BULK COLLECT into l_priced_tbl
                             from okc_k_lines_b where dnz_chr_id = p_chr_id
                             and price_level_ind ='Y';
                           IF (l_debug = 'Y') THEN
                              my_debug('16550 : select rowcount'||SQL%ROWCOUNT, 1);
                           END IF;

                    END IF;
                    If l_priced_tbl.count<1  then
                       IF l_okc_control_rec.p_level = 'QA' then
                           RAISE l_exception_STOP;
                      Else
                          OKC_API.set_message(p_app_name      => g_app_name,
                                              p_msg_name      => 'OKC_NO_QP_ROW');

                          l_return_status:= OKC_API.G_RET_STS_ERROR;
                          RAISE OKC_API.G_EXCEPTION_ERROR;

                      End IF;

                    End if;

                    px_cle_price_tbl.delete;
                    i:= l_priced_tbl.first;
                    j:=0;
                    --?????maybe we can do without initializing  global rec  here for better performance
                    OKC_PRICE_PUB.G_CONTRACT_INFO := null;
                    While i is not null LOOP -- l_priced_tbl loop
                         l_price_list:=null;
                         l_prc_Tbl.delete;
                         l_qual_Tbl.delete;
                         l_bpi_prc_Tbl.delete;
                         l_bpi_qual_Tbl.delete;

                         l_req_line_index := null;
                         get_line_ids (p_chr_id => p_chr_id,
                              p_cle_id         => l_priced_tbl(i) , --- priced line id
                              x_return_status  => l_return_status,
                              x_line_tbl       => l_line_tbl,
                              x_bpi_ind        => l_bpi_ind ,
                              x_pi_ind         => l_pi_ind);
                         IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                         ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
                            RAISE OKC_API.G_EXCEPTION_ERROR;
                         END IF;
                         If l_line_tbl.count = 0 then
                            IF (l_debug = 'Y') THEN
                               my_debug('16555 :Code error should not happen '||l_priced_tbl(i),2);
                            END IF;
                            OKC_API.set_message(p_app_name      => g_app_name,
                                                p_msg_name      => 'OKC_NO_ROW');
                             RAISE OKC_API.G_EXCEPTION_ERROR;
                         End If;
                          IF (l_debug = 'Y') THEN
                             my_debug('16556 :got line ids -count '||l_line_tbl.count,1);
                             my_debug('16557 :Id of the Priced line should be '||l_line_tbl(1).id,1);
                          END IF;

                         j:=j+1;
                         px_cle_price_tbl(j).id :=l_priced_tbl(i);
                         -- using index 1 here as Priced line should be the first one
                         IF (l_debug = 'Y') THEN
                            my_debug('16558 :first id for line tbl'||l_line_tbl(l_line_tbl.first).id,1);
                         END IF;

                         l_price_list:=l_line_tbl(l_line_tbl.first).pricelist_id;
                         px_cle_price_tbl(j).pricelist_id := l_price_list;
                         IF (l_debug = 'Y') THEN
                            my_debug('16560 : pricelist for priced line'||l_price_list, 1);
                         END IF;

                         px_cle_price_tbl(j).pi_bpi := 'P';
                         px_cle_price_tbl(j).uom_code:= l_line_tbl(l_line_tbl.first).uom_code;

                         If l_bpi_ind > 0 then
                            j:=j+1;
                            px_cle_price_tbl(j).id :=l_line_tbl(l_bpi_ind).id;
                            px_cle_price_tbl(j).pi_bpi := 'B';
                            --??????pricelist for pi and bpi will be same as per our design
                            px_cle_price_tbl(j).pricelist_id := l_price_list;
                         END IF;
                         IF (l_debug = 'Y') THEN
                            my_debug('16562 :  before calling create_request_line'||l_return_status);
                         END IF;
			     --Line Below commented for Bug 2403028, Results in ora-01403 when
			     -- user omits item_to_price in line style setup

                    --If l_line_tbl(l_pi_ind).service_yn = 'Y'then

			          If (l_pi_ind > 0 AND l_line_tbl(l_pi_ind).service_yn = 'Y') Then
                          Create_request_line_service(
                                             p_api_version             => p_api_version,
                                             p_init_msg_list           => p_init_msg_list,
                                             p_control_rec               => l_okc_control_rec,
                                             p_chr_id                  => p_chr_id,
                                             p_line_tbl                => l_line_tbl,
                                             p_pi_ind                  => l_pi_ind,
                                             p_bpi_ind                 => l_bpi_ind,
                                             p_pricing_event           => l_pricing_event,
                                             p_hdr_prc_contexts_Tbl    => l_hdr_prc_contexts_Tbl,
                                             p_hdr_qual_contexts_Tbl   => l_hdr_qual_contexts_Tbl,
                                             px_req_line_tbl           => l_req_line_tbl,
                                             px_Req_related_lines_tbl  => l_Req_related_lines_tbl,
                                             x_pricing_contexts_Tbl    => l_prc_Tbl,
                                             x_qualifier_contexts_Tbl  => l_qual_Tbl,
                                             x_return_status           => l_return_status,
                                             x_msg_count               => x_msg_count,
                                             x_msg_data                => x_msg_data);
                          --bug 2543687
					 l_check := 'NS';

                          IF (l_debug = 'Y') THEN
                             my_debug('16563 : after  calling create_request_line_service'||l_return_status);
                          END IF;
                        Else
                         Create_request_line(
                                             p_api_version             => p_api_version,
                                             p_init_msg_list           => p_init_msg_list,
                                             p_control_rec               => l_okc_control_rec,
                                             p_chr_id                  => p_chr_id,
                                             p_line_tbl                => l_line_tbl,
                                             p_pi_ind                  => l_pi_ind,
                                             p_bpi_ind                 => l_bpi_ind,
                                             p_pricing_event           => l_pricing_event,
                                             p_hdr_prc_contexts_Tbl    => l_hdr_prc_contexts_Tbl,
                                             p_hdr_qual_contexts_Tbl   => l_hdr_qual_contexts_Tbl,
                                             px_req_line_tbl           => l_req_line_tbl,
                                             px_Req_related_lines_tbl  => l_Req_related_lines_tbl,
                                             x_pricing_contexts_Tbl    => l_prc_Tbl,
                                             x_qualifier_contexts_Tbl  => l_qual_Tbl,
                                             x_return_status           => l_return_status,
                                             x_msg_count               => x_msg_count,
                                             x_msg_data                => x_msg_data);
                         IF (l_debug = 'Y') THEN
                            my_debug('16563 : after  calling create_request_line'||l_return_status);
                         END IF;
                        End If;
                        IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                                   RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                        ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
                                  RAISE OKC_API.G_EXCEPTION_ERROR;
                        END IF;
                        l_req_line_index := nvl(l_req_line_tbl.last,0);
                        If l_bpi_ind > 0 then
                            --loop and take out all the pricing attributes belonging to bpi
                            -- and put them in separate table
                            l_index := l_prc_Tbl.first;
                            while l_index is not null loop
                               If l_prc_Tbl(l_index).line_index = 2 then
                                  l_bpi_prc_tbl(l_index):= l_prc_Tbl(l_index);
                                  l_prc_Tbl.delete(l_index);
                               End If;
                               l_index:=l_prc_Tbl.next(l_index);
                            END LOOP;
                              --loop and take out all the qualifier attributes belonging to bpi
                            -- and put them in separate table
                            l_index := l_qual_Tbl.first;
                            while l_index is not null loop
                               If l_qual_Tbl(l_index).line_index = 2 then
                                  l_bpi_qual_tbl(l_index):= l_qual_Tbl(l_index);
                                  l_qual_Tbl.delete(l_index);
                               End If;
                               l_index:=l_qual_Tbl.next(l_index);
                            END LOOP;
                            IF  l_okc_control_rec.p_calc_Flag <> 'C' and l_req_line_index is not null then
                                 copy_attribs(
                                      l_req_line_index
                                     ,'N'
                                     ,l_bpi_prc_Tbl
                                     ,l_bpi_qual_Tbl
                                     ,l_pricing_contexts_tbl
                                     ,l_qualifiers_contexts_tbl);
                           End If;
                            -- since in case of bpi, first normal line is attached and then
                            -- bpi line is attached line_index for normal line would be
                            -- l_req_line_tbl.last-1
                            l_req_line_index := l_req_line_index -1;

                        End If;-- l_bpi_ind>0

                        IF (l_debug = 'Y') THEN
                           my_debug('16570 : request line index'||l_req_line_index);
                        END IF;

                        IF  l_okc_control_rec.p_calc_Flag <> 'C' and l_req_line_index is not null then
                           copy_attribs(
                                      l_req_line_index
                                     ,l_check
                                     ,l_prc_Tbl
                                     ,l_qual_Tbl
                                     ,l_pricing_contexts_tbl
                                     ,l_qualifiers_contexts_tbl);
                        End If;

                           i:=l_priced_tbl.next(i);
                    END LOOP; -- l_priced_tbl loop
           Elsif  l_okc_control_rec.p_config_yn in ('Y','S') then  --p_config_flag
           OKC_PRICE_PUB.G_CONTRACT_INFO:= null;
                If l_okc_control_rec.p_top_model_id is null then
                      OKC_API.set_message(p_app_name      => g_app_name,
                                   p_msg_name      => 'OKC_INVALID_TOP_MODEL');
                       RAISE OKC_API.G_EXCEPTION_ERROR;
                End if;
                If px_cle_price_tbl.count<1  then
                      OKC_API.set_message(p_app_name      => g_app_name,
                                   p_msg_name      => 'OKC_NO_QP_ROW');
                       RAISE OKC_API.G_EXCEPTION_ERROR;
                End if;
                Set_control_rec(l_okc_control_rec);
                l_control_rec := l_okc_control_rec.qp_control_rec;
                l_line_tbl.delete;

                  --collect all the line styles and rules and party roles attached to lines above configurated lines
                  select id
                  BULK COLLECT INTO l_id_tbl
                  from okc_k_lines_b
                  connect by prior cle_id = id
                  start with id=l_okc_control_rec.p_top_model_id;
                  --dbms_output.put_line('rows found'||l_id_tbl.count);
                  IF (l_debug = 'Y') THEN
                     my_debug('16650 : select rowcount'||SQL%ROWCOUNT, 1);
                  END IF;

                  i:= l_id_tbl.first;
                  while i is not null LOOP --#2config
                                    --dbms_output.put_line('san while'||l_id_tbl(i));

                    BEGIN
                      SELECT object1_id1, object1_id2, jtot_object1_code
                      into l_id1,l_id2,l_jtot1_code
                      FROM okc_k_items
                      where cle_id = l_id_tbl(i) and dnz_chr_id=p_chr_id;
                                                          --dbms_output.put_line('while again'||l_id_tbl(i));
                       IF (l_debug = 'Y') THEN
                          my_debug('16700 : select rowcount'||SQL%ROWCOUNT, 1);
                       END IF;

                      l_line_tbl(i).id:= l_id_tbl(i);
                      l_line_tbl(i).object_code:=l_jtot1_code ;
                      l_line_tbl(i).id1:=l_id1;
                      l_line_tbl(i).id2:=l_id2;
                      -- populate global top model intevnetory item id with this value
                      IF l_id_tbl(i) = l_okc_control_rec.p_top_model_id then
                         OKC_PRICE_PUB.G_CONTRACT_INFO.top_model_line_id:= l_id1;
                      END IF;
                      i:=l_id_tbl.next(i);
                    EXCEPTION
                      WHEN NO_DATA_FOUND then
                                                          --dbms_output.put_line('no data');

                         l_line_tbl(i).id:= l_id_tbl(i);
                    END;
                  End Loop; --#2config
                                                      --dbms_output.put_line('out of loop');

                  i:=px_cle_price_tbl.first;

                  while i is not null loop--#3config

                  --??????? an issue here that build_context has to be called now for each line as the
                  --following values will differ.
                  OKC_PRICE_PUB.G_CONTRACT_INFO.inventory_item_id := px_cle_price_tbl(i).id1;
                  /*-- here the assumption is that out of the pl/sql tbl sent by configurtor cal
                  -- the first record is the one with the top model line. hence
                  -- picking its inventory_item_id
                  If i = px_cle_price_tbl.first then
                   OKC_PRICE_PUB.G_CONTRACT_INFO.top_model_line_id:= px_cle_price_tbl(i).id1;
                  end if;*/
                   BUILD_CLE_CONTEXT(
                        p_api_version             => p_api_version,
                        p_init_msg_list           => p_init_msg_list,
                        p_request_type_code       => l_okc_control_rec.p_Request_Type_Code,
                        p_chr_id                  => p_chr_id,
                        P_line_tbl                => l_line_tbl,
                        p_line_index              => i,
                        x_pricing_contexts_Tbl    => l_prc_Tbl,
                        x_qualifier_contexts_Tbl  => l_qual_Tbl,
                        x_return_status           => l_return_status,
                        x_msg_count               => x_msg_count,
                        x_msg_data                => x_msg_data);
                      IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                      ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
                           RAISE OKC_API.G_EXCEPTION_ERROR;
                      END IF;
                      --dbms_output.put_line('config 1');

                      --attach header attribs
                       If (l_hdr_prc_contexts_Tbl.count >0 or l_hdr_qual_contexts_Tbl.count>0) then
                        copy_attribs(
                             i
                            ,'Y'
                            ,l_hdr_prc_contexts_Tbl
                            ,l_hdr_qual_contexts_Tbl
                            ,l_prc_Tbl
                            ,l_qual_Tbl);
                      END IF;
                    -- build context done

                      l_pricing_contexts_Tbl(i).line_index := i;
                      l_pricing_contexts_Tbl(i).PRICING_CONTEXT :='ITEM';
                      l_pricing_contexts_Tbl(i).PRICING_ATTRIBUTE :='PRICING_ATTRIBUTE1';
                      l_pricing_contexts_Tbl(i).PRICING_ATTR_VALUE_FROM  := px_cle_price_tbl(i).id1; -- Inventory Item Id
                      l_pricing_contexts_Tbl(i).VALIDATED_FLAG :='N';

                      IF   px_cle_price_tbl(i).pricelist_id is not null
                           and  px_cle_price_tbl(i).pricelist_id <> OKC_API.G_MISS_NUM then
                            l_qualifiers_contexts_Tbl(i).LINE_INDEX := i;
                            l_qualifiers_contexts_Tbl(i).QUALIFIER_CONTEXT :='MODLIST';
                            l_qualifiers_contexts_Tbl(i).QUALIFIER_ATTRIBUTE :='QUALIFIER_ATTRIBUTE4';
                            l_qualifiers_contexts_Tbl(i).QUALIFIER_ATTR_VALUE_FROM := to_char(px_cle_price_tbl(i).pricelist_id); -- Price List Id
                            l_qualifiers_contexts_Tbl(i).COMPARISON_OPERATOR_CODE := '=';
                            --l_qualifiers_contexts_Tbl(i).VALIDATED_FLAG :='Y';
                            l_qualifiers_contexts_Tbl(i).VALIDATED_FLAG :='N'; --Bug 2760904: we need QP to validate the price list
                      Else
                         px_cle_price_tbl(i).pricelist_id:=g_hdr_pricelist;
                      END IF;

                   	   l_req_line_tbl(i).Line_id := px_cle_price_tbl(i).id;
	                   l_req_line_tbl(i).REQUEST_TYPE_CODE := l_okc_control_rec.p_Request_Type_Code;
	                   l_req_line_tbl(i).LINE_INDEX     := i;
	                   l_req_line_tbl(i).LINE_TYPE_CODE  := 'LINE';
                --       l_req_line_tbl(i).PRICING_EFFECTIVE_DATE := trunc(sysdate);--???? is sysdate fine?
                       l_req_line_tbl(i).PRICING_EFFECTIVE_DATE := nvl(px_cle_price_tbl(i).pricing_date,g_hdr_pricing_date);
			  l_req_line_tbl(i).LINE_QUANTITY   := px_cle_price_tbl(i).qty ;
                       l_req_line_tbl(i).LINE_UOM_CODE   := px_cle_price_tbl(i).uom_code;
	                   l_req_line_tbl(i).CURRENCY_CODE   := px_cle_price_tbl(i).currency;
                       l_req_line_tbl(i).PRICE_FLAG := 'Y';
                       If (l_prc_Tbl.count >0 or l_qual_Tbl.count>0) then
                        copy_attribs(
                             i
                            ,'N'
                            ,l_prc_Tbl
                            ,l_qual_Tbl
                            ,l_pricing_contexts_Tbl
                            ,l_qualifiers_contexts_Tbl);
                      END IF;
                      --dbms_output.put_line('config 3');

                    i:=px_cle_price_tbl.next(i);
                  End loop;--#3config

           Else   --p_config_flag
                --dbms_output.put_line('code error: config flag should be Y or N');
                null;
           End If;--p_config_yn
            -- create header request line everytime irrespective of p_level
           Begin
                select currency_code
                into l_curr
                from okc_k_headers_b
                where id = p_chr_id;
                IF (l_debug = 'Y') THEN
                   my_debug('16750 : select rowcount'||SQL%ROWCOUNT, 1);
                END IF;

                EXCEPTION
                      WHEN NO_DATA_FOUND then
                       l_curr:='USD';
           END;

          l_line_index := l_req_line_tbl.count+1;
          l_req_line_tbl(l_line_index).REQUEST_TYPE_CODE :=l_okc_control_rec.p_request_type_code;
          l_req_line_tbl(l_line_index).PRICING_EVENT :=l_pricing_event;
          l_req_line_tbl(l_line_index).LINE_INDEX := l_line_index;
          l_req_line_tbl(l_line_index).LINE_TYPE_CODE := 'ORDER';

          -- Hold the header_id in line_id for 'HEADER' Records

          l_req_line_tbl(l_line_index).line_id := p_chr_id;
          --l_req_line_tbl(l_line_index).PRICING_EFFECTIVE_DATE := trunc(sysdate);
          l_req_line_tbl(l_line_index).PRICING_EFFECTIVE_DATE := g_hdr_pricing_date;
          l_req_line_tbl(l_line_index).CURRENCY_CODE := l_curr;
          -- Ask for pricing the Header only if we are pricing the whole contract or
          -- QA
          If l_okc_control_rec.p_level in ('H','QA')  then
	              l_req_line_tbl(l_line_index).PRICE_FLAG := 'Y';
          ELSE
          	      l_req_line_tbl(l_line_index).PRICE_FLAG := 'N';

          END IF;
          IF  l_okc_control_rec.p_calc_Flag <> 'C' then

           --attach header context
             copy_attribs(
               l_req_line_tbl.count
              ,'N'
              ,l_hdr_prc_contexts_Tbl
              ,l_hdr_qual_contexts_Tbl
              ,l_pricing_contexts_tbl
              ,l_qualifiers_contexts_tbl);
           End If;
           -- load the applied adjustments for the all the request lines
          i:= l_req_line_tbl.first;
          while i is not null loop
               l_return_status :=load_applied_adjs(i);
               IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
                  RAISE OKC_API.G_EXCEPTION_ERROR;
               END IF;

             i:=l_req_line_tbl.next(i);
          End loop;

                --assuming pi line with bpi is last and in case of header, header line is last
                --??? assuming they come back in the same order as they were sent
          BEGIN
--dbmsoutput area

               IF (l_debug = 'Y') THEN
                  my_debug('16800:+---------Information Returned to Caller before price request---------------------+ ');
               END IF;

               IF (l_debug = 'Y') THEN
                  my_debug('16802:-------------Request Line Information Sent IN------------------');
               END IF;
               I := l_req_line_tbl.FIRST;
IF I IS NOT NULL THEN
 LOOP
 	      IF (l_debug = 'Y') THEN
    	      my_debug('16803:.Line Id: '||l_req_line_tbl(I).line_id);
   	      my_debug('16804:.REQUEST_TYPE_CODE: '||l_req_line_tbl(I).REQUEST_TYPE_CODE);
   	      my_debug('16806:.LINE_TYPE_CODE: '||l_req_line_tbl(I).LINE_TYPE_CODE);
             my_debug('16808:.PRICING_EFFECTIVE_DATE: '||l_req_line_tbl(I).PRICING_EFFECTIVE_DATE );
   	      my_debug('16810:.LINE_QUANTITY: '||l_req_line_tbl(I).LINE_QUANTITY);
 	      END IF;

          IF (l_debug = 'Y') THEN
             my_debug('16812:.LINE_UOM_CODE: '||l_req_line_tbl(I).LINE_UOM_CODE);
   	      my_debug('16814:.CURRENCY_CODE: '||l_req_line_tbl(I).CURRENCY_CODE);
             my_debug('16816:.PRICE_FLAG: '||l_req_line_tbl(I).PRICE_FLAG);
          END IF;

          IF (l_debug = 'Y') THEN
             my_debug('16818:Line Index: '||l_req_line_tbl(I).line_index);
             my_debug('16820:Unit_price: '||l_req_line_tbl(I).unit_price);
             my_debug('16822:Percent price: '||l_req_line_tbl(I).percent_price);
             my_debug('16824:Adjusted Unit Price: '||l_req_line_tbl(I).adjusted_unit_price);
             my_debug('16826:UPDATED_ADJUSTED_UNIT_PRICE: '||l_req_line_tbl(I).UPDATED_ADJUSTED_UNIT_PRICE);
             my_debug('16828:Pricing status code: '||l_req_line_tbl(I).status_code);
             my_debug('16830:Pricing status text: '||l_req_line_tbl(I).status_text);
             my_debug('16832:phase san'||l_req_line_tbl(I).pricing_phase_id);
          END IF;

  EXIT WHEN I = l_req_line_tbl.LAST;
  I := l_req_line_tbl.NEXT(I);
 END LOOP;
END IF;

I := l_req_line_detail_tbl.FIRST;

IF (l_debug = 'Y') THEN
   my_debug('16834:------------Price List/Discount Information Sent In------------');
END IF;

IF I IS NOT NULL THEN
 LOOP
   IF (l_debug = 'Y') THEN
      my_debug('16834:I: '||I);
     my_debug('16836:Line Index: '||l_req_line_detail_tbl(I).line_index);
     my_debug('16838:Line Detail Index: '||l_req_line_detail_tbl(I).line_detail_index);
     my_debug('16840:Line Detail Type:'||l_req_line_detail_tbl(I).line_detail_type_code);
     my_debug('16840:Modifier level Code:'||l_req_line_detail_tbl(I).modifier_level_code);
     my_debug('16842:List Header Id: '||l_req_line_detail_tbl(I).list_header_id);
     my_debug('16844:List Line Id: '||l_req_line_detail_tbl(I).list_line_id);
     my_debug('16845:List Line Number: '||l_req_line_detail_tbl(I).list_line_no);
     my_debug('16846:List Line Type Code: '||l_req_line_detail_tbl(I).list_line_type_code);
     my_debug('16848:created from Type Code: '||l_req_line_detail_tbl(I).created_from_list_type_code);
     my_debug('16850:Adjustment Amount : '||l_req_line_detail_tbl(I).adjustment_amount);
     my_debug('16852:Line Quantity : '||l_req_line_detail_tbl(I).line_quantity);
     my_debug('16854:Operand Calculation Code: '||l_req_line_detail_tbl(I).Operand_calculation_code);
     my_debug('16856:Operand value: '||l_req_line_detail_tbl(I).operand_value);
     my_debug('16858:Automatic Flag: '||l_req_line_detail_tbl(I).automatic_flag);
     my_debug('16860:Override Flag: '||l_req_line_detail_tbl(I).override_flag);
     my_debug('16862:Applied flag: '||l_req_line_detail_tbl(I).applied_flag);
     my_debug('16864:Updated Flag: '||l_req_line_detail_tbl(I).UPDATED_FLAG);
     my_debug('16866:status_code: '||l_req_line_detail_tbl(I).status_code);
     my_debug('16868:status text: '||l_req_line_detail_tbl(I).status_text);
     my_debug('16870:-------------------------------------------');
   END IF;
  EXIT WHEN I =  l_req_line_detail_tbl.LAST;
  I := l_req_line_detail_tbl.NEXT(I);
 END LOOP;
END IF;
 IF (l_debug = 'Y') THEN
    my_debug('16872:--------------Pricng Context Information Sent In --------------');
 END IF;

IF (l_debug = 'Y') THEN
   my_debug('16874:starting PA '||l_pricing_contexts_tbl.count);
END IF;
If l_pricing_contexts_tbl.count >0 then
      i:=l_pricing_contexts_tbl.first;
      loop
          IF (l_debug = 'Y') THEN
             my_debug('16876:index '||l_pricing_contexts_tbl(i).line_index);
             my_debug('16878:context '||l_pricing_contexts_tbl(i).pricing_context);
             my_debug('16880:attribute'||l_pricing_contexts_tbl(i).pricing_attribute);
             my_debug('16882:pricing_attr_value_from '||l_pricing_contexts_tbl(i).pricing_attr_value_from);
             my_debug('16884:validated '||l_pricing_contexts_tbl(i).validated_flag);
             my_debug('16886:status code '||l_pricing_contexts_tbl(i).status_code);
             my_debug('16888:status text '||l_pricing_contexts_tbl(i).status_text);
          END IF;
          exit when i=l_pricing_contexts_tbl.last;
          i:= l_pricing_contexts_tbl.next(i);
      end loop;
end if;
 IF (l_debug = 'Y') THEN
    my_debug('16890:--------------Qual Context Information Sent In --------------');
   my_debug('16892:starting  QA'||l_qualifiers_contexts_tbl.count);
 END IF;
If l_qualifiers_contexts_tbl.count >0 then
      i:=l_qualifiers_contexts_tbl.first;
      loop
         IF (l_debug = 'Y') THEN
            my_debug('16894:index '||l_qualifiers_contexts_tbl(i).line_index);
             my_debug('16896:starting SAN QA '||i||'-'||l_qualifiers_contexts_tbl(i).qualifier_context);
             my_debug('16900:starting SAN QA '||i||'-'||l_qualifiers_contexts_tbl(i).qualifier_attribute);
             my_debug('16902:starting SAN QA '||i||'-'||l_qualifiers_contexts_tbl(i).qualifier_attr_value_from);
             my_debug('16904:validated '||l_qualifiers_contexts_tbl(i).validated_flag);
             my_debug('16906:status code '||l_qualifiers_contexts_tbl(i).status_code);
             my_debug('16908:status text '||l_qualifiers_contexts_tbl(i).status_text);
         END IF;

          exit when i=l_qualifiers_contexts_tbl.last;
          i:= l_qualifiers_contexts_tbl.next(i);
      end loop;
end if;

IF (l_debug = 'Y') THEN
   my_debug('16910:--------------Related Lines Information Sent In for Price Breaks/Service Items---------------');
END IF;
I := l_req_related_lines_tbl.FIRST;
IF I IS NOT NULL THEN
 LOOP
  IF (l_debug = 'Y') THEN
     my_debug('16912:Line Index :'||l_req_related_lines_tbl(I).line_index);
     my_debug('16914:Line Detail Index: '||l_req_related_lines_tbl(I).LINE_DETAIL_INDEX);
     my_debug('16916:Relationship Type Code: '||l_req_related_lines_tbl(I).relationship_type_code);
     my_debug('16918:Related Line Index: '||l_req_related_lines_tbl(I).RELATED_LINE_INDEX);
     my_debug('16920:Related Line Detail Index: '||l_req_related_lines_tbl(I).related_line_detail_index);
     my_debug('16922:Status Code: '|| l_req_related_lines_tbl(I).STATUS_CODE);
  END IF;
  EXIT WHEN I =  l_req_related_lines_tbl.LAST;
  I :=  l_req_related_lines_tbl.NEXT(I);
 END LOOP;
END IF;
-- dbmsoutput area*/
             IF (l_debug = 'Y') THEN
                my_debug('16924:Before Calling Price Request calculate flag'||l_control_rec.calculate_flag);
             END IF;
             QP_PREQ_PUB.PRICE_REQUEST
             --QP_PREQ_GRP.PRICE_REQUEST
		           (p_control_rec	 	    => l_control_rec
		           ,p_line_tbl              => l_Req_line_tbl
 		           ,p_qual_tbl              => l_qualifiers_contexts_tbl
  		           ,p_line_attr_tbl         => l_pricing_contexts_tbl
		           ,p_line_detail_tbl       => l_req_line_detail_tbl
	 	           ,p_line_detail_qual_tbl  => l_req_line_detail_qual_tbl
	  	           ,p_line_detail_attr_tbl  => l_req_line_detail_attr_tbl
	   	           ,p_related_lines_tbl     => l_req_related_lines_tbl
		           ,x_line_tbl              => px_req_line_tbl
	   	           ,x_line_qual             => px_Req_qual_tbl
	    	       ,x_line_attr_tbl         => px_Req_line_attr_tbl
		           ,x_line_detail_tbl       => px_req_line_detail_tbl
	 	           ,x_line_detail_qual_tbl  => px_req_line_detail_qual_tbl
 	  	           ,x_line_detail_attr_tbl  => px_req_line_detail_attr_tbl
	   	           ,x_related_lines_tbl     => px_req_related_line_tbl
	    	       ,x_return_status         => l_return_status
	    	       ,x_return_status_Text    => l_return_status_Text
		           );
                IF (l_debug = 'Y') THEN
                   my_debug('16925:After Calling Price Request. Return status'||l_return_status);
                END IF;

                 IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                   RAISE l_exception_stop;
                 END IF;

                 Exception
                  WHEN l_exception_stop THEN
                   OKC_API.set_message(p_app_name      => g_app_name,
                                   p_msg_name      => 'OKC_QP_PRICE_ERROR',
                                   p_token1        => 'Proc',
                                   p_token1_value  => 'Price Request',
                                   p_token2        => 'err_text',
                                   p_token2_value  => l_return_status_text);
                   If l_return_status = OKC_API.G_RET_STS_ERROR then
                     Raise OKC_API.G_EXCEPTION_ERROR;
                   ELSE
                     RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                   END IF;

                  when others then
                    IF (l_debug = 'Y') THEN
                       my_debug('16926:error'||substr(sqlerrm,1,240));
                    END IF;
                    OKC_API.set_message(p_app_name      => g_app_name,
                                   p_msg_name      => 'OKC_QP_INT_ERROR',
                                   p_token1        => 'Proc',
                                   p_token1_value  => 'Price Request',
                                   p_token2        => 'SQLCODE',
                                   p_token2_value  => SQLCODE,
                                   p_token3        => 'SQLERRM',
                                   p_token3_value  => SQLERRM);
                    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;

            END;
             --dbmsoutput area
              IF (l_debug = 'Y') THEN
                 my_debug('16928:lines sent in'||l_req_line_tbl.count);
              END IF;

              IF (l_debug = 'Y') THEN
                 my_debug('16930:-------------Request Line Information Sent out------------------'||px_req_line_tbl.count);
              END IF;

I := px_req_line_tbl.FIRST;
IF I IS NOT NULL THEN
 LOOP
  IF (l_debug = 'Y') THEN
     my_debug('16931:Line id: '||px_req_line_tbl(I).line_id);
     my_debug('16932:Line Index: '||px_req_line_tbl(I).line_index);
     my_debug('16934:Unit_price: '||px_req_line_tbl(I).unit_price);
     my_debug('16936:list type code: '||px_req_line_tbl(I).line_type_code);
     my_debug('16938:Percent price: '||px_req_line_tbl(I).percent_price);
     my_debug('16940:Adjusted Unit Price: '||px_req_line_tbl(I).adjusted_unit_price);
     my_debug('16942:UPDATED_ADJUSTED_UNIT_PRICE: '||px_req_line_tbl(I).UPDATED_ADJUSTED_UNIT_PRICE);
     my_debug('16944:Pricing status code: '||px_req_line_tbl(I).status_code);
     my_debug('16946:Pricing status text: '||px_req_line_tbl(I).status_text);
     my_debug('16948:phase san'||px_req_line_tbl(I).pricing_phase_id);
     my_debug('16950:PROCESS CODE: '||px_req_line_tbl(I).PROCESSED_CODE);
     my_debug('16952:Line Qty: '||px_req_line_tbl(I).line_quantity);
     my_debug('16954:Line UOM Code: '||px_req_line_tbl(I).line_uom_code);
     my_debug('16956:Priced Qty: '||px_req_line_tbl(I).priced_quantity);
     my_debug('16958:priced UOM Code: '||px_req_line_tbl(I).priced_uom_code);
     my_debug('16959:Pricing_date : '||px_req_line_tbl(I).pricing_effective_date);
  END IF;

  EXIT WHEN I = px_req_line_tbl.LAST;
  I := px_req_line_tbl.NEXT(I);
 END LOOP;
END IF;
  IF (l_debug = 'Y') THEN
     my_debug('16960:--------------Pricng Context  --------------');
  END IF;

IF (l_debug = 'Y') THEN
   my_debug('16962:starting  '||px_Req_line_attr_tbl.count);
END IF;
If px_Req_line_attr_tbl.count >0 then
      i:=px_Req_line_attr_tbl.first;
      loop
          IF (l_debug = 'Y') THEN
             my_debug('16964:index '||px_Req_line_attr_tbl(i).line_index);
             my_debug('16966:context '||px_Req_line_attr_tbl(i).pricing_context);
             my_debug('16968:attribute'||px_Req_line_attr_tbl(i).pricing_attribute);
             my_debug('16970:pricing_attr_value_from '||px_Req_line_attr_tbl(i).pricing_attr_value_from);
             my_debug('16972:validated '||px_Req_line_attr_tbl(i).validated_flag);
             my_debug('16974:status code '||px_Req_line_attr_tbl(i).status_code);
             my_debug('16976:status text '||px_Req_line_attr_tbl(i).status_text);
          END IF;

          exit when i=px_Req_line_attr_tbl.last;
          i:= px_Req_line_attr_tbl.next(i);
      end loop;
end if;
 IF (l_debug = 'Y') THEN
    my_debug('16978:--------------Qual Context Information--------------');
   my_debug('16980:starting  QA'||px_Req_qual_tbl.count);
 END IF;
If px_Req_qual_tbl.count >0 then
      i:=px_Req_qual_tbl.first;
      loop
          IF (l_debug = 'Y') THEN
             my_debug('16982:index '||px_Req_qual_tbl(i).line_index);
             my_debug('16984:context '||i||'-'||px_Req_qual_tbl(i).qualifier_context);
             my_debug('16986:attrib '||i||'-'||px_Req_qual_tbl(i).qualifier_attribute);
             my_debug('16988:from'||i||'-'||px_Req_qual_tbl(i).qualifier_attr_value_from);
             my_debug('16990:validated '||px_Req_qual_tbl(i).validated_flag);
             my_debug('16992:status code '||px_Req_qual_tbl(i).status_code);
             my_debug('16994:status text '||px_Req_qual_tbl(i).status_text);
          END IF;

          exit when i=px_Req_qual_tbl.last;
          i:= px_Req_qual_tbl.next(i);
      end loop;
end if;
IF (l_debug = 'Y') THEN
   my_debug('16996:-----------Pricing Attributes Information-------------');
   my_debug('16997:starting  PA'||px_req_line_detail_attr_tbl.count);
END IF;
I := px_req_line_detail_attr_tbl.FIRST;
IF I IS NOT NULL THEN
 LOOP

  IF (l_debug = 'Y') THEN
     my_debug('16998:Line detail Index '||px_req_line_detail_attr_tbl(I).line_detail_index);
     my_debug('16999:Context '||px_req_line_detail_attr_tbl(I).pricing_context);
     my_debug('17000:Attribute '||px_req_line_detail_attr_tbl(I).pricing_attribute);
     my_debug('17002:Value '||px_req_line_detail_attr_tbl(I).pricing_attr_value_from);
  END IF;
--  my_debug('17004:validated '||l_pricing_contexts_tbl(i).validated_flag);
  --my_debug('17006:status code '||l_pricing_contexts_tbl(i).status_code);
 -- my_debug('17008:status text '||l_pricing_contexts_tbl(i).status_text);

  IF (l_debug = 'Y') THEN
     my_debug('17010:---------------------------------------------------');
  END IF;

  EXIT WHEN I = px_req_line_detail_attr_tbl.last;
  I:=px_req_line_detail_attr_tbl.NEXT(I);

 END LOOP;
END IF;

IF (l_debug = 'Y') THEN
   my_debug('17012:-----------Qualifier Attributes Information-------------');
END IF;

I := px_req_line_detail_qual_tbl.FIRST;
IF I IS NOT NULL THEN
 LOOP
  IF (l_debug = 'Y') THEN
     my_debug('17014:Line Detail Index '||px_req_line_detail_qual_tbl(I).line_detail_index);
     my_debug('17018:Context '||px_req_line_detail_qual_tbl(I).qualifier_context);
     my_debug('17020:Attribute '||px_req_line_detail_qual_tbl(I).qualifier_attribute);
     my_debug('17022:Value '||px_req_line_detail_qual_tbl(I).qualifier_attr_value_from);
     my_debug('17024:Status Code '||px_req_line_detail_qual_tbl(I).status_code);
     my_debug('17026:---------------------------------------------------');
  END IF;

  EXIT WHEN I = px_req_line_detail_qual_tbl.last;
  I:=px_req_line_detail_qual_tbl.NEXT(I);

 END LOOP;
END IF;
I := px_req_line_detail_tbl.FIRST;

IF (l_debug = 'Y') THEN
   my_debug('17028:------------Price List/Discount Information------------');
END IF;

IF I IS NOT NULL THEN
 LOOP
   IF (l_debug = 'Y') THEN
      my_debug('17030:I: '||I);
     my_debug('17032:Line Index: '||px_req_line_detail_tbl(I).line_index);
     my_debug('17034:Line Detail Index: '||px_req_line_detail_tbl(I).line_detail_index);
     my_debug('17036:Line Detail Type:'||px_req_line_detail_tbl(I).line_detail_type_code);
     my_debug('17036:Modifier level code:'||px_req_line_detail_tbl(I).modifier_level_code);
     my_debug('17038:List Header Id: '||px_req_line_detail_tbl(I).list_header_id);
     my_debug('17040:List Line Id: '||px_req_line_detail_tbl(I).list_line_id);
     my_debug('17041:List Line Number: '||px_req_line_detail_tbl(I).list_line_no);
     my_debug('17042:List Line Type Code: '||px_req_line_detail_tbl(I).list_line_type_code);
     my_debug('17044:created from Type Code: '||px_req_line_detail_tbl(I).created_from_list_type_code);
     my_debug('17046:Adjustment Amount : '||px_req_line_detail_tbl(I).adjustment_amount);
     my_debug('17048:Line Quantity : '||px_req_line_detail_tbl(I).line_quantity);
     my_debug('17050:Operand Calculation Code: '||px_req_line_detail_tbl(I).Operand_calculation_code);
     my_debug('17052:Operand value: '||px_req_line_detail_tbl(I).operand_value);
     my_debug('17054:Automatic Flag: '||px_req_line_detail_tbl(I).automatic_flag);
     my_debug('17056:Override Flag: '||px_req_line_detail_tbl(I).override_flag);
     my_debug('17058:Applied flag: '||px_req_line_detail_tbl(I).applied_flag);
     my_debug('17060:Updated Flag: '||px_req_line_detail_tbl(I).UPDATED_FLAG);
     my_debug('17062:PROCESS CODE: '||px_req_line_detail_tbl(I).PROCESS_CODE);
     my_debug('17064:status_code: '||px_req_line_detail_tbl(I).status_code);
     my_debug('17066:status text: '||px_req_line_detail_tbl(I).status_text);
     my_debug('17068:-------------------------------------------');
   END IF;
  EXIT WHEN I =  px_req_line_detail_tbl.LAST;
  I := px_req_line_detail_tbl.NEXT(I);
 END LOOP;
END IF;




IF (l_debug = 'Y') THEN
   my_debug('17070:--------------Related Lines Information for Price Breaks/Service Items---------------');
END IF;
I := px_req_related_line_tbl.FIRST;
IF I IS NOT NULL THEN
 LOOP
  IF (l_debug = 'Y') THEN
     my_debug('17072:Line Index :'||px_req_related_line_tbl(I).line_index);
     my_debug('17074:Line Detail Index: '||px_req_related_line_tbl(I).LINE_DETAIL_INDEX);
     my_debug('17076:Relationship Type Code: '||px_req_related_line_tbl(I).relationship_type_code);
     my_debug('17078:Related Line Index: '||px_req_related_line_tbl(I).RELATED_LINE_INDEX);
     my_debug('17080:Related Line Detail Index: '||px_req_related_line_tbl(I).related_line_detail_index);
     my_debug('17082:Status Code: '|| px_req_related_line_tbl(I).STATUS_CODE);
  END IF;
  EXIT WHEN I =  px_req_related_line_tbl.LAST;
  I :=  px_req_related_line_tbl.NEXT(I);
 END LOOP;
END IF;
--san */

            ----end dbmsoutput area
            -- nulligy body local tables
            g_hdr_rul_tbl.delete;
            g_hdr_prle_tbl.delete;
            g_hdr_pricelist :=null;
          --return lines and prices and any errors if any.
          IF (l_debug = 'Y') THEN
             my_debug('17084:Before Calling process_adjustments'||px_CLE_PRICE_TBL.count);
          END IF;

          PROCESS_ADJUSTMENTS(p_api_version               =>  p_api_version,
                              p_CHR_ID                     => p_chr_id,
                              p_Control_Rec			       => l_okc_control_rec,
                              p_req_line_tbl               => px_req_line_tbl,
                              p_Req_LINE_DETAIL_tbl        => px_req_line_detail_tbl,
                              p_Req_LINE_DETAIL_qual_tbl   => px_req_line_detail_qual_tbl,
                              p_Req_LINE_DETAIL_attr_tbl   => px_req_line_detail_attr_tbl,
                              p_Req_RELATED_LINE_TBL       => px_req_related_line_tbl,
                              px_CLE_PRICE_TBL		       => px_CLE_PRICE_TBL,
                              x_return_status              => l_return_status,
                              x_msg_count                  => x_msg_count,
                              x_msg_data                   => x_msg_data);

          IF (l_debug = 'Y') THEN
             my_debug('17090:After calling process_adjustments'||l_return_status);
          END IF;

                  IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                             RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
                             RAISE OKC_API.G_EXCEPTION_ERROR;
                  ELSIF l_return_status = G_SOME_LINE_ERRORED THEN
                           x_return_status := l_return_status;

                  END IF;


    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       my_debug('17096 : Exiting CALCULATE_PRICE', 2);
    END IF;
    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;


    EXCEPTION
          when l_exception_stop then
              x_return_status:= OKC_API.G_RET_STS_SUCCESS;
              RAISE l_exception_stop;
              IF (l_debug = 'Y') THEN
                 my_debug('17690 : Exiting CALCULATE_PRICE', 4);
              END IF;
              IF (l_debug = 'Y') THEN
                 okc_debug.Reset_Indentation;
              END IF;

          WHEN OKC_API.G_EXCEPTION_ERROR THEN
              x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                       'OKC_API.G_RET_STS_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');
         IF (l_debug = 'Y') THEN
            my_debug('17700 : Exiting CALCULATE_PRICE', 4);
         END IF;
         IF (l_debug = 'Y') THEN
            okc_debug.Reset_Indentation;
         END IF;

         WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
              x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                       'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');
         IF (l_debug = 'Y') THEN
            my_debug('17800 : Exiting CALCULATE_PRICE', 4);
         END IF;
         IF (l_debug = 'Y') THEN
            okc_debug.Reset_Indentation;
         END IF;

         WHEN OTHERS THEN
              OKC_API.set_message(p_app_name      => g_app_name,
                                 p_msg_name      => g_unexpected_error,
                                 p_token1        => g_sqlcode_token,
                                 p_token1_value  => sqlcode,
                                 p_token2        => g_sqlerrm_token,
                                 p_token2_value  => sqlerrm);
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
         IF (l_debug = 'Y') THEN
            my_debug('17898 : error ocurred'||sqlcode||sqlerrm, 4);
         END IF;

         IF (l_debug = 'Y') THEN
            my_debug('17900 : Exiting CALCULATE_PRICE', 4);
         END IF;
         IF (l_debug = 'Y') THEN
            okc_debug.Reset_Indentation;
         END IF;

END CALCULATE_price;


----------------------------------------------------------------------------
-- GET_MANUAL_ADJUSTMENTS
-- This procedure will return all the manual adjustments that qualify for the
-- sent in lines and header
-- To get adjustments for a line pass p_cle_id and p_control_rec.p_level='L'
-- To get adjustments for a Header pass p_cle_id as null and p_control_rec.p_level='H'
----------------------------------------------------------------------------
PROCEDURE get_manual_adjustments(
          p_api_version                 IN          NUMBER,
          p_init_msg_list               IN          VARCHAR2 ,
          p_CHR_ID                      IN          NUMBER,
          p_cle_id                      IN          number                     ,
          p_Control_Rec			        IN          OKC_CONTROL_REC_TYPE,
          x_ADJ_tbl                     OUT  NOCOPY MANUAL_Adj_Tbl_Type,
          x_return_status               OUT  NOCOPY VARCHAR2,
          x_msg_count                   OUT  NOCOPY NUMBER,
          x_msg_data                    OUT  NOCOPY VARCHAR2) IS
    l_return_status varchar2(1) :=OKC_API.G_RET_STS_SUCCESS;

    l_api_name constant VARCHAR2(30) := 'Get_manual_adjustments';
    l_cle_id_tbl num_tbl_type;
    i pls_integer :=0;
    j pls_integer :=0;
    l_ind pls_integer :=0;
    l_id                        number;
    l_control_rec               OKC_CONTROL_REC_TYPE:= p_control_rec;
    l_id_tbl num_tbl_type;
    l_cle_price_tbl             CLE_PRICE_TBL_TYPE;
    l_req_line_tbl              QP_PREQ_GRP.LINE_TBL_TYPE;
    l_req_line_qual_tbl         QP_PREQ_GRP.QUAL_TBL_TYPE;
    l_req_line_attr_tbl         QP_PREQ_GRP.LINE_ATTR_TBL_TYPE;
    l_req_line_detail_tbl       QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
    l_req_line_detail_qual_tbl  QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE;
    l_req_line_detail_attr_tbl  QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE;
    l_req_related_line_tbl      QP_PREQ_GRP.RELATED_LINES_TBL_TYPE;
BEGIN
    --dbms_output.put_line('start new get manual adjs');
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('GET_MANUAL_ADJUSTMENTS');
    END IF;
    IF (l_debug = 'Y') THEN
       my_debug('18000 : Entering GET_MANUAL_ADJUSTMENTS', 2);
    END IF;

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PROCESS',
                                               x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                    raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_control_rec.p_calc_flag:='S';
    Set_control_rec(l_control_rec);

    If l_control_rec.p_level = 'H' and p_chr_id is not null then
      select id
      bulk collect into l_id_tbl
      from OKC_K_LINES_B
      where price_level_ind='Y' and dnz_chr_id = p_chr_id;
      IF (l_debug = 'Y') THEN
         my_debug('18010 : select rowcount'||SQL%ROWCOUNT, 1);
      END IF;

       i:= l_id_tbl.first;
       while i is not null loop
           l_cle_price_tbl(i).id:=l_id_tbl(i);
        i:=l_id_tbl.next(i);
       END loop;
       l_id := p_chr_id;
    ELSIF l_control_rec.p_level = 'L' and p_cle_id is not null then
               l_cle_price_tbl(1).id:=p_cle_id;
               l_id := p_cle_id;
    ELSIF  l_control_rec.p_level = 'QA' then
       OKC_API.set_message(p_app_name      => g_app_name,
                                 p_msg_name      => 'OKC_INVALID_LEVEL',
                                 p_token1        => 'level',
                                 p_token1_value  => 'QA');

        RAISE OKC_API.G_EXCEPTION_ERROR;
    End if;

    CALCULATE_price(p_api_version                => p_api_version,
                    p_CHR_ID                     => p_chr_id,
                    p_Control_Rec			     => l_control_rec,
                    px_req_line_tbl              => l_req_line_tbl,
                    px_Req_qual_tbl              => l_req_line_qual_tbl,
                    px_Req_line_attr_tbl         => l_req_line_attr_tbl,
                    px_Req_LINE_DETAIL_tbl       => l_req_line_detail_tbl,
                    px_Req_LINE_DETAIL_qual_tbl  => l_req_line_detail_qual_tbl,
                    px_Req_LINE_DETAIL_attr_tbl  => l_req_line_detail_attr_tbl,
                    px_Req_RELATED_LINE_TBL      => l_req_related_line_tbl,
                    px_CLE_PRICE_TBL		     => l_CLE_PRICE_TBL,
                    x_return_status              => x_return_status,
                    x_msg_count                  => x_msg_count,
                    x_msg_data                   => x_msg_data);
     IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    --Since there is only one line here in case of error return the error found
     ELSIF x_return_status = OKC_API.G_RET_STS_ERROR OR x_return_status = OKC_API.G_RET_STS_ERROR THEN
                  RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;
     i:=l_req_line_detail_tbl.first;
	        While i Is not Null Loop
               If l_req_line_detail_tbl(i).automatic_flag = 'N' Then --#2

                   If l_req_line_tbl(l_req_line_detail_tbl(i).line_index).line_id=l_id --#1
--                      and l_req_line_detail_tbl(i).line_index = l_discount_line_ind
                      and (( p_control_rec.p_level='L' and
                            l_req_line_tbl(l_req_line_detail_tbl(i).line_index).line_type_code = 'LINE')
                            OR (p_control_rec.p_level='H' and
                            l_req_line_tbl(l_req_line_detail_tbl(i).line_index).line_type_code = 'ORDER'))
                       then

                       x_adj_tbl(i).modifier_number:=l_req_line_detail_tbl(i).list_line_no;
                       x_adj_tbl(i).list_line_type_code :=l_req_line_detail_tbl(i).list_line_type_code;
                       x_adj_tbl(i).operand          :=l_req_line_detail_tbl(i).operand_value;
                       x_adj_tbl(i).list_line_id     :=l_req_line_detail_tbl(i).list_line_id;
                       x_adj_tbl(i).list_header_id   :=l_req_line_detail_tbl(i).list_header_id;
                       x_adj_tbl(i).pricing_phase_id :=l_req_line_detail_tbl(i).pricing_phase_id;
                       x_adj_tbl(i).automatic_flag   :=l_req_line_detail_tbl(i).automatic_flag;
                       x_adj_tbl(i).modifier_level_code:=l_req_line_detail_tbl(i).modifier_level_code;
                       x_adj_tbl(i).override_flag    :=l_req_line_detail_tbl(i).override_flag;
                       x_adj_tbl(i).applied_flag     :=l_req_line_detail_tbl(i).applied_flag;
                       x_adj_tbl(i).operator         :=l_req_line_detail_tbl(i).operand_calculation_code;
                       x_adj_tbl(i).MODIFIER_MECHANISM_TYPE_CODE      := l_req_line_detail_tbl(i).created_from_list_type_code;


                       /** Bug 2692818: for manual adjustments based on line AMOUNT, we need to store the 'line quantity'
                           coming from pricing as range break quantity. Pricing returns 'line quantity' for the PBH.
                       **/
                       If l_req_line_detail_tbl(i).list_line_type_code = 'PBH' Then
                          x_adj_tbl(i).range_break_quantity := l_req_line_detail_tbl(i).line_quantity;


                          --Bug 2784735: need to use this for price break modifiers using formula
                          x_adj_tbl(i).line_detail_index := l_req_line_detail_tbl(i).line_detail_index;

                       End If;


                   End If; --#1

                End If; --#2


                  i:=l_req_line_detail_tbl.next(i);
                End Loop;


IF (l_debug = 'Y') THEN
   my_debug('18400 : --------------Manual discounts returned for Id'||l_id);
END IF;
I := x_adj_tbl.FIRST;
IF I IS NOT NULL THEN
 LOOP
                      IF (l_debug = 'Y') THEN
                         my_debug('18400 : modifier no :'||x_adj_tbl(i).modifier_number,1);
                         my_debug('18410 : list line type code :'||x_adj_tbl(i).list_line_type_code,1);
                         my_debug('18420 : operand :'||x_adj_tbl(i).operand,1);
                         my_debug('18430 : list line id :'|| x_adj_tbl(i).list_line_id,1);
                         my_debug('18440 : list header id :'||x_adj_tbl(i).list_header_id,1);
                         my_debug('18450 : pricing phase id :'||x_adj_tbl(i).pricing_phase_id ,1);
                         my_debug('18460 : automatic flag :'||x_adj_tbl(i).automatic_flag ,1);
                         my_debug('18470 :  modifier level code :'||x_adj_tbl(i).modifier_level_code,1);
                         my_debug('18480 : override flag :'||x_adj_tbl(i).override_flag ,1);
                         my_debug('18490 :  Applied flag :'||x_adj_tbl(i).Applied_flag,1);
                         my_debug('18500 :  operator :'||x_adj_tbl(i).operator ,1);
                         my_debug('18502 :  modifier mechanism type code :'||x_adj_tbl(i).modifier_mechanism_type_code ,1);
                         my_debug('18503 : range break quantity :'||x_adj_tbl(i).range_break_quantity,1);
                         my_debug('18504 : line detail index :'||x_adj_tbl(i).line_detail_index,1);
                      END IF;
  EXIT WHEN I =x_adj_tbl.LAST;
  I := x_adj_tbl.NEXT(I);


 END LOOP;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       my_debug('18600 : Exiting GET_MANUAL_ADJUSTMENTS', 2);
    END IF;
    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;

END IF;  ----end dbmsoutput area
    EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
              x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                       'OKC_API.G_RET_STS_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');
         IF (l_debug = 'Y') THEN
            my_debug('18700 : Exiting GET_MANUAL_ADJUSTMENTS', 4);
         END IF;
         IF (l_debug = 'Y') THEN
            okc_debug.Reset_Indentation;
         END IF;

         WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
              x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                       'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');
         IF (l_debug = 'Y') THEN
            my_debug('18800 : Exiting GET_MANUAL_ADJUSTMENTS', 4);
         END IF;
         IF (l_debug = 'Y') THEN
            okc_debug.Reset_Indentation;
         END IF;

         WHEN OTHERS THEN
              OKC_API.set_message(p_app_name     => g_app_name,
                                 p_msg_name      => g_unexpected_error,
                                 p_token1        => g_sqlcode_token,
                                 p_token1_value  => sqlcode,
                                 p_token2        => g_sqlerrm_token,
                                 p_token2_value  => sqlerrm);
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
         IF (l_debug = 'Y') THEN
            my_debug('18900 : Exiting GET_MANUAL_ADJUSTMENTS', 4);
         END IF;
         IF (l_debug = 'Y') THEN
            okc_debug.Reset_Indentation;
         END IF;

 END get_manual_adjustments;

--????? no foriegn key checks in PAT for cle/chr
--??????ask sri assocs- we donot generate extra lines , so relate how. for price breaks need to store unapplied ones as well
END OKC_PRICE_PVT;

/
