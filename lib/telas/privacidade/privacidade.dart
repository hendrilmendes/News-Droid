import 'package:flutter/material.dart';

class PolicyPage extends StatelessWidget {
  const PolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Política de Privacidade'),
      ),
      body: const Card(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Text(
              style: TextStyle(fontSize: 16),
              """
      Aplicável em 01/08/2023
      
          Este aplicativo respeita sua privacidade e está comprometido em proteger suas informações pessoais. Esta política de privacidade descreve como coletamos, usamos e compartilhamos suas informações pessoais quando você usa nossos produtos e serviços.
      
          Coleta de Informações Pessoais
      
          Quando você usa nossos produtos e serviços, coletamos as seguintes informações pessoais:
      
          * Suas visitas aos nossos sites;
          * Suas interações com nossos anúncios;
          * Suas atividades em nossos produtos e serviços.
      
          Também podemos coletar informações pessoais de outras fontes, como parceiros de negócios, fontes públicas e redes sociais.
      
          Uso de Informações Pessoais
      
          Usamos suas informações pessoais para os seguintes fins:
      
          * Fornecer nossos produtos e serviços;
          * Melhorar nossos produtos e serviços;
          * Personalizar sua experiência;
          * Contatá-lo;
          * Cumprir com as leis e regulamentos aplicáveis.
      
          Compartilhamento de Informações Pessoais
      
          Compartilhamos suas informações pessoais com as seguintes entidades:
      
          * Nossos parceiros de negócios;
          * Fornecedores de serviços;
          * Autoridades governamentais;
          * Outros terceiros quando for necessário para cumprir com as leis e regulamentos aplicáveis.
      
          Segurança de Informações Pessoais
      
          Tomamos medidas de segurança para proteger suas informações pessoais contra acesso, uso, divulgação, alteração e destruição não autorizados. Estas medidas incluem:
      
          * Criptografia;
          * Controle de acesso;
          * Auditoria;
          * Treinamento de funcionários.
      
          Seus Direitos
      
          Você tem os seguintes direitos sobre suas informações pessoais:
      
          * Acesso;
          * Correção;
          * Apagar;
          * Restringir;
          * Portabilidade;
          * Oposição;
          * Não ser discriminado.
      
          Você pode exercer estes direitos entrando em contato conosco através do email hendrilmendes2015@gmail.com.
      
          Atualizações
      
          Podemos atualizar esta política de privacidade a qualquer momento. Se fizermos alterações importantes, iremos notificá-lo por e-mail ou através de um aviso em nossos sites.
      
          Contato
      
          Se você tiver alguma dúvida sobre esta política de privacidade, entre em contato conosco através do email hendrilmendes2015@gmail.com.
          """,
            ),
          ),
        ),
      ),
    );
  }
}
