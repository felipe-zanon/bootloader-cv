# CV-Bootloader Poliglota: Sistema Operacional em Bare-Metal

Um projeto de engenharia de software de baixo nível que transforma um currículo tradicional num arquivo poliglota: funciona como um documento **PDF legível**  e como um **Bootloader de 16-bits executável** que roda direto na BIOS.



## Arquivo Poliglota
O arquivo `CVBootloader.pdf` na raiz deste repositório foi construído manipulando as estruturas de cabeçalho binário. 
1. **Como PDF:** Ao dar duplo clique no sistema operacional, os leitores de PDF interpretam a assinatura `%PDF-` e processam a tabela de referências cruzadas, exibindo o currículo estático perfeitamente.
2. **Como Bootloader:** Ao ser montado como um disco de boot (Floppy) no VMware ou QEMU, a BIOS lê os primeiros bytes do arquivo. A assinatura do PDF é interpretada pela CPU como instruções x86 válidas e inofensivas (`AND AX, 4450h`), seguidas por um salto lógico (`jmp`) que desvia a execução diretamente para o  código em Assembly, renderizando a interface gráfica.

## Arquitetura de Software e Tecnologias
* **Assembly x86 (16-bits):** Programação bare-metal com manipulação direta de registradores e chamadas de interrupções da BIOS (`int 0x10` para vídeo VGA Modo 13h e `int 0x13` para leitura estendida de setores).
* **Compressão RLE Customizada:** Desenvolvido um compressor em **C** para mitigar a limitação de espaço físico em disco, otimizando matrizes de pixels em sequências de bytes consecutivas contidas na memória.
* **Segurança de Memória:** Implementada trava lógica de fim de dados prevenindo o vazamento de ponteiros de leitura para áreas corrompidas ou lixo da RAM.

## Como Executar o Bootloader
Se quiser ver o código rodando em tempo real na BIOS através do emulador QEMU, execute:

```bash
qemu-system-i386 -fda CVBootloader.pdf
