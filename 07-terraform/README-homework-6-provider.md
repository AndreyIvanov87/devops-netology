# Домашнее задание к занятию "7.6. Написание собственных провайдеров для Terraform."

Бывает, что 
* общедоступная документация по терраформ ресурсам не всегда достоверна,
* в документации не хватает каких-нибудь правил валидации или неточно описаны параметры,
* понадобиться использовать провайдер без официальной документации,
* может возникнуть необходимость написать свой провайдер для системы используемой в ваших проектах.   

## Задача 1. 
Давайте потренируемся читать исходный код AWS провайдера, который можно склонировать от сюда: 
[https://github.com/hashicorp/terraform-provider-aws.git](https://github.com/hashicorp/terraform-provider-aws.git).
Просто найдите нужные ресурсы в исходном коде и ответы на вопросы станут понятны.  


1. Найдите, где перечислены все доступные `resource` и `data_source`, приложите ссылку на эти строки в коде на гитхабе.
https://github.com/hashicorp/terraform-provider-aws/blob/1644f0171903703fcbc36ae054dc7accce94403f/internal/provider/provider.go#L423  
https://github.com/hashicorp/terraform-provider-aws/blob/1644f0171903703fcbc36ae054dc7accce94403f/internal/provider/provider.go#L902     
1. Для создания очереди сообщений SQS используется ресурс `aws_sqs_queue` у которого есть параметр `name`.
 в ResourcesMap ищем  
"aws_sqs_queue":        sqs.ResourceQueue(),
Функцию ResourceQueue() находим в файле internal/service/sqs/queue.go  
package sqs
...
https://github.com/hashicorp/terraform-provider-aws/blob/1644f0171903703fcbc36ae054dc7accce94403f/internal/service/sqs/queue.go#L169  

Там же объявлены переменные в начале файла:
```go
var (
	queueSchema = map[string]*schema.Schema{
...
		"name": {
			Type:          schema.TypeString,
			Optional:      true,
			Computed:      true,
			ForceNew:      true,
			ConflictsWith: []string{"name_prefix"},
		},
		"name_prefix": {
			Type:          schema.TypeString,
			Optional:      true,
			Computed:      true,
			ForceNew:      true,
			ConflictsWith: []string{"name"},
		},
```
    * С каким другим параметром конфликтует `name`? Приложите строчку кода, в которой это указано.
                        ConflictsWith: []string{"name_prefix"},  
    * Какая максимальная длина имени? - 75 символов.  
    * Какому регулярному выражению должно подчиняться имя?  
```go

		if fifoQueue {
			re = regexp.MustCompile(`^[a-zA-Z0-9_-]{1,75}\.fifo$`)
		} else {
			re = regexp.MustCompile(`^[a-zA-Z0-9_-]{1,80}$`)
		}

		if !re.MatchString(name) {
			return fmt.Errorf("invalid queue name: %s", name)
		}    
```

## Задача 2. (Не обязательно) 
В рамках вебинара и презентации мы разобрали как создать свой собственный провайдер на примере кофемашины. 
Также вот официальная документация о создании провайдера: 
[https://learn.hashicorp.com/collections/terraform/providers](https://learn.hashicorp.com/collections/terraform/providers).

1. Проделайте все шаги создания провайдера.
2. В виде результата приложение ссылку на исходный код.
3. Попробуйте скомпилировать провайдер, если получится то приложите снимок экрана с командой и результатом компиляции.   

---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
