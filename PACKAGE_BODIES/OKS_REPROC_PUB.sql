--------------------------------------------------------
--  DDL for Package Body OKS_REPROC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_REPROC_PUB" As
/* $Header: OKSOREPB.pls 120.0 2005/05/25 17:46:51 appldev noship $ */


Procedure submit_request(x_request_id OUT NOCOPY NUMBER)
Is
l_request_id NUMBER;

Begin
	l_request_id := FND_REQUEST.SUBMIT_REQUEST('OKS','OKSREPROC','','',FALSE,'SEL','FORM');
    if (l_request_id > 0) then
      COMMIT WORK;
    end if;

    x_request_id := l_request_id;

End;

Procedure insert_order_line(
                            p_ordline_id IN NUMBER,
                            p_processed IN VARCHAR2,
                            p_reprocess IN VARCHAR2,
                            p_hdr_id IN NUMBER,
			    p_ordnum IN NUMBER,
			    x_id OUT NOCOPY VARCHAR2,
			    x_rowid OUT NOCOPY VARCHAR2,
                            x_return_status OUT NOCOPY VARCHAR2
                           )
Is
l_init_msg_list         VARCHAR2(1) := OKC_API.G_FALSE;
l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_msg_count             NUMBER := 0;
l_msg_data              VARCHAR2(2000);
l_repv_rec              OKS_REP_PVT.repv_rec_type;
l_out_repv_rec          OKS_REP_PVT.repv_rec_type;

Begin

l_repv_rec.order_line_id := p_ordline_id;
l_repv_rec.order_id := p_hdr_id;
l_repv_rec.order_number  := p_ordnum;
l_repv_rec.source_flag := 'MANUAL';
l_repv_rec.success_flag:= p_processed;
l_repv_rec.reprocess_yn := p_reprocess;

SAVEPOINT BEFORE_INSERT;
oks_rep_pub.insert_row(p_api_version                  => 1.0,
                       p_init_msg_list                => l_init_msg_list,
                       x_return_status                => l_return_status,
                       x_msg_count                    => l_msg_count,
                       x_msg_data                     => l_msg_data,
                       p_repv_rec                     => l_repv_rec ,
                       x_repv_rec                     => l_out_repv_rec);

x_id := l_out_repv_rec.id;

select rowid into x_rowid
from oks_reprocessing
where id = x_id;

x_return_status := l_return_status;

EXCEPTION
WHEN DUP_VAL_ON_INDEX THEN
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'Dup val exp raised');
        ROLLBACK to BEFORE_INSERT;
        x_return_status := 'S';

End;

Procedure Update_Order_Lines(p_item IN VARCHAR2,
			     x_return_status OUT NOCOPY VARCHAR2)
Is

Cursor Get_Order_lines Is
                Select id,object_version_number
                From oks_reprocessing
                Where reprocess_yn = 'Y'
                And Conc_request_id is null;

l_obj_vers_num                NUMBER;
l_id                          NUMBER;
l_new_repv_rec                OKS_REP_PVT.repv_rec_type;
l_repv_rec                    OKS_REP_PVT.repv_rec_type;
l_return_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_msg_count                   NUMBER;
l_msg_data                    VARCHAR2(2000);

Begin
      x_return_status := l_return_status;
      If(p_item = 'Submit') Then
        Open Get_Order_lines;
        Loop
                Fetch Get_Order_lines into l_id,l_obj_vers_num;
                Exit when Get_Order_lines%NOTFOUND;
                l_repv_rec.id := l_id;
                l_repv_rec.object_version_number := l_obj_vers_num;
                l_repv_rec.reprocess_yn := 'N';
                l_repv_rec.success_flag := 'R';

                oks_rep_pub.update_row(p_api_version      => 1.0,
                               p_init_msg_list    => 'T',
                               x_return_status    => l_return_status,
                               x_msg_count        => l_msg_count,
                               x_msg_data         => l_msg_data,
                               p_repv_rec         => l_repv_rec ,
                               x_repv_rec         => l_new_repv_rec);

                X_return_status := l_return_status;
                If(l_return_status <> FND_API.G_RET_STS_SUCCESS) then
                        Exit;
                End If;
        End Loop;
        Close Get_Order_lines;
     End If;

End Update_Order_Lines;


Procedure translate_msg(p_id IN NUMBER , x_msg OUT NOCOPY VARCHAR2)
Is

Cursor get_message_csr(p_id IN NUMBER)
Is
Select error_text
from oks_reprocessing
where id = p_id;

l_ind1 Number;
l_ind2 Number;
l_msg Varchar2(2000);
i Number;
l_message_txt Varchar2(2000);
l_id NUMBER;
l_error_text VARCHAR2(2000);

Begin

Open get_message_csr(p_id);
Fetch get_message_csr into l_error_text;
Close get_message_csr;



l_ind1 := instr(l_error_text,'#',1,1);
l_ind2 := instr(l_error_text,'#',1,2);


If(l_ind2 = 0) Then

	x_msg := null;
Else

	l_msg := substr(l_error_text,l_ind1+1, l_ind2-l_ind1-1);
	fnd_message.set_encoded(l_msg);
	l_message_txt := fnd_message.get || '; ' ;

	i := 3;

	Loop

		l_ind1 := l_ind2;
		l_ind2 := instr(l_error_text,'#',1,i);

		If(l_ind2 = 0) Then
			exit;
		Else
			l_msg := substr(l_error_text,l_ind1+1, l_ind2-l_ind1-1);
			fnd_message.set_encoded(l_msg);
			l_message_txt := l_message_txt || fnd_message.get || '; ' ;
			i := i + 1;
		End If;
	End Loop;


	x_msg := l_message_txt;
End If;



End translate_msg;

End OKS_REPROC_PUB;


/
