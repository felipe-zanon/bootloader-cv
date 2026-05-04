# 💾 Bootloader CV

Um currículo executável que roda direto na BIOS (bare metal), sem necessidade de um sistema operacional. Desenvolvido inteiramente em **Assembly 16-bits (NASM)** e **C**.

![Preview do Bootloader](assets/preview.png)

## 🚀 O Projeto
Em vez de enviar um PDF tradicional, decidi programar o meu currículo direto no setor de boot de um disco flexível. O programa ocupa o primeiro setor (512 bytes) para configurar o ambiente e carregar o segundo setor na memória, onde uma imagem minha e a frase "Me contrata! =D" são desenhadas na tela.

Para fazer a imagem caber no setor de boot, desenvolvi um conversor próprio em C (`LeitorBMP`) que lê uma imagem `.bmp` monocromática e aplica um algoritmo de compressão **RLE (Run-Length Encoding)** customizado, gerando o array de bytes que o Assembly lê e desenha na tela usando a interrupção de vídeo da BIOS.

## ⚙️ Tecnologias e Conceitos Aplicados
* **Assembly x86 (16-bits):** Acesso direto ao hardware via interrupções da BIOS (`int 0x10` para vídeo, `int 0x13` para leitura de disco).
* **Modo Gráfico VGA 13h:** Manipulação direta de pixels na tela.
* **C & Manipulação de Bits:** Leitura de arquivos binários e extração de metadados de cabeçalhos BMP.
* **Estrutura de Dados:** Implementação de compressão RLE para otimização extrema de espaço em disco (limite de 512 bytes por setor).
* **Estrutura FAT12:** O bootloader foi escrito respeitando a estrutura BPB do FAT12 para ser reconhecido como uma mídia válida.

## 🛠️ Como rodar
Para testar este projeto na sua máquina, você precisará do **NASM** para compilar e do **QEMU** (ou Bochs) para emular.

1. Compile o bootloader:
\`\`\`bash
nasm -f bin src-asm/bootloader.asm -o bootloader.bin
\`\`\`

2. Execute no emulador:
\`\`\`bash
qemu-system-i386 -fda bootloader.bin
\`\`\`

## 👨‍💻 Sobre mim
[Escreva um parágrafo rápido sobre você, seus interesses na área de segurança, redes, SOC ou baixo nível, e deixe seu LinkedIn/Email de contato]