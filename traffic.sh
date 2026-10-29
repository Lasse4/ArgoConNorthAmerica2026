#!/bin/bash
# Asks questions through agentgateway (port-forward on 8080) and shows who answered

questions=(
  "What are the continents?"
  "Which planet is known as the Red Planet?"
  "What gas do plants absorb from the air?"
  "How many legs does a spider have?"
  "What is the largest ocean?"
)

while true; do
  for question in "${questions[@]}"; do
    response=$(curl -s -i http://localhost:8080/v1/chat/completions \
      -H "content-type: application/json" \
      -d "{\"model\":\"assistant\",\"temperature\":0,\"max_tokens\":30,\"messages\":[{\"role\":\"user\",\"content\":\"$question\"}]}")

    # headers set by agentgateway
    backend=$(echo "$response" | grep -i "^x-served-by" | cut -d' ' -f2 | cut -d'.' -f1)
    tokens=$(echo "$response" | grep -i "^x-total-tokens" | cut -d' ' -f2 | tr -d '\r')
    answer=$(echo "$response" | grep -o '"content":"[^"]*"' | cut -d'"' -f4)

    if [ -z "$backend" ]; then
      echo "no answer. Is the port-forward on 8080 running?"
      sleep 2
    elif [ "$backend" = "assistant-canary" ]; then
      echo -e "\033[32m$backend\033[0m ($tokens tokens)  $question -> $answer"
    else
      echo "$backend ($tokens tokens)  $question -> $answer"
    fi
    sleep 0.2
  done
done
